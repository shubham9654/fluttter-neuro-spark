import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

/// Notification Service
/// Handles push notifications for tasks and reminders
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Request notification permissions
      await requestPermissions();

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Initialization settings
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize plugin
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create notification channel for Android
      if (!kIsWeb) {
        await _createNotificationChannel();
      }

      _initialized = true;
      debugPrint('✅ Notification service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
    }
  }

  /// Create Android notification channel
  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      'neurospark_tasks', // id
      'Task Notifications', // name
      description: 'Notifications for task creation and reminders',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Navigate to specific task or screen based on payload
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      // Check current permission status
      var status = await Permission.notification.status;

      if (status.isDenied) {
        // Request permission
        status = await Permission.notification.request();
      }

      if (status.isGranted) {
        debugPrint('✅ Notification permission granted');
        return true;
      } else if (status.isPermanentlyDenied) {
        debugPrint('⚠️ Notification permission permanently denied');
        // Open app settings
        await openAppSettings();
        return false;
      } else {
        debugPrint('⚠️ Notification permission denied');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error requesting notification permission: $e');
      return false;
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('Error checking notification status: $e');
      return false;
    }
  }

  /// Schedule a task reminder
  Future<void> scheduleTaskReminder({
    required String taskId,
    required String taskTitle,
    required DateTime scheduledTime,
  }) async {
    if (!_initialized) await initialize();

    final isEnabled = await areNotificationsEnabled();
    if (!isEnabled) {
      debugPrint('⚠️ Notifications not enabled, skipping reminder');
      return;
    }

    try {
      final tzLocation = tz.getLocation('America/New_York'); // Default timezone
      final scheduledDate = tz.TZDateTime.from(scheduledTime, tzLocation);

      const androidDetails = AndroidNotificationDetails(
        'neurospark_tasks',
        'Task Notifications',
        channelDescription: 'Notifications for task creation and reminders',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        taskId.hashCode,
        'Task Reminder',
        taskTitle,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: taskId,
      );

      debugPrint('📅 Scheduled reminder for task: $taskTitle at $scheduledTime');
    } catch (e) {
      debugPrint('❌ Error scheduling reminder: $e');
    }
  }

  /// Send immediate notification (for task creation)
  Future<void> sendNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    final isEnabled = await areNotificationsEnabled();
    if (!isEnabled) {
      debugPrint('⚠️ Notifications not enabled');
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'neurospark_tasks',
        'Task Notifications',
        channelDescription: 'Notifications for task creation and reminders',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch % 100000,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      debugPrint('🔔 Notification sent: $title - $body');
    } catch (e) {
      debugPrint('❌ Error sending notification: $e');
    }
  }

  /// Send notification when task is created
  Future<void> notifyTaskCreated({
    required String taskTitle,
    String? taskId,
  }) async {
    await sendNotification(
      title: '✅ Task Created',
      body: taskTitle,
      payload: taskId,
    );
  }

  /// Cancel a scheduled notification
  Future<void> cancelNotification(String notificationId) async {
    try {
      await _notifications.cancel(notificationId.hashCode);
      debugPrint('🚫 Cancelled notification: $notificationId');
    } catch (e) {
      debugPrint('❌ Error cancelling notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      debugPrint('🚫 Cancelled all notifications');
    } catch (e) {
      debugPrint('❌ Error cancelling all notifications: $e');
    }
  }

  /// Show notification settings
  Future<void> openNotificationSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      debugPrint('❌ Error opening settings: $e');
    }
  }
}

/// Provider for notification service
final notificationService = NotificationService();
