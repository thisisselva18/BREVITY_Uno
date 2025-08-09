import 'package:shared_preferences/shared_preferences.dart';

class TutorialService {
  static const String _tutorialKey = 'tutorialShown';

  static Future<bool> shouldShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_tutorialKey) ?? false);
  }

  static Future<void> completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialKey, true);
  }
}
