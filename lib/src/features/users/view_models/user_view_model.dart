import 'package:flutter/foundation.dart';
import 'package:riverpod_mvvm_example/src/common/patterns/app_state_pattern.dart';
import 'package:riverpod_mvvm_example/src/common/state_management/state_management.dart';
import 'package:riverpod_mvvm_example/src/features/users/models/user_model.dart';
import 'package:riverpod_mvvm_example/src/features/users/repositories/user_repository.dart';

typedef _ViewModel = StateManagement<UsersState>;

typedef UsersState = AppState<List<UserModel>>;

abstract interface class UserViewModel extends _ViewModel {
  UserViewModel(super.initialState);

  Future<void> getAllUsers();
}

class UserViewModelImpl extends _ViewModel implements UserViewModel {
  final UserRepository userRepository;

  UserViewModelImpl({required this.userRepository}) : super(InitialState());

  @override
  Future<void> getAllUsers() async {
    _emit(LoadingState());

    final result = await userRepository.findAllUsers();

    final state = result.fold<UsersState>(
      onSuccess: (value) => SuccessState(data: value),
      onError: (error) => ErrorState(message: '$error'),
    );

    _emit(state);
  }

  void _emit(UsersState newState) {
    emitState(newState);
    debugPrint('User state: $state');
  }
}
