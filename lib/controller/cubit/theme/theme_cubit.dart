import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/theme_model.dart';
import '../../services/theme_service.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final ThemeService _themeService;

  ThemeCubit({ThemeService? themeService})
    : _themeService = themeService ?? ThemeService.instance,
      super(ThemeState.initial());

  // Initialize theme from storage or use default
  Future<void> initializeTheme() async {
    emit(state.copyWith(status: ThemeStatus.loading));

    try {
      final savedTheme = await _themeService.loadTheme();
      emit(
        state.copyWith(currentTheme: savedTheme, status: ThemeStatus.loaded),
      );
    } catch (e) {
      emit(
        state.copyWith(
          currentTheme: AppThemes.defaultTheme,
          status: ThemeStatus.error,
          errorMessage: 'Failed to load theme: $e',
        ),
      );
    }
  }

  // Change theme and persist it
  Future<void> changeTheme(AppTheme newTheme) async {
    emit(state.copyWith(status: ThemeStatus.loading));

    try {
      final success = await _themeService.saveTheme(newTheme);

      if (success) {
        emit(
          state.copyWith(currentTheme: newTheme, status: ThemeStatus.loaded),
        );
      } else {
        emit(
          state.copyWith(
            status: ThemeStatus.error,
            errorMessage: 'Failed to save theme',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ThemeStatus.error,
          errorMessage: 'Error changing theme: $e',
        ),
      );
    }
  }

  // Reset theme to default
  Future<void> resetTheme() async {
    emit(state.copyWith(status: ThemeStatus.loading));

    try {
      await _themeService.clearTheme();
      emit(
        state.copyWith(
          currentTheme: AppThemes.defaultTheme,
          status: ThemeStatus.loaded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ThemeStatus.error,
          errorMessage: 'Error resetting theme: $e',
        ),
      );
    }
  }

  // Get current theme color for backward compatibility
  AppTheme get currentTheme => state.currentTheme;

  // Check if theme is default
  bool get isDefaultTheme => state.currentTheme == AppThemes.defaultTheme;

  // Get all available themes
  List<AppTheme> get availableThemes => AppThemes.availableThemes;
}
