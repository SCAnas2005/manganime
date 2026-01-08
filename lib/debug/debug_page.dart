import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/anime_sections.dart';
import 'package:flutter_application_1/models/identifiable.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/anime_cache_provider.dart';
import 'package:flutter_application_1/providers/database_provider.dart';
import 'package:flutter_application_1/providers/manga_cache_provider.dart';
import 'package:flutter_application_1/providers/media_path_provider.dart';
import 'package:flutter_application_1/providers/media_sections_provider.dart';
import 'package:flutter_application_1/services/image_sync_service.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    // NIVEAU 1 : DATABASE vs CACHE vs SECTIONS
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Master Debugger 🕷️"),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.storage), text: "DATABASE"),
              Tab(icon: Icon(Icons.memory), text: "CACHE"),
              Tab(icon: Icon(Icons.view_quilt), text: "SECTIONS (HOME)"),
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
            _SectionsTab(), // Onglet 3
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// ONGLET 1 : DATABASE (SQL/HIVE DB BRUTE)
// =============================================================================
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
    // Récupère tout depuis la DB
    final List<I> items = I == Anime
        ? DatabaseProvider.instance.getAllAnime() as List<I>
        : DatabaseProvider.instance.getAllManga() as List<I>;

    if (items.isEmpty) return const Center(child: Text("Table Vide 🤷‍♂️"));

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

// =============================================================================
// ONGLET 2 : CACHE (RAM vs HIVE STOCKAGE)
// =============================================================================
class _CacheTab extends StatelessWidget {
  const _CacheTab();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.orange.shade50,
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
    // Assure-toi d'avoir ajouté les getters 'memoryCache' et 'box' dans tes Providers !
    final memoryMap = T == Anime
        ? AnimeCache.instance.memoryCache
        : MangaCache.instance.memoryCache;

    final hiveBox = T == Anime
        ? AnimeCache.instance.box
        : MangaCache.instance.box;

    return Row(
      children: [
        // --- RAM ---
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
        // --- HIVE ---
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

// =============================================================================
// ONGLET 3 : SECTIONS (Ce qui s'affiche sur la Home)
// =============================================================================
class _SectionsTab extends StatelessWidget {
  const _SectionsTab();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.teal.shade50,
            child: const TabBar(
              labelColor: Colors.teal,
              indicatorColor: Colors.teal,
              tabs: [
                Tab(text: "Anime Sections"),
                Tab(text: "Manga Sections"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Vue pour les sections Animes
                _SectionViewer<AnimeSections, Anime>(
                  values: AnimeSections.values,
                  onLoad: (section) =>
                      MediaSectionsProvider.instance.getAnimes(section),
                  labelBuilder: (section) => section.toString().split('.').last,
                ),
                // Vue pour les sections Mangas
                _SectionViewer<MangaSections, Manga>(
                  values: MangaSections.values,
                  onLoad: (section) =>
                      MediaSectionsProvider.instance.getMangas(section),
                  labelBuilder: (section) => section.toString().split('.').last,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionViewer<E, T extends Identifiable> extends StatefulWidget {
  final List<E> values;
  final Future<List<T>> Function(E section) onLoad;
  final String Function(E section) labelBuilder;

  const _SectionViewer({
    required this.values,
    required this.onLoad,
    required this.labelBuilder,
  });

  @override
  State<_SectionViewer<E, T>> createState() => _SectionViewerState<E, T>();
}

class _SectionViewerState<E, T extends Identifiable>
    extends State<_SectionViewer<E, T>> {
  E? _selectedSection;
  List<T>? _data;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.values.isNotEmpty) {
      _loadSection(widget.values.first);
    }
  }

  Future<void> _loadSection(E section) async {
    setState(() {
      _selectedSection = section;
      _isLoading = true;
      _data = null;
    });

    try {
      final result = await widget.onLoad(section);
      if (mounted) {
        setState(() {
          _data = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Erreur chargement section: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // SÉLECTEUR (CHIPS)
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: widget.values.length,
            itemBuilder: (context, index) {
              final section = widget.values[index];
              final isSelected = section == _selectedSection;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(widget.labelBuilder(section).toUpperCase()),
                  selected: isSelected,
                  selectedColor: Colors.teal.shade200,
                  onSelected: (val) {
                    if (val) _loadSection(section);
                  },
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),
        // LISTE RÉSULTATS
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _data == null || _data!.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inbox, size: 40, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text(
                        "Section vide ou non chargée\n(${_selectedSection.toString().split('.').last})",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _data!.length,
                  itemBuilder: (context, index) {
                    final item = _data![index];
                    return FutureBuilder<File>(
                      future: MediaPathProvider.getLocalFileImage(item),
                      builder: (context, snapshot) {
                        final file = snapshot.data;
                        final exists = file != null && file.existsSync();

                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 60,
                            color: Colors.grey[200],
                            child: exists
                                ? Image.file(file, fit: BoxFit.cover)
                                : const Icon(
                                    Icons.image_not_supported,
                                    size: 16,
                                  ),
                          ),
                          title: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("#${index + 1} • ID: ${item.id}"),
                          dense: true,
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
