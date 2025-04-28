import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'movie.dart';

class HiveHelper {
  static Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    Hive.registerAdapter(MovieAdapter());
    await Hive.openBox<Movie>('movies');
  }

  static Box<Movie> getMoviesBox() => Hive.box<Movie>('movies');
}
