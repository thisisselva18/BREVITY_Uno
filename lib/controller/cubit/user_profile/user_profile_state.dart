import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../models/user_model.dart';

enum UserProfileStatus { initial, loading, loaded, error }

class UserProfileState extends Equatable {
  final UserProfileStatus status;
  final UserModel? user;
  final String? errorMessage;
  final File? localProfileImage; // Add this line

  const UserProfileState({
    this.status = UserProfileStatus.initial,
    this.user,
    this.errorMessage,
    this.localProfileImage, // Add this line
  });

  UserProfileState copyWith({
    UserProfileStatus? status,
    UserModel? user,
    String? errorMessage,
    File? localProfileImage, // Add this line
  }) {
    return UserProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      localProfileImage: localProfileImage ?? this.localProfileImage, // Add this line
    );
  }

  // Helper getters
  bool get isLoading => status == UserProfileStatus.loading;
  bool get isLoaded => status == UserProfileStatus.loaded;
  bool get hasError => status == UserProfileStatus.error;
  bool get isInitial => status == UserProfileStatus.initial;
  bool get hasUser => user != null;

  @override
  List<Object?> get props => [status, user, errorMessage, localProfileImage]; // Add localProfileImage here
}
