import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/viewmodels/anime_view_model.dart';
import 'package:flutter_application_1/widgets/Search.dart';
import 'package:flutter_application_1/viewmodels/search_view_model.dart';

Widget miniSearchBar(BuildContext context) {
  return InkWell(
    onTap: () {
      final vm = context.read<AnimeViewModel>();
      final searchViewModel = context.read<SearchViewModel>();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: vm),
              ChangeNotifierProvider.value(value: searchViewModel),
            ],
            child: Search(),
          ),
        ),
      );
    },
    child: Icon(Icons.search, color: Colors.grey[600]),
  );
}
