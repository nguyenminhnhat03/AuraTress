import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      icon: const Icon(
        Icons.language,
        color: Colors.white,
      ),
      onSelected: (Locale locale) {
        context.setLocale(locale);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<Locale>(
          value: const Locale('en', 'US'),
          child: Row(
            children: [
              const Text('🇺🇸', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 12),
              Text('language.english'.tr()),
              if (context.locale == const Locale('en', 'US'))
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.check, color: Colors.green, size: 16),
                ),
            ],
          ),
        ),
        PopupMenuItem<Locale>(
          value: const Locale('vi', 'VN'),
          child: Row(
            children: [
              const Text('🇻🇳', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 12),
              Text('language.vietnamese'.tr()),
              if (context.locale == const Locale('vi', 'VN'))
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.check, color: Colors.green, size: 16),
                ),
            ],
          ),
        ),
        PopupMenuItem<Locale>(
          value: const Locale('ja', 'JP'),
          child: Row(
            children: [
              const Text('🇯🇵', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 12),
              Text('language.japanese'.tr()),
              if (context.locale == const Locale('ja', 'JP'))
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.check, color: Colors.green, size: 16),
                ),
            ],
          ),
        ),
      ],
    );
  }
}