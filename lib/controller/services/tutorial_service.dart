import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
class TutorialService {
  static const String _tutorialKey = 'tutorialShown';

  static Future<bool> shouldShowTutorial() async {
  developer.log('TUTORIAL_SERVICE shouldShowTutorial called',
    name:'TUTORIAL_SERVICE');

    final prefs = await SharedPreferences.getInstance();
    final result= !(prefs.getBool(_tutorialKey) ?? false);

    developer.log(
        'TUTORIAL_SERVICE shouldShowTutorial result: $result (isTutorialCompleted=${!result})',
            name: 'TUTORIAL_SERVICE',
            );
     return result;

  }

  static Future<void> completeTutorial() async {
  developer.log('TUTORIAL_SERVICE completeTutorial called',
      name:'TUTORIAL_SERVICE');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialKey, true);

    developer.log('TUTORIAL_SERVICE Tutorial marked as completed',
        name:'TUTORIAL_SERVICE');
  }
}
