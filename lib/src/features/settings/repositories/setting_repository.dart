import 'package:riverpod_mvvm_example/src/common/constants/value_constant.dart';
import 'package:riverpod_mvvm_example/src/common/services/storage_service.dart';
import 'package:riverpod_mvvm_example/src/features/settings/models/setting_model.dart';

abstract interface class SettingRepository {
  Future<SettingModel> readTheme();
  Future<void> updateTheme({required bool isDarkTheme});
}

class SettingRepositoryImpl implements SettingRepository {
  final StorageService storageService;

  SettingRepositoryImpl({required this.storageService});

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
