import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Karim")),
      body: Center(
        child: SearchAnchor(
          builder: (BuildContext context, SearchController controller) {
            return SearchBar(
              controller: controller,
              hintText: "Rechercher un anime",
              onChanged: (text) {
                controller.openView();
              },
            );
          },
          suggestionsBuilder:
              (BuildContext context, SearchController controller) {
                return <Widget>[];
              },
        ),
      ),
    );
  }
}
