class SettingModel {
  final bool isDarkTheme;

  SettingModel({this.isDarkTheme = false});

  SettingModel copyWith({bool? isDarkTheme}) =>
      SettingModel(isDarkTheme: isDarkTheme ?? this.isDarkTheme);
}
