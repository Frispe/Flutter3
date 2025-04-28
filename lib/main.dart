import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'hive_helper.dart';
import 'movie.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveHelper.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Любимые фильмы',
      home: MovieListScreen(),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDark);
  }

  @override
  Widget build(BuildContext context) {
    final moviesBox = HiveHelper.getMoviesBox();
    return MaterialApp( 
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Любимые фильмы'),
        ),
        body: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Название'),
            ),
            TextField(
              controller: _yearController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Год'),
            ),
            TextField(
              controller: _genreController,
              decoration: InputDecoration(labelText: 'Жанр'),
            ),
            ElevatedButton(
              onPressed: () async {
                final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _imageFile = File(pickedFile.path);
                  });
                  final appDir = await getApplicationDocumentsDirectory();
                  final imagePath = '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
                  await _imageFile!.copy(imagePath);
                }
              },
              child: Text('Выбрать картинку'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty &&
                    _yearController.text.isNotEmpty &&
                    _genreController.text.isNotEmpty) {
                  moviesBox.add(Movie(
                    title: _titleController.text,
                    year: int.parse(_yearController.text),
                    genre: _genreController.text,
                    imagePath: _imageFile != null ? _imageFile!.path : null,
                  ));
                  _titleController.clear();
                  _yearController.clear();
                  _genreController.clear();
                  setState(() {});
                }
              },
              child: Text('Добавить фильм'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: moviesBox.length,
                itemBuilder: (context, index) {
                  final movie = moviesBox.getAt(index)!;
                  return ListTile(
                    leading: movie.imagePath != null
                        ? Image.file(File(movie.imagePath!))
                        : null,
                    title: Text(movie.title),
                    subtitle: Text('${movie.year} - ${movie.genre}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        moviesBox.deleteAt(index);
                        setState(() {});
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _isDarkMode = !_isDarkMode;
              _saveTheme(_isDarkMode);
            });
          },
          child: Icon(_isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
        ),
      ),
    );
  }
}
