import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchBarDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          // Close the search bar
          close(context, '');
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.search),
      onPressed: () {
        // the search bar will expand automatically
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Handle search results here
    return Container();
  }


  @override
  Widget buildSuggestions(BuildContext context) {
    final List<String> items = ['Neurologist', 'Pediatrician', 'Dermatologist', 'Oncologist', 'Psychiatrist'];

    return ListView(
      children: items.map((String item) {
        return ListTile(
          title: Text(item),
          onTap: () {
            query = item; // Set the query to the selected item
            close(context, item); // Close the search bar with the selected item as the result
          },
        );
      }).toList(),
    );
  }

}
