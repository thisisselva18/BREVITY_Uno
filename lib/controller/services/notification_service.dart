import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brevity/utils/logger.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'bookmark_services.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static const String _reminderEnabledKey = 'bookmark_reminder_enabled';
  static const String _reminderTimeKey = 'bookmark_reminder_time';
  static const int _bookmarkReminderId = 1;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      // Set local timezone (you may need to adjust this based on your needs)
      final String timeZoneName = await _getDeviceTimeZone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      // Android initialization with proper settings
      const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization (if you plan to support iOS)
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final bool? initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized == true) {
        _isInitialized = true;
        Log.d('Notification service initialized successfully');

        // Create notification channel for Android
        await _createNotificationChannel();
      } else {
        Log.e('Failed to initialize notification service');
      }
    } catch (e) {
      Log.e('Error initializing notifications: $e');
    }
  }

  Future<String> _getDeviceTimeZone() async {
    try {
      // You might want to use a package like device_info_plus to get actual timezone
      // For now, using a common default
      return 'Asia/Kolkata'; // Adjust based on your target audience
    } catch (e) {
      return 'UTC'; // Fallback
    }
  }

  Future<void> _createNotificationChannel() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'bookmark_reminder',
            'Bookmark Reminders',
            description: 'Daily reminders to check your bookmarked articles',
            importance: Importance.high,
            enableVibration: true,
            playSound: true,
          ),
        );

        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'test_channel',
            'Test Notifications',
            description: 'Test notification channel',
            importance: Importance.high,
          ),
        );
      }
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to bookmarks screen
    Log.d('Notification tapped: ${response.payload}');
    // Add your navigation logic here if needed
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        // Request notification permission (Android 13+)
        final bool? granted = await androidPlugin.requestNotificationsPermission();

        // Request exact alarm permission (Android 12+)
        final bool? exactAlarmGranted = await androidPlugin.requestExactAlarmsPermission();

        Log.d('Notification permission: $granted, Exact alarm permission: $exactAlarmGranted');

        return granted ?? false;
      }
    } else if (Platform.isIOS) {
      final bool? result = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }

    return true; // For other platforms
  }

  Future<bool> isReminderEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_reminderEnabledKey) ?? false;
    } catch (e) {
      Log.e('Error getting reminder enabled status: $e');
      return false;
    }
  }

  Future<void> setReminderEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_reminderEnabledKey, enabled);

      if (enabled) {
        await _scheduleBookmarkReminder(true);
      } else {
        await _cancelBookmarkReminder();
      }
    } catch (e) {
      Log.e('Error setting reminder enabled: $e');
    }
  }

  Future<String> getReminderTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_reminderTimeKey) ?? '09:00';
    } catch (e) {
      Log.e('Error getting reminder time: $e');
      return '09:00';
    }
  }

  Future<void> setReminderTime(String time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_reminderTimeKey, time);

      // Reschedule if reminder is enabled
      if (await isReminderEnabled()) {
        await _scheduleBookmarkReminder();
      }
    } catch (e) {
      Log.e('Error setting reminder time: $e');
    }
  }

  Future<void> _scheduleBookmarkReminder([bool allowSameDay = false]) async {
    try {
      // Ensure we're initialized
      if (!_isInitialized) {
        await initialize();
      }

      // Cancel existing reminder first
      await _notifications.cancel(_bookmarkReminderId);

      // Check if user has bookmarks
      final bookmarkService = BookmarkServices();
      await bookmarkService.initialize();
      final bookmarks = await bookmarkService.getBookmarks();

      if (bookmarks.isEmpty) {
        Log.d('No bookmarks found, skipping reminder scheduling');
        return;
      }

      final timeString = await getReminderTime();
      final timeParts = timeString.split(':');

      if (timeParts.length != 2) {
        Log.e('Invalid time format: $timeString');
        return;
      }

      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);

      if (hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        Log.e('Invalid hour or minute: $hour:$minute');
        return;
      }

      final now = tz.TZDateTime.now(tz.local);
      var scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If the scheduled time has passed today, schedule for tomorrow
      if (scheduledTime.isBefore(now.add(const Duration(minutes: 1))) && !allowSameDay) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'bookmark_reminder',
        'Bookmark Reminders',
        channelDescription: 'Daily reminders to check your bookmarked articles',
        importance: Importance.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
        autoCancel: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        _bookmarkReminderId,
        'Time to catch up! 📚',
        'You have ${bookmarks.length} bookmarked article${bookmarks.length == 1 ? '' : 's'} waiting to be read.',
        scheduledTime,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'bookmark_reminder',
      );

      Log.d('Bookmark reminder scheduled for ${scheduledTime.toString()}');
    } catch (e) {
      Log.e('Error scheduling bookmark reminder: $e');
    }
  }

  Future<void> _cancelBookmarkReminder() async {
    try {
      await _notifications.cancel(_bookmarkReminderId);
      Log.d('Bookmark reminder cancelled');
    } catch (e) {
      Log.e('Error cancelling bookmark reminder: $e');
    }
  }

  // Call this method when bookmarks are added/removed to update the reminder
  Future<void> updateBookmarkReminder() async {
    if (await isReminderEnabled()) {
      await _scheduleBookmarkReminder();
    }
  }

  Future<void> showTestNotification() async {
    try {
      // Ensure we're initialized
      if (!_isInitialized) {
        await initialize();
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Test notification channel',
        importance: Importance.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
        autoCancel: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        999,
        'Test Notification 🔔',
        'This is a test notification to verify everything is working!',
        platformDetails,
        payload: 'test',
      );

      Log.d('Test notification sent');
    } catch (e) {
      Log.e('Error showing test notification: $e');
    }
  }

  // Helper method to check if notifications are enabled at system level
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        return await androidPlugin.areNotificationsEnabled() ?? false;
      }
    }
    return true;
  }

  // Get list of pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
