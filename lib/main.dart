import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'hive_helper.dart';
import 'movie.dart';
import 'movie_cubit.dart';
import 'theme_cubit.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveHelper.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(create: (context) => MovieCubit()),
      ],
      child: BlocBuilder<ThemeCubit, bool>(
        builder: (context, isDark) {
          return MaterialApp(
            title: 'Любимые фильмы',
            theme: isDark ? ThemeData.dark() : ThemeData.light(),
            home: MovieListScreen(),
          );
        },
      ),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                context.read<MovieCubit>().addMovie(Movie(
                  title: _titleController.text,
                  year: int.parse(_yearController.text),
                  genre: _genreController.text,
                  imagePath: _imageFile?.path,
                ));
                _titleController.clear();
                _yearController.clear();
                _genreController.clear();
                setState(() {
                  _imageFile = null;
                });
              }
            },
            child: Text('Добавить фильм'),
          ),
          Expanded(
            child: BlocBuilder<MovieCubit, MovieState>(
              builder: (context, state) {
                if (state is MovieInitial) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is MovieLoaded) {
                  return ListView.builder(
                    itemCount: state.movies.length,
                    itemBuilder: (context, index) {
                      final movie = state.movies[index];
                      return ListTile(
                        leading: movie.imagePath != null
                            ? Image.file(File(movie.imagePath!))
                            : null,
                        title: Text(movie.title),
                        subtitle: Text('${movie.year} - ${movie.genre}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            context.read<MovieCubit>().deleteMovie(index);
                          },
                        ),
                      );
                    },
                  );
                }
                return SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<ThemeCubit>().toggleTheme();
        },
        child: BlocBuilder<ThemeCubit, bool>(
          builder: (context, isDark) {
            return Icon(isDark ? Icons.wb_sunny : Icons.nights_stay);
          },
        ),
      ),
    );
  }
}