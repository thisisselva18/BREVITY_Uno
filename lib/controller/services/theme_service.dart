import 'dart:convert';
import 'package:brevity/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/theme_model.dart';

class ThemeService {
  static const String _themeKey = 'selected_theme';
  static ThemeService? _instance;
  SharedPreferences? _prefs;

  // Singleton pattern
  static ThemeService get instance {
    _instance ??= ThemeService._();
    return _instance!;
  }

  ThemeService._();

  // Initialize the service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save theme to local storage
  Future<bool> saveTheme(AppTheme theme) async {
    try {
      await _ensureInitialized();
      final themeJson = jsonEncode(theme.toJson());
      Log.i("Saving theme: $themeJson");
      return await _prefs!.setString(_themeKey, themeJson);
    } catch (e) {
      Log.e('Error saving theme: $e');
      return false;
    }
  }

  // Load theme from local storage
  Future<AppTheme> loadTheme() async {
    try {
      await _ensureInitialized();
      final themeJson = _prefs!.getString(_themeKey);
      Log.d("Loading theme: $themeJson");

      if (themeJson != null) {
        final themeMap = jsonDecode(themeJson) as Map<String, dynamic>;
        final loadedTheme = AppTheme.fromJson(themeMap);
        Log.i("Loaded theme: ${loadedTheme.name}");
        return loadedTheme;
      } else {
        Log.w("No saved theme found, using default");
      }
    } catch (e) {
      Log.e('Error loading theme: $e');
    }

    // Return default theme if loading fails
    return AppThemes.defaultTheme;
  }

  // Clear saved theme
  Future<bool> clearTheme() async {
    try {
      await _ensureInitialized();
      Log.d("Clearing theme");
      return await _prefs!.remove(_themeKey);
    } catch (e) {
      Log.e('Error clearing theme: $e');
      return false;
    }
  }

  // Check if theme is saved
  Future<bool> hasTheme() async {
    try {
      await _ensureInitialized();
      return _prefs!.containsKey(_themeKey);
    } catch (e) {
      Log.e('Error checking theme: $e');
      return false;
    }
  }

  // Get saved theme synchronously (for immediate access after initialization)
  AppTheme? getSavedThemeSync() {
    try {
      if (_prefs == null) return null;
      
      final themeJson = _prefs!.getString(_themeKey);
      if (themeJson != null) {
        final themeMap = jsonDecode(themeJson) as Map<String, dynamic>;
        return AppTheme.fromJson(themeMap);
      }
    } catch (e) {
      Log.e('Error getting saved theme sync: $e');
    }
    return null;
  }

  // Ensure SharedPreferences is initialized
  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
}