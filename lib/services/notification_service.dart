import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/identifiable.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

/// Service gérant les notifications locales et la planification temporelle.
///
/// Ce service utilise [flutter_local_notifications] pour l'affichage et [timezone]
/// pour garantir que les notifications sont déclenchées à l'heure locale correcte de l'utilisateur.
class NotificationService {
  /// Instance unique (Singleton) du service de notification.
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  /// Plugin principal pour interagir avec les notifications natives.
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialise le service, configure le fuseau horaire local et définit le callback de réponse.
  ///
  /// [onDidReceiveNotificationResponse] : Fonction appelée lorsque l'utilisateur clique sur une notification.
  Future<void> init({
    Function(NotificationResponse reponse)? onDidReceiveNotificationResponse,
  }) async {
    // 1. Initialise les bases de données de fuseaux horaires
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

    // Configuration spécifique à Android (icône de notification)
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

    // Vérifie si l'application a été lancée suite à un clic sur une notification
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

  /// Demande les permissions nécessaires sur Android (Notifications et Alarmes exactes).
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

  /// Planifie une notification unique à une heure précise de la journée.
  ///
  /// La notification se répétera quotidiennement grâce au composant [DateTimeComponents.time].
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
          "daily_recommendation_channel", // Identifiant unique du canal
          "Recommendations quotidiennes", // Nom du canal visible par l'utilisateur
          channelDescription:
              "Reçoit une recommandation d'anime/manga par jour",
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Calcule la prochaine instance temporelle (TZDateTime) pour une heure donnée.
  ///
  /// Si l'heure est déjà passée pour aujourd'hui, planifie pour le lendemain.
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

  /// Annule toutes les notifications programmées.
  Future<void> cancelAll() async {
    flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Méthode spécialisée pour planifier la recommandation d'un média spécifique.
  ///
  /// [identifiable] : L'objet (Anime ou Manga) à recommander.
  /// [date] : La date et l'heure à laquelle la notification doit apparaître.
  Future<void> scheduleDailyRecommendations({
    required int id,
    required String title,
    required String body,
    required Identifiable identifiable,
    required DateTime date,
  }) async {
    // Le payload permet de transmettre le type et l'ID du média pour la navigation au clic
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
      "Notification programmée pour le : $date, média : $identifiable",
    );
  }
}
