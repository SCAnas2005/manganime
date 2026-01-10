// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/identifiable.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/media_path_provider.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ImageSyncService {
  static const String BOX_NAME = "pending_download_queue";
  static final ImageSyncService instance = ImageSyncService._();
  ImageSyncService._();

  final Set<String> _processingKeys = {};

  late Box _queueBox;
  bool _isDownloading = false;

  Future<void> init() async {
    _queueBox = await Hive.openBox(BOX_NAME);
    if (_queueBox.isNotEmpty) processQueue();
  }

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

  Future<void> scheduleDownload<T extends Identifiable>(T item) async {
    if (await NetworkService.isConnected) {
      final file = await MediaPathProvider.downloadFileImage<T>(item);
      if (file != null && await file.exists()) return; // Succès
    }
    await addToQueue(item);
  }

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

        // Check Local
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

        // 3. TÉLÉCHARGEMENT
        File? downloadedFile;
        // ⚡️ OPTIMISATION : On utilise 'item' directement au lieu de refaire fromJson
        if (item is Anime) {
          downloadedFile = await MediaPathProvider.downloadFileImage<Anime>(
            item,
          );
        } else if (item is Manga) {
          downloadedFile = await MediaPathProvider.downloadFileImage<Manga>(
            item,
          );
        }

        // 4. VÉRIFICATION FINALE
        if (downloadedFile != null && await downloadedFile.exists()) {
          final len = await downloadedFile.length();
          if (len > 0) {
            await _queueBox.delete(key);
            // debugPrint("✅ Succès : ${item.id}");
          }
        } else {
          debugPrint("❌ Échec : ${item.id} reste en queue.");
        }
      } catch (e) {
        debugPrint("[ImageSync] Erreur sur $key: $e");
      } finally {
        _processingKeys.remove(key); // Libération du verrou pour cet item
      }

      // Petit délai pour laisser le CPU respirer
      await Future.delayed(const Duration(milliseconds: 50));
    }

    _isDownloading = false;
    debugPrint("🏁 Session terminée. Reste : ${_queueBox.length}");
  }
}
