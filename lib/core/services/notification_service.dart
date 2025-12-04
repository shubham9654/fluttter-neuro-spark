import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Notification Service
/// Handles push notifications for tasks and reminders
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Request notification permissions
      await requestPermissions();
      _initialized = true;
      debugPrint('✅ Notification service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
    }
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
      // TODO: Implement actual notification scheduling
      // This will be implemented with flutter_local_notifications
      debugPrint('📅 Scheduled reminder for task: $taskTitle at $scheduledTime');
    } catch (e) {
      debugPrint('❌ Error scheduling reminder: $e');
    }
  }

  /// Send immediate notification
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
      // TODO: Implement actual notification
      debugPrint('🔔 Notification: $title - $body');
    } catch (e) {
      debugPrint('❌ Error sending notification: $e');
    }
  }

  /// Cancel a scheduled notification
  Future<void> cancelNotification(String notificationId) async {
    try {
      // TODO: Implement notification cancellation
      debugPrint('🚫 Cancelled notification: $notificationId');
    } catch (e) {
      debugPrint('❌ Error cancelling notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      // TODO: Implement cancel all
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

