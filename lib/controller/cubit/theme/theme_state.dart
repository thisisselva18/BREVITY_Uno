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

  // Initial state
  factory ThemeState.initial() {
    return const ThemeState(
      currentTheme: AppThemes.defaultTheme,
      status: ThemeStatus.initial,
    );
  }

  // Loading state
  ThemeState loading() {
    return copyWith(status: ThemeStatus.loading);
  }

  // Loaded state
  ThemeState loaded(AppTheme theme) {
    return copyWith(
      currentTheme: theme,
      status: ThemeStatus.loaded,
      errorMessage: null,
    );
  }

  // Error state
  ThemeState error(String message) {
    return copyWith(status: ThemeStatus.error, errorMessage: message);
  }

  // Copy with method
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

  @override
  String toString() {
    return 'ThemeState(currentTheme: ${currentTheme.name}, status: $status, errorMessage: $errorMessage)';
  }
}
