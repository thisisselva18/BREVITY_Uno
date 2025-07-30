import 'dart:async';
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
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserProfileStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
  
  // Update user profile
  Future<void> updateProfile({required String displayName}) async {
    try {
      emit(state.copyWith(status: UserProfileStatus.loading));
      
      final UserModel? currentUser = _authService.currentUser;
      if (currentUser == null) {
        emit(state.copyWith(
          status: UserProfileStatus.error,
          errorMessage: 'No authenticated user found',
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
      );
      
      // Set access token in repository
      final String? accessToken = _authService.accessToken;
      if (accessToken != null) {
        _userRepository.setAccessToken(accessToken);
      }
      
      await _userRepository.updateUserProfile(updatedUser);
      
      // After successful update, load the updated profile
      await loadUserProfile();
      
    } catch (e) {
      emit(state.copyWith(
        status: UserProfileStatus.error,
        errorMessage: 'Failed to update profile: ${e.toString()}',
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
