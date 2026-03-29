import 'package:mockito/annotations.dart';
import 'package:riverpod_mvvm_example/src/common/services/connection_service.dart';
import 'package:riverpod_mvvm_example/src/common/services/http_service.dart';
import 'package:riverpod_mvvm_example/src/features/users/repositories/user_repository.dart';

@GenerateMocks([ConnectionService, HttpService, UserRepository])
void main() {}
