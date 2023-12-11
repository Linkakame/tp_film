import 'package:flutter/material.dart';

class FilmListPage extends StatelessWidget {
  final List<dynamic> filmList;

  FilmListPage({required this.filmList});

  

  @override
  Widget build(BuildContext context) {

    void afficherDialogDetails(Map<String, dynamic> filmDetails) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(filmDetails['Title']),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Année: ${filmDetails['Year']}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Films'),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: filmList.length,
          itemBuilder: (context, index) {
            final result = filmList[index];
            return ListTile(
              title: Container(
                child: GestureDetector(
                  onTap: () {
                    afficherDialogDetails(result);
                  },
                  child: Column(
                    children: [
                      Text(result["Title"]),
                      Container(
                        height: 120,
                        child: Image.network(result['Poster']),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
