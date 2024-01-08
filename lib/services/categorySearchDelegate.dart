import 'package:design_project_1/screens/patientInterface/BookAppointment/doctorsListPage.dart';
import 'package:flutter/material.dart';

class CategorySearchDelegate extends SearchDelegate<String> {
  final List<String> specializations; // List of all specializations

  CategorySearchDelegate({required this.specializations});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(query);
  }

  Widget _buildSearchResults(String query) {
    final List<String> filteredSpecializations = specializations
        .where((category) => category.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredSpecializations.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(filteredSpecializations[index]),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorsListPage(selectedCategory: filteredSpecializations[index]),
              ),
            );
          },
        );
      },
    );
  }

}
