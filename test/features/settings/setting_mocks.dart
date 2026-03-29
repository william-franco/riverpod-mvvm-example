import 'package:mockito/annotations.dart';
import 'package:riverpod_mvvm_example/src/common/services/storage_service.dart';
import 'package:riverpod_mvvm_example/src/features/settings/repositories/setting_repository.dart';

@GenerateMocks([StorageService, SettingRepository])
void main() {}
