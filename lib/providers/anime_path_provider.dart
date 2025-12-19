import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class AnimePathProvider {
  static const String ANIME_COVERS_DIR = "anime_covers";

  static Future<Directory> getDirectory() async {
    final dir = await getApplicationCacheDirectory();
    final folder = Directory(path.join(dir.path, ANIME_COVERS_DIR));

    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    return folder;
  }

  static Future<File> getLocalFileImage(Anime anime) async {
    final folder = await getDirectory();
    return File(path.join(folder.path, "${anime.id}.jpg"));
  }

  static Future<File?> _downloadRaw(Anime anime) async {
    try {
      final folder = await getDirectory();
      final targetFile = File(path.join(folder.path, "${anime.id}.jpg"));

      if (await targetFile.exists()) {
        debugPrint("Image for anime ${anime.id} already exists locally.");
        return targetFile;
      }
      final response = await http.get(
        Uri.parse(anime.imageUrl),
        headers: {'User-Agent': 'MangAnime/1.0'},
      );

      if (response.statusCode == 200) {
        // On écrit les données
        await targetFile.writeAsBytes(response.bodyBytes);
        debugPrint("Download image for anime ${anime.id} successful");
        return targetFile;
      } else {
        debugPrint(
          "Download failed for anime ${anime.id} with status ${response.statusCode}",
        );
        return null;
      }
    } catch (e) {
      debugPrint("Error downloading image for anime ${anime.id}: $e");
      return null;
    }
  }

  static Future<File?> downloadFileImage(Anime anime) async {
    if (!await NetworkService.isConnected) {
      debugPrint("Pas d'internet pour télécharger l'image de ${anime.id}");
      return null;
    }

    return await _downloadRaw(anime);
  }

  static Future<void> downloadBatchImages(List<Anime> animes) async {
    if (!await NetworkService.isConnected) {
      debugPrint("Pas d'internet : Batch annulé.");
      return;
    }

    await Future.wait(animes.map((anime) => _downloadRaw(anime)));
  }
}
