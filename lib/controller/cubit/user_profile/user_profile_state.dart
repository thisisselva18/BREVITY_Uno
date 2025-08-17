import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../models/user_model.dart';

enum UserProfileStatus { initial, loading, loaded, error }

class UserProfileState extends Equatable {
  final UserProfileStatus status;
  final UserModel? user;
  final String? errorMessage;
  final File? localProfileImage;

  const UserProfileState({
    this.status = UserProfileStatus.initial,
    this.user,
    this.errorMessage,
    this.localProfileImage,
  });

  UserProfileState copyWith({
    UserProfileStatus? status,
    UserModel? user,
    String? errorMessage,
    File? localProfileImage,
    bool clearLocalImage = false, // Add this flag
  }) {
    return UserProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      localProfileImage: clearLocalImage ? null : (localProfileImage ?? this.localProfileImage),
    );
  }

  // Helper getters
  bool get isLoading => status == UserProfileStatus.loading;
  bool get isLoaded => status == UserProfileStatus.loaded;
  bool get hasError => status == UserProfileStatus.error;
  bool get isInitial => status == UserProfileStatus.initial;
  bool get hasUser => user != null;

  @override
  List<Object?> get props => [status, user, errorMessage, localProfileImage];
}
