import 'package:flutter/material.dart';
import 'package:flutter/material.dart' show SearchAnchor, SearchController, SearchBar;
import 'package:flutter_application_1/widgets/anime_card.dart';
import 'package:flutter_application_1/viewmodels/search_view_model.dart';
import 'package:flutter_application_1/viewmodels/anime_view_model.dart';
import 'package:provider/provider.dart';

class Search extends StatefulWidget {
     
    @override 
    State<Search> createState() => _SearchState();

}

class _SearchState extends State<Search> {
    int index = 0;


    @override
    void initState() {
        super.initState();
        Future.microtask(() {
            final searchViewModel = context.read<SearchViewModel>();
            searchViewModel.searchEmpty("");
        });
    }

   
@override 
Widget build (BuildContext context) {
    final vm = context.watch<AnimeViewModel>();
    final searchViewModel = context.watch<SearchViewModel>();
    final suggestions = searchViewModel.results;

    if (suggestions.isNotEmpty){
        index = index % suggestions.length;
    }
    
    return Scaffold(
        appBar: AppBar(title: Text("Karim")),
        body: Column(
                children: [    
                    Padding(

                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),   
                            child: SearchBar(
                            hintText: "Rechercher un anime",
                            onChanged: (text)  {
                                    if (text.isNotEmpty){
                                        searchViewModel.search(text);
                                        }
                                    else {
                                        searchViewModel.searchEmpty(text);
                                         }
                        },

                        ),
                    ),
            
                
                  
           

       
                  
          const SizedBox(height: 10),

         
          if (suggestions.isNotEmpty)
            Expanded(
               
                   child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,        
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1,     
               ),
           

                itemCount: suggestions.length,
                itemBuilder: (context, i) {
                  final anime = suggestions[i];
                  return GestureDetector(
                    onTap: () => vm.openAnimePage(context, anime),
                    child: AnimeCard(
                      anime: anime,
                      onTap: (anime) => vm.openAnimePage(context, anime),
                    ),
                  );
                },
            ),
                ),
            
        ],
     
    )
    );
  }
}
