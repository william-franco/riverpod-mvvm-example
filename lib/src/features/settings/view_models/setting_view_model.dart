import 'package:flutter/foundation.dart';
import 'package:riverpod_mvvm_example/src/features/settings/models/setting_model.dart';
import 'package:riverpod_mvvm_example/src/features/settings/repositories/setting_repository.dart';

typedef _ViewModel = ChangeNotifier;

abstract interface class SettingViewModel extends _ViewModel {
  SettingModel get settingModel;

  Future<void> getTheme();
  Future<void> changeTheme({required bool isDarkTheme});
}

class SettingViewModelImpl extends _ViewModel implements SettingViewModel {
  final SettingRepository settingRepository;

  SettingViewModelImpl({required this.settingRepository});

  SettingModel _settingModel = SettingModel();

  @override
  SettingModel get settingModel => _settingModel;

  @override
  Future<void> getTheme() async {
    final model = await settingRepository.readTheme();
    _emit(model);
  }

  @override
  Future<void> changeTheme({required bool isDarkTheme}) async {
    final model = _settingModel.copyWith(isDarkTheme: isDarkTheme);
    await settingRepository.updateTheme(isDarkTheme: isDarkTheme);
    _emit(model);
  }

  void _emit(SettingModel newValue) {
    _settingModel = newValue;
    notifyListeners();
    debugPrint('SettingController: ${settingModel.isDarkTheme}');
  }
}
