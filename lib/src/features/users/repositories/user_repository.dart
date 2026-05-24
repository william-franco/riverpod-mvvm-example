import 'package:riverpod_mvvm_example/src/common/constants/api_constant.dart';
import 'package:riverpod_mvvm_example/src/common/patterns/result_pattern.dart';
import 'package:riverpod_mvvm_example/src/common/services/connection_service.dart';
import 'package:riverpod_mvvm_example/src/common/services/http_service.dart';
import 'package:riverpod_mvvm_example/src/features/users/exceptions/user_exception.dart';
import 'package:riverpod_mvvm_example/src/features/users/models/user_model.dart';

typedef UserResult = Result<List<UserModel>, UserException>;

abstract interface class UserRepository {
  Future<UserResult> findAllUsers();
}

class UserRepositoryImpl implements UserRepository {
  final ConnectionService connectionService;
  final HttpService httpService;

  UserRepositoryImpl({
    required this.connectionService,
    required this.httpService,
  });

  @override
  Future<UserResult> findAllUsers() async {
    try {
      await connectionService.checkConnection();

      if (!connectionService.isConnected) {
        return ErrorResult(error: UserException('Device not connected.'));
      }

      final result = await httpService.getData(path: ApiConstant.users);

      if (result.statusCode == 200 && result.data != null) {
        final users = (result.data as List)
            .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
            .toList();

        return SuccessResult(value: users);
      }

      return ErrorResult(
        error: UserException('Failed to fetch users: ${result.statusCode}'),
      );
    } catch (error) {
      return ErrorResult(error: UserException('Unexpected error: $error'));
    }
  }
}
