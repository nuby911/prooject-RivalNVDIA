import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import '../models/task.dart';

class NotificationService {
	NotificationService._();

	static final NotificationService instance = NotificationService._();

	final FlutterLocalNotificationsPlugin _plugin =
			FlutterLocalNotificationsPlugin();
	bool _initialized = false;

	Future<void> initialize() async {
		if (_initialized) return;

		timezone_data.initializeTimeZones();
		final localTimezone = await FlutterTimezone.getLocalTimezone();
		timezone.setLocalLocation(timezone.getLocation(localTimezone.identifier));

		const initializationSettings = InitializationSettings(
			android: AndroidInitializationSettings('@mipmap/ic_launcher'),
			iOS: DarwinInitializationSettings(),
		);

		await _plugin.initialize(settings: initializationSettings);
		_initialized = true;
	}

	Future<void> requestPermissions() async {
		await initialize();

		final androidPlugin = _plugin
				.resolvePlatformSpecificImplementation<
					AndroidFlutterLocalNotificationsPlugin
				>();
		await androidPlugin?.requestNotificationsPermission();

		final iosPlugin = _plugin
				.resolvePlatformSpecificImplementation<
					IOSFlutterLocalNotificationsPlugin
				>();
		await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
	}

	Future<void> scheduleReminder(Task task) async {
		await initialize();

		final reminderAt = task.reminderAt;
		if (task.isCompleted ||
				reminderAt == null ||
				!reminderAt.isAfter(DateTime.now())) {
			await cancelReminder(task);
			return;
		}

		await _plugin.zonedSchedule(
			id: task.notificationId,
			title: 'Pengingat tugas',
			body: task.title,
			scheduledDate: timezone.TZDateTime.from(reminderAt, timezone.local),
			notificationDetails: const NotificationDetails(
				android: AndroidNotificationDetails(
					'task_reminders',
					'Pengingat tugas',
					channelDescription: 'Notifikasi untuk mengingatkan tugas',
					importance: Importance.high,
					priority: Priority.high,
				),
				iOS: DarwinNotificationDetails(),
			),
			androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
		);
	}

	Future<void> cancelReminder(Task task) async {
		await initialize();
		await _plugin.cancel(id: task.notificationId);
	}

	Future<void> cancelAllReminders() async {
		await initialize();
		await _plugin.cancelAll();
	}
}
