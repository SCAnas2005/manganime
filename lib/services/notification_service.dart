import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/identifiable.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init({
    Function(NotificationResponse reponse)? onDidReceiveNotificationResponse,
  }) async {
    // 1. Initialize les time zones;
    tz.initializeTimeZones();

    final TimezoneInfo timeZoneInfo = await FlutterTimezone.getLocalTimezone();

    try {
      final location = getLocation(timeZoneInfo.identifier);
      tz.setLocalLocation(location);
    } catch (e) {
      debugPrint(
        "Erreur fuseau horaire '${timeZoneInfo.identifier}', fallback sur UTC",
      );
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("@drawable/app_icon");

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onDidReceiveNotificationResponse?.call(response);
      },
    );

    final NotificationAppLaunchDetails? details =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (details != null &&
        details.didNotificationLaunchApp &&
        details.notificationResponse != null) {
      if (onDidReceiveNotificationResponse != null) {
        onDidReceiveNotificationResponse(details.notificationResponse!);
      }
    }
  }

  Future<void> requestPermission() async {
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
    required TimeOfDay time,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "daily_recommendation_channel", // Id du channel
          "Recommendations quotidiennes", // Nom visible par le user,
          channelDescription:
              "Recoit une recommendation d'anime/manga par jour",
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    debugPrint("---------------- DEBUG NOTIF ----------------");
    debugPrint("1. Il est actuellement (Local) : $now");
    debugPrint("2. Je planifie pour          : $scheduledDate");
    debugPrint(
      "3. Différence en minutes     : ${scheduledDate.difference(now).inMinutes}",
    );
    debugPrint("---------------------------------------------");

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelAll() async {
    flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> scheduleDailyRecommendations({
    required int id,
    required String title,
    required String body,
    required Identifiable identifiable,
    required DateTime date,
  }) async {
    String payload =
        "${identifiable is Anime ? "anime" : "manga"}:${identifiable.id}";
    await scheduleNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
      time: TimeOfDay.fromDateTime(date),
    );

    debugPrint(
      "Notification scheduled for date : $date, identifiable : $identifiable",
    );
  }
}
