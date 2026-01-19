// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/identifiable.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/media_path_provider.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Service responsable de la synchronisation et du téléchargement des images de couverture.
///
/// Il utilise une file d'attente persistante (Hive) pour garantir que les images
/// sont téléchargées même si la connexion est perdue puis retrouvée.
class ImageSyncService {
  /// Nom de la boîte Hive stockant les téléchargements en attente.
  static const String BOX_NAME = "pending_download_queue";
  static final ImageSyncService instance = ImageSyncService._();
  ImageSyncService._();

  /// Verrou de sécurité pour éviter de traiter deux fois le même item simultanément.
  final Set<String> _processingKeys = {};

  late Box _queueBox;

  /// État du service pour éviter de lancer plusieurs boucles de traitement en parallèle.
  bool _isDownloading = false;

  /// Initialise le service et ouvre la boîte de stockage de la file d'attente.
  Future<void> init() async {
    _queueBox = await Hive.openBox(BOX_NAME);
    if (_queueBox.isNotEmpty) processQueue();
  }

  /// Ajoute un élément ([Anime] ou [Manga]) à la file d'attente de téléchargement.
  Future<void> addToQueue(Identifiable item) async {
    String typeStr;
    if (item is Anime) {
      typeStr = "Anime";
    } else if (item is Manga)
      // ignore: curly_braces_in_flow_control_structures
      typeStr = "Manga";
    else {
      return;
    }
    final key = "${typeStr}_${item.id}";
    await _queueBox.put(key, {"type": typeStr, "data": item.toJson()});
  }

  /// Tente de télécharger l'image immédiatement ou l'ajoute à la file en cas d'échec/absence de réseau.
  Future<void> scheduleDownload<T extends Identifiable>(T item) async {
    if (await NetworkService.isConnected) {
      final file = await MediaPathProvider.downloadFileImage<T>(item);
      if (file != null && await file.exists()) return; // Succès
    }
    await addToQueue(item);
  }

  /// Parcourt la file d'attente et tente de télécharger les images stockées.
  ///
  /// Cette méthode s'arrête si la connexion est perdue et gère le nettoyage
  /// des fichiers corrompus ou vides.
  Future<void> processQueue() async {
    // 1. Verrouillage de la méthode elle-même
    if (_isDownloading) return;
    if (!await NetworkService.isConnected) return;

    _isDownloading = true;

    // On prend un instantané des clés actuelles
    final keys = _queueBox.keys.map((e) => e.toString()).toList();

    debugPrint("[ImageSync] Démarrage de la file (${keys.length} items)");

    for (var key in keys) {
      // 2. Verrouillage par item : Si cet ID est déjà en cours de téléchargement par une autre tâche, on saute
      if (_processingKeys.contains(key)) continue;
      final entry = _queueBox.get(key);
      if (entry == null) continue;

      try {
        _processingKeys.add(key); // On marque comme "en cours"

        final typeStr = entry["type"];
        final data = Map<String, dynamic>.from(entry["data"]);
        File? localFile;
        // Reconstruction de l'objet
        Identifiable item;
        if (typeStr == 'Anime') {
          item = Anime.fromJson(data);
          localFile = await MediaPathProvider.getLocalFileImage<Anime>(
            item as Anime,
          );
        } else if (typeStr == 'Manga') {
          item = Manga.fromJson(data);
          localFile = await MediaPathProvider.getLocalFileImage<Manga>(
            item as Manga,
          );
        } else {
          await _queueBox.delete(key);
          continue;
        }

        // Vérification de l'existence locale pour éviter les téléchargements inutiles
        if (await localFile.exists()) {
          if (await localFile.length() > 0) {
            await _queueBox.delete(key);
            continue;
          } else {
            await localFile.delete(); // Nettoyage fichier vide
          }
        }

        // Check Internet (avant chaque download)
        if (!await NetworkService.isConnected) break;

        File? downloadedFile;
        if (item is Anime) {
          downloadedFile = await MediaPathProvider.downloadFileImage<Anime>(
            item,
          );
        } else if (item is Manga) {
          downloadedFile = await MediaPathProvider.downloadFileImage<Manga>(
            item,
          );
        }

        if (downloadedFile != null && await downloadedFile.exists()) {
          final len = await downloadedFile.length();
          if (len > 0) {
            await _queueBox.delete(key);
          }
        } else {
          debugPrint("[ImageSync] Echec : ${item.id} reste en queue.");
        }
      } catch (e) {
        debugPrint("[ImageSync] Erreur sur $key: $e");
      } finally {
        _processingKeys.remove(key);
      }

      // Petit délai pour laisser le CPU respirer et éviter de bloquer l'UI thread
      await Future.delayed(const Duration(milliseconds: 50));
    }

    _isDownloading = false;
  }
}
