import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/Search.dart';

Widget miniSearchBar(BuildContext context) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Search()),
      );
    },
    child: Icon(Icons.search, color: Colors.grey[600]),
  );
}
