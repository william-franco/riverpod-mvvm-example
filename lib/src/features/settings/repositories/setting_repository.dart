import 'package:riverpod_mvvm_example/src/common/constants/value_constant.dart';
import 'package:riverpod_mvvm_example/src/common/services/storage_service.dart';
import 'package:riverpod_mvvm_example/src/common/services/url_launcher_service.dart';
import 'package:riverpod_mvvm_example/src/features/settings/models/setting_model.dart';

abstract interface class SettingRepository {
  Future<void> openUrl({required Uri url});
  Future<SettingModel> readTheme();
  Future<void> updateTheme({required bool isDarkTheme});
}

class SettingRepositoryImpl implements SettingRepository {
  final StorageService storageService;

  final UrlLauncherService urlLauncherService;

  SettingRepositoryImpl({
    required this.storageService,
    required this.urlLauncherService,
  });

  @override
  Future<void> openUrl({required Uri url}) async {
    await urlLauncherService.openUrl(url: url);
  }

  @override
  Future<SettingModel> readTheme() async {
    try {
      final isDarkMode = await storageService.getBoolValue(
        key: ValueConstant.darkMode,
      );
      return SettingModel(isDarkTheme: isDarkMode ?? false);
    } catch (error) {
      throw Exception('SettingRepository: $error');
    }
  }

  @override
  Future<void> updateTheme({required bool isDarkTheme}) async {
    try {
      await storageService.setBoolValue(
        key: ValueConstant.darkMode,
        value: isDarkTheme,
      );
    } catch (error) {
      throw Exception('SettingRepository: $error');
    }
  }
}
