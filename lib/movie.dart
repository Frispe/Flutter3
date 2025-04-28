import 'package:hive/hive.dart';
part 'movie.g.dart';

@HiveType(typeId: 0)
class Movie {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final int year;
  @HiveField(2)
  final String genre;
  @HiveField(3)
  String? imagePath;

  Movie({required this.title, required this.year, required this.genre, this.imagePath});
}
