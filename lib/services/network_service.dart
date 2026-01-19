import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Service utilitaire permettant de vérifier
/// la disponibilité d'une connexion Internet.
///
/// Il s'appuie sur le package `internet_connection_checker_plus`
/// pour déterminer si l'application a réellement accès à Internet.
class NetworkService {
  /// Indique si l'appareil dispose actuellement
  /// d'un accès Internet fonctionnel.
  ///
  /// Retourne `true` si une connexion active est détectée,
  /// sinon `false`.
  static Future<bool> get isConnected async {
    return InternetConnection().hasInternetAccess;
  }
}
