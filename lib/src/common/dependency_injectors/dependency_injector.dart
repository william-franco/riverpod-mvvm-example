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
final connectionServiceProvider = Provider<ConnectionService>((ref) {
  return ConnectionServiceImpl();
});

final httpServiceProvider = Provider<HttpService>((ref) {
  return HttpServiceImpl();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageServiceImpl();
});

// Repositories
final settingRepositoryProvider = Provider.autoDispose<SettingRepository>((
  ref,
) {
  final storageService = ref.watch(storageServiceProvider);
  return SettingRepositoryImpl(storageService: storageService);
});

final userRepositoryProvider = Provider.autoDispose<UserRepository>((ref) {
  final connectionService = ref.watch(connectionServiceProvider);
  final httpService = ref.watch(httpServiceProvider);
  return UserRepositoryImpl(
    connectionService: connectionService,
    httpService: httpService,
  );
});

// ViewModels
final settingViewModelProvider = ChangeNotifierProvider<SettingViewModel>((
  ref,
) {
  final settingRepository = ref.watch(settingRepositoryProvider);
  return SettingViewModelImpl(settingRepository: settingRepository);
});

final userViewModelProvider = ChangeNotifierProvider<UserViewModel>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return UserViewModelImpl(userRepository: userRepository);
});

/// Init dependencies asynchronously.
final appBootstrapProvider = FutureProvider<void>((ref) async {
  final storageService = ref.read(storageServiceProvider);
  final connectionService = ref.read(connectionServiceProvider);
  final settingViewModel = ref.read(settingViewModelProvider);

  await Future.wait([
    storageService.initStorage(),
    connectionService.checkConnection(),
  ]);

  await settingViewModel.getTheme();
});
