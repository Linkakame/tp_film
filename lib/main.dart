import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'filmlistepage.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Omdb Demo pour prépa TP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'Flutter Demo JSON API FROM OMDB'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  late List<dynamic> results = [];
  late Map<String, dynamic> filmAccueil;
  bool dataOK = false;
  TextEditingController searchController = TextEditingController();
  late String recherchefilm = "";

  @override
  void initState() {
    super.initState();
    // Chargez les détails du film d'accueil lors de l'initialisation
    recupFilmAccueil();
  }

  Future<void> recupFilmAccueil() async {
    Uri uri = Uri.http(
        'www.omdbapi.com', '', {'i': 'tt0086190', 'apikey': 'db0bdb23'});
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      setState(() {
        filmAccueil = convert.jsonDecode(response.body);
        dataOK = true;
      });
    } else {
      print(
          "Erreur lors de la récupération du film d'accueil. Statut : ${response.statusCode}");
      print("Réponse du serveur : ${response.body}");
    }
  }

  Future<void> recupFilm(String keyword) async {
    Uri uri =
        Uri.http('www.omdbapi.com', '', {'s': keyword, 'apikey': 'db0bdb23'});
    http.Response response = await http.get(uri);
    print("Response for $keyword: ${response.body}");

    if (response.statusCode == 200) {
      var responseData = convert.jsonDecode(response.body);
      setState(() {
        dataOK = true;
        results = responseData['Search'];
      });
    } else {
      setState(() {
        dataOK = false;
        results = [];
      });
      print("Erreur lors de la recherche. Statut : ${response.statusCode}");
      print("Réponse du serveur : ${response.body}");
      // Gérer les erreurs ici
    }
  }

  Widget attente() {
    // Ajoutez cette ligne

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: 10),
        const SizedBox(height: 20),
        const Text('En attente des données',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold)),
        CircularProgressIndicator(
          color: Colors.deepOrange,
          strokeCap: StrokeCap.round,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
      ),
      body: dataOK ? affichage() : attente(),
      backgroundColor: Colors.blueGrey[900],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          recupFilm(searchController.text);
        },
        tooltip: 'Rechercher',
        child: IconButton(
            onPressed: () async {
              await recupFilm(searchController.text);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FilmListPage(filmList: results),
                ),
              );
            },
            icon: Icon(Icons.search)),
      ),
    );
  }

  Widget affichage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextField(
          controller: searchController, // Utilisez le contrôleur distinct
          decoration: const InputDecoration(
            labelText: 'Rechercher un film',
            border: OutlineInputBorder(),
          ),
        ),
        ListTile(
          title: Column(
            children: [
              Text(filmAccueil['Title']),
              Container(
                height: 120,
                child: Image.network(filmAccueil['Poster']),
              ),
            ],
          ),
          subtitle: Text(filmAccueil['Year']),
          onTap: () {
            afficherDetails(filmAccueil['imdbID']);
          },
        ),
      ],
    );
  }

  void afficherDetails(String imdbID) async {
    Uri uri =
        Uri.http('www.omdbapi.com', '', {'i': imdbID, 'apikey': 'db0bdb23'});
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      var filmDetails = convert.jsonDecode(response.body);
      _afficherDialogDetails(filmDetails);
    } else {
      print(
          "Erreur lors de la récupération des détails du film. Statut : ${response.statusCode}");
      print("Réponse du serveur : ${response.body}");
    }
  }

  void _afficherDialogDetails(Map<String, dynamic> filmDetails) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(filmDetails['Title']),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Année: ${filmDetails['Year']}'),
              Text('Genre: ${filmDetails['Genre']}'),
              Text('Réalisé par: ${filmDetails['Director']}'),
              Text('Acteurs: ${filmDetails['Actors']}'),
              Text('Synopsis: ${filmDetails['Plot']}'),
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
}
