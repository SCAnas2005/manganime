// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/identifiable.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class MediaPathProvider {
  static const String ANIME_COVERS_DIR = "anime_covers";
  static const String MANGA_COVERS_DIR = "manga_covers";

  static String getDirByType<T extends Identifiable>() {
    if (T == Anime) return ANIME_COVERS_DIR;
    if (T == Manga) return MANGA_COVERS_DIR;

    throw Exception(
      "[MediaPathProvider] getdirByType<$T>(): Unsupported type $T",
    );
  }

  static Future<Directory> getDirectory<T extends Identifiable>() async {
    final dir = await getApplicationCacheDirectory();
    final dirName = getDirByType<T>();
    final folder = Directory(path.join(dir.path, dirName));

    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    return folder;
  }

  static Future<File> getLocalFileImage<T extends Identifiable>(
    T identifiable,
  ) async {
    final folder = await getDirectory<T>();
    return File(path.join(folder.path, "${identifiable.id}.jpg"));
  }

  static Future<File?> _downloadRaw<T extends Identifiable>(
    T identfiable,
  ) async {
    try {
      final folder = await getDirectory<T>();
      final targetFile = File(path.join(folder.path, "${identfiable.id}.jpg"));

      if (await targetFile.exists()) {
        debugPrint("Image for $T ${identfiable.id} already exists locally.");
        return targetFile;
      }
      final response = await http.get(
        Uri.parse(identfiable.imageUrl),
        headers: {'User-Agent': 'MangAnime/1.0'},
      );

      if (response.statusCode == HttpStatus.ok) {
        // On écrit les données
        await targetFile.writeAsBytes(response.bodyBytes);
        debugPrint(
          "[MediaPathProvider] _downloadRaw<$T>(): Download image for $T ${identfiable.id} successful",
        );
        return targetFile;
      } else {
        debugPrint(
          "[MediaPathProvider] _downloadRaw<$T>(): Download failed for $T ${identfiable.id} with status ${response.statusCode}",
        );
        return null;
      }
    } catch (e) {
      debugPrint(
        "[MediaPathProvider] _downloadRaw<$T>(): Error downloading image for $T ${identfiable.id}: $e",
      );
      return null;
    }
  }

  static Future<File?> downloadFileImage<T extends Identifiable>(
    T identifiable,
  ) async {
    if (!await NetworkService.isConnected) {
      debugPrint(
        "[MediaPathProvider] downloadFileImage<$T>(): Pas d'internet pour télécharger l'image de $T ${identifiable.id}",
      );
      return null;
    }

    return await _downloadRaw<T>(identifiable);
  }

  static Future<void> downloadBatchImages<T extends Identifiable>(
    List<T> identifiables,
  ) async {
    if (!await NetworkService.isConnected) {
      debugPrint(
        "[MediaPathProvider] downloadBatchImages<$T>(): Pas d'internet : Batch annulé.",
      );
      return;
    }

    await Future.wait(
      identifiables.map((identfiable) => _downloadRaw<T>(identfiable)),
    );
  }
}
