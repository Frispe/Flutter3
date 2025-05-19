import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'movie.dart';
import 'hive_helper.dart';

// Состояния
abstract class MovieState extends Equatable {
  const MovieState();
  @override
  List<Object> get props => [];
}

class MovieInitial extends MovieState {}

class MovieLoaded extends MovieState {
  final List<Movie> movies;
  const MovieLoaded(this.movies);
  @override
  List<Object> get props => [movies];
}

// Кубит
class MovieCubit extends Cubit<MovieState> {
  MovieCubit() : super(MovieInitial()) {
    loadMovies();
  }

  void loadMovies() {
    final movies = HiveHelper.getMoviesBox().values.toList();
    emit(MovieLoaded(movies));
  }

  void addMovie(Movie movie) {
    HiveHelper.getMoviesBox().add(movie);
    loadMovies();
  }

  void deleteMovie(int index) {
    HiveHelper.getMoviesBox().deleteAt(index);
    loadMovies();
  }
}