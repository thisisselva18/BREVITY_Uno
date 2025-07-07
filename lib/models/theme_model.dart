import 'package:flutter/material.dart';

class AppTheme {
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final int colorValue; // For persistence

  const AppTheme({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.colorValue,
  });

  // Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {'name': name, 'colorValue': colorValue};
  }

  // Create from JSON
  factory AppTheme.fromJson(Map<String, dynamic> json) {
    final colorValue = json['colorValue'] as int;
    return AppThemes.availableThemes.firstWhere(
      (theme) => theme.colorValue == colorValue,
      orElse: () => AppThemes.defaultTheme,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppTheme && other.colorValue == colorValue;
  }

  @override
  int get hashCode => colorValue.hashCode;
}

class AppThemes {
  static const AppTheme defaultTheme = AppTheme(
    name: 'Blue',
    primaryColor: Colors.blue,
    secondaryColor: Colors.blueAccent,
    colorValue: 0xFF2196F3,
  );

  static const List<AppTheme> availableThemes = [
    AppTheme(
      name: 'Blue',
      primaryColor: Colors.blue,
      secondaryColor: Colors.blueAccent,
      colorValue: 0xFF2196F3,
    ),
    AppTheme(
      name: 'Purple',
      primaryColor: Colors.purple,
      secondaryColor: Colors.purpleAccent,
      colorValue: 0xFF9C27B0,
    ),
    AppTheme(
      name: 'Green',
      primaryColor: Colors.green,
      secondaryColor: Colors.greenAccent,
      colorValue: 0xFF4CAF50,
    ),
    AppTheme(
      name: 'Orange',
      primaryColor: Colors.orange,
      secondaryColor: Colors.orangeAccent,
      colorValue: 0xFFFF9800,
    ),
    AppTheme(
      name: 'Red',
      primaryColor: Colors.red,
      secondaryColor: Colors.redAccent,
      colorValue: 0xFFF44336,
    ),
    AppTheme(
      name: 'Teal',
      primaryColor: Colors.teal,
      secondaryColor: Colors.tealAccent,
      colorValue: 0xFF009688,
    ),
    AppTheme(
      name: 'Pink',
      primaryColor: Colors.pink,
      secondaryColor: Colors.pinkAccent,
      colorValue: 0xFFE91E63,
    ),
    AppTheme(
      name: 'Indigo',
      primaryColor: Colors.indigo,
      secondaryColor: Colors.indigoAccent,
      colorValue: 0xFF3F51B5,
    ),
  ];

  // Get theme by color value
  static AppTheme getThemeByColor(Color color) {
    return availableThemes.firstWhere(
      (theme) => theme.colorValue == color.value,
      orElse: () => defaultTheme,
    );
  }

  // Generate MaterialApp theme from AppTheme
  static ThemeData generateThemeData(AppTheme appTheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: _createMaterialColor(appTheme.primaryColor),
      primaryColor: appTheme.primaryColor,
      colorScheme: ColorScheme.dark(
        primary: appTheme.primaryColor,
        secondary: appTheme.secondaryColor,
        surface: const Color(0xFF1E1E1E),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: appTheme.primaryColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: appTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: appTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return appTheme.primaryColor;
          }
          return Colors.grey[400];
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return appTheme.primaryColor.withOpacity(0.3);
          }
          return Colors.grey[800];
        }),
      ),
    );
  }

  // Helper method to create MaterialColor from Color
  static MaterialColor _createMaterialColor(Color color) {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (final strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(color.value, swatch);
  }
}
