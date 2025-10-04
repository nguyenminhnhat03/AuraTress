import 'package:flutter_riverpod/flutter_riverpod.dart';

// Stores the current language/locale label shown in the navbar.
final languageLabelProvider = NotifierProvider<LanguageLabelNotifier, String>(
  () => LanguageLabelNotifier(),
);

class LanguageLabelNotifier extends Notifier<String> {
  @override
  String build() => 'us EN';
  
  void setLanguage(String language) {
    state = language;
  }
}
