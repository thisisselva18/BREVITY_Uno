import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brevity/controller/services/firestore_service.dart'; // This is your UserRepository
import 'package:brevity/controller/services/auth_service.dart';
import '../../../models/user_model.dart';
import 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final UserRepository _userRepository = UserRepository();
  final AuthService _authService = AuthService();
  StreamSubscription? _authSubscription;

  UserProfileCubit() : super(UserProfileState()) {
    // Listen to auth state changes
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authSubscription = _authService.authStateChanges.listen((user) {
      if (user != null) {
        // User is logged in, load their profile
        loadUserProfile();
      } else {
        // User is logged out, clear profile
        emit(UserProfileState());
      }
    });
  }

  // Load user profile once
  Future<void> loadUserProfile() async {
    emit(state.copyWith(status: UserProfileStatus.loading));

    try {
      final UserModel? currentUser = _authService.currentUser;

      if (currentUser == null) {
        emit(state.copyWith(
          status: UserProfileStatus.error,
          errorMessage: 'No authenticated user found',
        ));
        return;
      }

      // Set access token in repository
      final String? accessToken = _authService.accessToken;
      if (accessToken != null) {
        _userRepository.setAccessToken(accessToken);
      }

      final UserModel profile = await _userRepository.getUserProfile(currentUser.uid);

      emit(state.copyWith(
        status: UserProfileStatus.loaded,
        user: profile,
        localProfileImage: null, // Clear local image when loading from server
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserProfileStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // Update user profile
  Future<void> updateProfile({
    required String displayName,
    File? profileImage,
  }) async {
    try {
      emit(state.copyWith(
        status: UserProfileStatus.loading,
        localProfileImage: profileImage, // Store local image immediately for UI feedback
      ));

      final UserModel? currentUser = _authService.currentUser;
      if (currentUser == null) {
        emit(state.copyWith(
          status: UserProfileStatus.error,
          errorMessage: 'No authenticated user found',
          localProfileImage: null, // Clear local image on error
        ));
        return;
      }

      final UserModel updatedUser = UserModel(
        uid: currentUser.uid,
        displayName: displayName,
        email: currentUser.email,
        emailVerified: currentUser.emailVerified,
        createdAt: currentUser.createdAt,
        updatedAt: DateTime.now(),
        // Keep the existing profileImageUrl if no new image is provided
        profileImageUrl: currentUser.profileImageUrl,
      );

      // Set access token in repository
      final String? accessToken = _authService.accessToken;
      if (accessToken != null) {
        _userRepository.setAccessToken(accessToken);
      }

      // Update profile on server - this should return the updated user with new profileImageUrl
      final UserModel updatedProfile = await _userRepository.updateUserProfile(
          updatedUser,
          profileImage: profileImage
      );

      // Update the auth service's current user with the new profile data
      // This ensures the auth service has the latest user info including profileImageUrl
      await _authService.refreshUser();

      // Emit the updated profile (which should include the new profileImageUrl from server)
      emit(state.copyWith(
        status: UserProfileStatus.loaded,
        user: updatedProfile, // Use the profile returned from server
        localProfileImage: null, // Clear local image since we now have the server URL
      ));

    } catch (e) {
      emit(state.copyWith(
        status: UserProfileStatus.error,
        errorMessage: 'Failed to update profile: ${e.toString()}',
        localProfileImage: null, // Clear local image on error
      ));
    }
  }

  // Refresh profile data
  Future<void> refreshProfile() async {
    await loadUserProfile();
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
