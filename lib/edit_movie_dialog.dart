import 'package:flutter/material.dart';
import 'movie.dart';

class EditMovieDialog extends StatefulWidget {
  final Movie movie;
  final int index;

  const EditMovieDialog({required this.movie, required this.index, Key? key}) : super(key: key);

  @override
  _EditMovieDialogState createState() => _EditMovieDialogState();
}

class _EditMovieDialogState extends State<EditMovieDialog> {
  late TextEditingController _titleController;
  late TextEditingController _yearController;
  late TextEditingController _genreController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.movie.title);
    _yearController = TextEditingController(text: widget.movie.year.toString());
    _genreController = TextEditingController(text: widget.movie.genre);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _yearController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Редактировать фильм'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedMovie = Movie(
              title: _titleController.text,
              year: int.parse(_yearController.text),
              genre: _genreController.text,
              imagePath: widget.movie.imagePath,
            );
            Navigator.pop(context, updatedMovie);
          },
          child: Text('Сохранить'),
        ),
      ],
    );
  }
}