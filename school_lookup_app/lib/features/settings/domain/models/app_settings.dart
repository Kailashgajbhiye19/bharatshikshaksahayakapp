class AppSettings {
  final String language;
  final bool isDarkMode;
  final bool notificationsEnabled;

  AppSettings({
    required this.language,
    required this.isDarkMode,
    required this.notificationsEnabled,
  });

  AppSettings copyWith({
    String? language,
    bool? isDarkMode,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      language: language ?? this.language,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
