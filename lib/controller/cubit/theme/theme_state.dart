import 'package:equatable/equatable.dart';
import '../../../models/theme_model.dart';

enum ThemeStatus { initial, loading, loaded, error }

class ThemeState extends Equatable {
  final AppTheme currentTheme;
  final ThemeStatus status;
  final String? errorMessage;

  const ThemeState({
    required this.currentTheme,
    required this.status,
    this.errorMessage,
  });

  factory ThemeState.initial() {
    return ThemeState(
      currentTheme: AppTheme.defaultTheme,
      status: ThemeStatus.initial,
    );
  }

  ThemeState copyWith({
    AppTheme? currentTheme,
    ThemeStatus? status,
    String? errorMessage,
  }) {
    return ThemeState(
      currentTheme: currentTheme ?? this.currentTheme,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [currentTheme, status, errorMessage];
}
