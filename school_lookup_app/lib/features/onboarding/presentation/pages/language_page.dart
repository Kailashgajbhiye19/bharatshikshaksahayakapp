import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../../../core/theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localization.dart';

class LanguagePage extends ConsumerStatefulWidget {
  const LanguagePage({super.key});

  @override
  ConsumerState<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends ConsumerState<LanguagePage> {
  late String _selectedLang;
  
  @override
  void initState() {
    super.initState();
    _selectedLang = Hive.box('settings').get('language', defaultValue: "en");
  }

  final List<Map<String, String>> _languages = [
    {"code": "en", "label": "English", "sub": "Selected by default"},
    {"code": "hi", "label": "हिन्दी", "sub": "Hindi"},
    {"code": "hinglish", "label": "Hinglish", "sub": "Mix of Hindi & English"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.translate,
                size: 60,
                color: AppColors.primaryOrange,
              ),
              const SizedBox(height: 20),
              const Text(
                "अपनी भाषा चुनें",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Choose Your Language",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryOrange,
                ),
              ),
              const SizedBox(height: 40),
              ..._languages.map(
                (lang) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _selectedLang == lang["code"]
                          ? AppColors.lightOrange
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedLang == lang["code"]
                            ? AppColors.primaryOrange
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _selectedLang == lang["code"]
                              ? AppColors.primaryOrange
                              : Colors.grey.shade200,
                          child: Text(
                            lang["label"]!.substring(0, 1),
                            style: TextStyle(
                              color: _selectedLang == lang["code"]
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                        title: Text(
                          lang["label"]!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(lang["sub"]!),
                        trailing: _selectedLang == lang["code"]
                            ? const Icon(
                                Icons.check_circle,
                                color: AppColors.primaryOrange,
                              )
                            : null,
                        onTap: () =>
                            setState(() => _selectedLang = lang["code"]!),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await Hive.box('settings').put('language', _selectedLang);
                    ref.read(localeProvider.notifier).state = _selectedLang;
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  child: const Text("Set Language  →"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
