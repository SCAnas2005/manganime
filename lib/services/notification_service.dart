import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/identifiable.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
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
  final enableNotifications = true;
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
    if (!enableNotifications) return;
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
        AndroidInitializationSettings("@mipmap/ic_launcher");

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

  /// Demande la permission intelligemment.
  /// Retourne TRUE si c'est bon, FALSE si c'est bloqué.
  Future<bool> checkAndRequestPermission(BuildContext context) async {
    if (!enableNotifications) return false;
    PermissionStatus status = await Permission.notification.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      // Cas 1 : C'est la première fois, ou l'utilisateur a dit "Non" une fois.
      // On affiche la pop-up système Android.
      status = await Permission.notification.request();
    }

    if (status.isPermanentlyDenied || status.isDenied) {
      // Cas 2 : L'utilisateur a bloqué les notifs dans les réglages (ton cas actuel).
      // La pop-up système ne s'affichera PLUS. Il faut guider l'utilisateur.

      if (context.mounted) {
        _showSettingsDialog(context);
      }
      return false;
    }

    return status.isGranted;
  }

  /// Affiche une alerte pour expliquer pourquoi on a besoin des notifs
  /// et propose un bouton pour ouvrir les réglages.
  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Notifications bloquées"),
        content: const Text(
          "Pour recevoir les recommandations quotidiennes, vous devez autoriser les notifications dans les paramètres.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text(
              "Ouvrir les réglages",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
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
    if (!enableNotifications) return;
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "daily_recommendation_channel_v2", // Identifiant unique du canal
          "Recommendations quotidiennes", // Nom du canal visible par l'utilisateur
          channelDescription:
              "Reçoit une recommandation d'anime/manga par jour",
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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
    if (!enableNotifications) return;
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
