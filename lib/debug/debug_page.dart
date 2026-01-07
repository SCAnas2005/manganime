import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/identifiable.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/anime_cache_provider.dart'; // Assure-toi du chemin
import 'package:flutter_application_1/providers/database_provider.dart';
import 'package:flutter_application_1/providers/manga_cache_provider.dart'; // Assure-toi du chemin
import 'package:flutter_application_1/providers/media_path_provider.dart';
import 'package:flutter_application_1/services/image_sync_service.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    // NIVEAU 1 : DATABASE vs CACHE
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Master Debugger 🕷️"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.storage), text: "DATABASE (SQL)"),
              Tab(icon: Icon(Icons.memory), text: "CACHE (RAM/HIVE)"),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.sync),
              tooltip: "Force Process Queue",
              onPressed: () => ImageSyncService.instance.processQueue(),
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            _DatabaseTab(), // Onglet 1
            _CacheTab(), // Onglet 2
          ],
        ),
      ),
    );
  }
}

// ... (Le code de _DatabaseTab et _DebugDatabaseList reste inchangé, comme tu l'as déjà) ...
// Je le remets ici pour que le fichier soit complet si tu copies-colles tout.

class _DatabaseTab extends StatelessWidget {
  const _DatabaseTab();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.blueGrey.shade50,
            child: const TabBar(
              labelColor: Colors.black,
              tabs: [
                Tab(text: "Animes Table"),
                Tab(text: "Mangas Table"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _DebugDatabaseList<Anime>(),
                _DebugDatabaseList<Manga>(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DebugDatabaseList<I extends Identifiable> extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<I> items = I == Anime
        ? DatabaseProvider.instance.getAllAnime() as List<I>
        : DatabaseProvider.instance.getAllManga() as List<I>;

    if (items.isEmpty) return const Center(child: Text("Table SQL Vide 🤷‍♂️"));

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return FutureBuilder<File>(
          future: MediaPathProvider.getLocalFileImage(item),
          builder: (context, snapshot) {
            final file = snapshot.data;
            final bool exists = file != null && file.existsSync();
            final int size = exists ? file.lengthSync() : 0;
            final bool valid = size > 500;

            return ListTile(
              leading: Container(
                width: 50,
                height: 50,
                color: Colors.grey[300],
                child: valid
                    ? Image.file(file!, fit: BoxFit.cover)
                    : const Icon(Icons.broken_image, color: Colors.red),
              ),
              title: Text(
                "[${item.id}] ${item.title}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                valid ? "Fichier OK ($size octets)" : "MANQUANT/CORROMPU ❌",
                style: TextStyle(
                  color: valid ? Colors.green : Colors.red,
                  fontSize: 10,
                ),
              ),
              trailing: valid
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : IconButton(
                      icon: const Icon(Icons.download, color: Colors.blue),
                      onPressed: () {
                        ImageSyncService.instance.addToQueue(item);
                        ImageSyncService.instance.processQueue();
                      },
                    ),
            );
          },
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// ONGLET 2 : VUE CACHE (Mémoire vs Hive) - CORRIGÉ
// -----------------------------------------------------------------------------
class _CacheTab extends StatelessWidget {
  const _CacheTab();

  @override
  Widget build(BuildContext context) {
    // On rajoute un TabController interne pour choisir Anime ou Manga DANS le cache
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors
                .orange
                .shade50, // Couleur différente pour repérer le cache
            child: const TabBar(
              labelColor: Colors.deepOrange,
              tabs: [
                Tab(text: "Anime Cache"),
                Tab(text: "Manga Cache"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // On appelle le widget générique pour chaque type
                _GenericCacheView<Anime>(),
                _GenericCacheView<Manga>(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GenericCacheView<T extends Identifiable> extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 1. Récupération dynamique des données selon le type T
    // NOTE : Assure-toi d'avoir ajouté les getters 'memoryCache' et 'box' dans tes Providers !
    final memoryMap = T == Anime
        ? AnimeCache.instance.memoryCache
        : MangaCache.instance.memoryCache;

    final hiveBox = T == Anime
        ? AnimeCache.instance.box
        : MangaCache.instance.box;

    return Row(
      children: [
        // -------------------------------------------------
        // COLONNE 1 : MÉMOIRE (RAM)
        // -------------------------------------------------
        Expanded(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.orange.shade100,
                width: double.infinity,
                child: Text(
                  "RAM (Mémoire)\n${memoryMap.length} items",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: memoryMap.length,
                  itemBuilder: (context, index) {
                    final id = memoryMap.keys.elementAt(index);
                    final item = memoryMap.values.elementAt(index);
                    return ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      title: Text(
                        "$id",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      leading: const Icon(
                        Icons.flash_on,
                        color: Colors.orange,
                        size: 16,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        const VerticalDivider(width: 1, color: Colors.grey),

        // -------------------------------------------------
        // COLONNE 2 : HIVE (DISQUE)
        // -------------------------------------------------
        Expanded(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.purple.shade100,
                width: double.infinity,
                child: Text(
                  "HIVE (Disque)\n${hiveBox.length} items",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: hiveBox.length,
                  itemBuilder: (context, index) {
                    final key = hiveBox.keyAt(index);
                    final rawData = hiveBox.get(key);
                    String title = "???";

                    // Gestion sécurisée du titre selon le format stocké
                    if (rawData is Identifiable) {
                      title = rawData.title;
                    } else if (rawData is Map) {
                      title = rawData['title'] ?? 'No Title';
                    }

                    return ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      title: Text(
                        "$key",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      leading: const Icon(
                        Icons.save,
                        color: Colors.purple,
                        size: 16,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
