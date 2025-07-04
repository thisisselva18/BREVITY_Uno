import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:brevity/controller/services/firestore_service.dart';
import 'package:brevity/controller/services/auth_service.dart';
import '../../../models/user_model.dart';
import 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final UserRepository _userRepository = UserRepository();
  final AuthService _authService = AuthService();
  StreamSubscription? _profileSubscription;
  
  UserProfileCubit() : super(UserProfileState());
  
  // Load user profile once
  Future<void> loadUserProfile() async {
    emit(state.copyWith(status: UserProfileStatus.loading));
    
    try {
      final User? currentUser = _authService.currentUser;
      
      if (currentUser == null) {
        emit(state.copyWith(
          status: UserProfileStatus.error,
          errorMessage: 'No authenticated user found',
        ));
        return;
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
  
  // Subscribe to real-time profile updates
  void startProfileSubscription() {
    final User? currentUser = _authService.currentUser;
    
    if (currentUser == null) {
      emit(state.copyWith(
        status: UserProfileStatus.error,
        errorMessage: 'No authenticated user found',
      ));
      return;
    }
    
    emit(state.copyWith(status: UserProfileStatus.loading));
    
    _profileSubscription?.cancel();
    _profileSubscription = _userRepository
        .userProfileStream(currentUser.uid)
        .listen(
          (profile) => emit(state.copyWith(
            status: UserProfileStatus.loaded,
            user: profile,
          )),
          onError: (error) => emit(state.copyWith(
            status: UserProfileStatus.error,
            errorMessage: error.toString(),
          )),
        );
  }
  
  // Update user profile
  Future<void> updateProfile({required String displayName}) async {
    try {
      final UserModel updatedUser = UserModel(
        uid: state.user?.uid ?? '',
        displayName: displayName,
        email: state.user?.email ?? '',
        emailVerified: state.user?.emailVerified ?? false,
        createdAt: state.user?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _userRepository.updateUserProfile(updatedUser);
      // No need to emit a new state as the stream subscription will handle that
    } catch (e) {
      emit(state.copyWith(
        status: UserProfileStatus.error,
        errorMessage: 'Failed to update profile: ${e.toString()}',
      ));
    }
  }
  
  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}
