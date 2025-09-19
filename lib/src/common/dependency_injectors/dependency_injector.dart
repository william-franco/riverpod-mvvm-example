import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod_mvvm_example/src/common/services/connection_service.dart';
import 'package:riverpod_mvvm_example/src/common/services/http_service.dart';
import 'package:riverpod_mvvm_example/src/common/services/storage_service.dart';
import 'package:riverpod_mvvm_example/src/features/settings/repositories/setting_repository.dart';
import 'package:riverpod_mvvm_example/src/features/settings/view_models/setting_view_model.dart';
import 'package:riverpod_mvvm_example/src/features/users/repositories/user_repository.dart';
import 'package:riverpod_mvvm_example/src/features/users/view_models/user_view_model.dart';

// Services
final connectionService = Provider<ConnectionService>((ref) {
  final service = ConnectionServiceImpl();
  Future.microtask(() async {
    await service.checkConnection();
  });
  return service;
});

final httpService = Provider<HttpService>((ref) {
  return HttpServiceImpl();
});

final storageService = Provider<StorageService>((ref) {
  final service = StorageServiceImpl();
  Future.microtask(() async {
    await service.initStorage();
  });
  return service;
});

// Repositories
final settingRepository = Provider.autoDispose<SettingRepository>((ref) {
  return SettingRepositoryImpl(storageService: ref.watch(storageService));
});

final userRepository = Provider.autoDispose<UserRepository>((ref) {
  return UserRepositoryImpl(
    connectionService: ref.watch(connectionService),
    httpService: ref.watch(httpService),
  );
});

// ViewModels
final settingViewModelProv = ChangeNotifierProvider<SettingViewModel>((ref) {
  final viewModel = SettingViewModelImpl(
    settingRepository: ref.watch(settingRepository),
  );
  Future.microtask(() async {
    await Future.delayed(Duration.zero);
    await viewModel.getTheme();
  });
  return viewModel;
});

final userViewModelProv = ChangeNotifierProvider<UserViewModel>((ref) {
  return UserViewModelImpl(userRepository: ref.watch(userRepository));
});
