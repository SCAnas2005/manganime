import 'package:flutter/material.dart';
import 'package:flutter/material.dart' show SearchAnchor, SearchController, SearchBar;

class Search extends StatefulWidget {
    @override 
    State<Search> createState() => _SearchState();

}

class _SearchState extends State<Search> {

   
@override 
Widget build (BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Karim")),
        body: Center(
                child: SearchAnchor(
                    builder: (BuildContext context, SearchController controller){
                        return SearchBar(
                            controller: controller,
                            hintText: "Rechercher un anime",
                            onChanged: (_){controller.openView();
                            },

                        );
                    },
                    suggestionsBuilder: (BuildContext context, SearchController controller){
                        return <Widget>[];
                    }
                )
        )
    );
}
}
