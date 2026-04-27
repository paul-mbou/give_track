import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme mode provider
final themeModeProvider = NotifierProvider<ThemeModeNotifier, bool>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<bool> {
  @override
  bool build() {
    Future<void> load() async {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool('isDarkMode') ?? false;
    }

    load();
    return false;
  }

  Future<void> toggleTheme() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', state);
  }
}

// Language provider
final languageProvider = NotifierProvider<LanguageNotifier, String>(
  LanguageNotifier.new,
);

class LanguageNotifier extends Notifier<String> {
  @override
  String build() {
    Future<void> load() async {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getString('language') ?? 'en';
    }

    load();
    return 'en';
  }

  Future<void> setLanguage(String lang) async {
    state = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
  }
}

// Notifications provider
final notificationsProvider = NotifierProvider<NotificationsNotifier, bool>(
  NotificationsNotifier.new,
);

class NotificationsNotifier extends Notifier<bool> {
  @override
  bool build() {
    Future<void> load() async {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool('notificationsEnabled') ?? true;
    }

    load();
    return true;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', state);
  }
}
