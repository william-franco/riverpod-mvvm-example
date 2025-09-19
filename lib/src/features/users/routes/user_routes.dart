import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_mvvm_example/src/common/dependency_injectors/dependency_injector.dart';
import 'package:riverpod_mvvm_example/src/features/users/models/user_model.dart';
import 'package:riverpod_mvvm_example/src/features/users/views/user_detail_view.dart';
import 'package:riverpod_mvvm_example/src/features/users/views/user_view.dart';

class UserRoutes {
  static String get users => '/users';
  static String get userDetail => '/users-detail';

  List<GoRoute> get routes => _routes;

  final List<GoRoute> _routes = [
    GoRoute(
      path: users,
      builder: (context, state) {
        return Consumer(
          builder: (context, ref, child) {
            return UserView(userViewModel: ref.read(userViewModelProv));
          },
        );
      },
    ),
    GoRoute(
      path: userDetail,
      builder: (context, state) {
        final UserModel userModel = state.extra as UserModel;

        return UserDetailView(userModel: userModel);
      },
    ),
  ];
}
