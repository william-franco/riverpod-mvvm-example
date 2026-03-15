import 'package:flutter/foundation.dart';
import 'package:riverpod_mvvm_example/src/common/state_management/state_management.dart';
import 'package:riverpod_mvvm_example/src/features/settings/models/setting_model.dart';
import 'package:riverpod_mvvm_example/src/features/settings/repositories/setting_repository.dart';

typedef _ViewModel = StateManagement<SettingModel>;

abstract interface class SettingViewModel extends _ViewModel {
  SettingViewModel(super.initialState);

  Future<void> getTheme();
  Future<void> changeTheme({required bool isDarkTheme});
}

class SettingViewModelImpl extends _ViewModel implements SettingViewModel {
  final SettingRepository settingRepository;

  SettingViewModelImpl({required this.settingRepository})
    : super(SettingModel());

  @override
  Future<void> getTheme() async {
    final model = await settingRepository.readTheme();
    _emit(model);
  }

  @override
  Future<void> changeTheme({required bool isDarkTheme}) async {
    final model = state.copyWith(isDarkTheme: isDarkTheme);
    await settingRepository.updateTheme(isDarkTheme: isDarkTheme);
    _emit(model);
  }

  void _emit(SettingModel newState) {
    emitState(newState);
    debugPrint('SettingViewModel: ${state.isDarkTheme}');
  }
}
