import 'package:equatable/equatable.dart';
import '../../../models/user_model.dart';

enum UserProfileStatus { initial, loading, loaded, error }

class UserProfileState extends Equatable {
  final UserProfileStatus status;
  final UserModel? user;
  final String? errorMessage;
  
  const UserProfileState({
    this.status = UserProfileStatus.initial,
    this.user = null,
    this.errorMessage,
  });
  
  UserProfileState copyWith({
    UserProfileStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return UserProfileState(
      status: status ?? this.status,
      user: user ?? this.user ?? UserModel.empty(),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
  
  @override
  List<Object?> get props => [status, user, errorMessage];
}
