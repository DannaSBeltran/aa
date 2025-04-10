import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class Movie {
  final String title;
  final String year;
  final String imdbID;
  final String poster;

  Movie({
    required this.title,
    required this.year,
    required this.imdbID,
    required this.poster,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['Title'] ?? 'No Title',
      year: json['Year'] ?? 'N/A',
      imdbID: json['imdbID'] ?? '',
      poster: json['Poster'] != 'N/A' ? json['Poster'] : '',
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OMDb Movie cars',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: MovieSearchScreen(),
    );
  }
}

class MovieSearchScreen extends StatefulWidget {
  @override
  _MovieSearchScreenState createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  final String apiKey = '92ac1408';
  List<Movie> movies = [];
  bool isLoading = false;
  final TextEditingController controller = TextEditingController();

  Future<void> searchMovies(String keyword) async {
    setState(() => isLoading = true);

    final url =
        'https://www.omdbapi.com/?s=${Uri.encodeComponent(keyword)}&apikey=$apiKey';

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    if (data['Response'] == 'True') {
      final List results = data['Search'];
      setState(() {
        movies = results.map((json) => Movie.fromJson(json)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        movies = [];
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se encontraron resultados')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Buscar Películas')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Buscar por palabra clave',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => searchMovies(controller.text),
                ),
              ),
            ),
            SizedBox(height: 10),
            isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return Card(
                          child: ListTile(
                            leading: movie.poster.isNotEmpty
                                ? Image.network(movie.poster, width: 50)
                                : Icon(Icons.movie),
                            title: Text(movie.title),
                            subtitle: Text(movie.year),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
