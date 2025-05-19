import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<bool> {
  ThemeCubit() : super(false) {
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    emit(prefs.getBool('darkMode') ?? false);
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final newState = !state;
    await prefs.setBool('darkMode', newState);
    emit(newState);
  }
}