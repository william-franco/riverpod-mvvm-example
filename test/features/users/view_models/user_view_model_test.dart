import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod_mvvm_example/src/common/patterns/app_state_pattern.dart';
import 'package:riverpod_mvvm_example/src/common/patterns/result_pattern.dart';
import 'package:riverpod_mvvm_example/src/features/users/models/user_model.dart';
import 'package:riverpod_mvvm_example/src/features/users/repositories/user_repository.dart';
import 'package:riverpod_mvvm_example/src/features/users/view_models/user_view_model.dart';

import '../user_mocks.mocks.dart';

void main() {
  group('UserViewModel Test', () {
    late MockUserRepository mockUserRepository;
    late UserViewModel viewModel;

    // Dummy values required by mockito for sealed/generic return types
    final dummySuccess = SuccessResult<List<UserModel>, Exception>(value: []);
    final dummyError = ErrorResult<List<UserModel>, Exception>(
      error: Exception('dummy'),
    );

    setUpAll(() {
      provideDummy<UserResult>(dummySuccess);
      provideDummy<UserResult>(dummyError);
    });

    setUp(() {
      mockUserRepository = MockUserRepository();
      viewModel = UserViewModelImpl(userRepository: mockUserRepository);
    });

    tearDown(() {
      viewModel.dispose();
    });

    // ---------------------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------------------

    final tUsers = [
      UserModel(
        id: 1,
        name: 'Leanne Graham',
        username: 'Bret',
        email: 'Sincere@april.biz',
        phone: '1-770-736-0860',
        website: 'hildegard.org',
        address: Address(
          street: 'Kulas Light',
          suite: 'Apt. 556',
          city: 'Gwenborough',
          zipcode: '92998-3874',
          geo: Geo(lat: '-37.3159', lng: '81.1496'),
        ),
        company: Company(
          name: 'Romaguera-Crona',
          catchPhrase: 'Multi-layered client-server neural-net',
          bs: 'harness real-time e-markets',
        ),
      ),
    ];

    // ---------------------------------------------------------------------------
    // Initial state
    // ---------------------------------------------------------------------------

    test('should start with InitialState', () {
      expect(viewModel.state, isA<InitialState<List<UserModel>>>());
    });

    // ---------------------------------------------------------------------------
    // getAllUsers — success path
    // ---------------------------------------------------------------------------

    group('getAllUsers', () {
      test('should emit [LoadingState, SuccessState] '
          'when repository returns SuccessResult', () async {
        // arrange
        when(
          mockUserRepository.findAllUsers(),
        ).thenAnswer((_) async => SuccessResult(value: tUsers));

        final emittedStates = <UsersState>[];
        viewModel.addListener(() => emittedStates.add(viewModel.state));

        // act
        await viewModel.getAllUsers();

        // assert
        expect(emittedStates.length, equals(2));
        expect(emittedStates[0], isA<LoadingState<List<UserModel>>>());
        expect(emittedStates[1], isA<SuccessState<List<UserModel>>>());

        final success = emittedStates[1] as SuccessState<List<UserModel>>;
        expect(success.data, equals(tUsers));
        expect(success.data.first.name, equals(tUsers.first.name));

        verify(mockUserRepository.findAllUsers()).called(1);
      });

      // -------------------------------------------------------------------------
      // getAllUsers — error path
      // -------------------------------------------------------------------------

      test('should emit [LoadingState, ErrorState] '
          'when repository returns ErrorResult', () async {
        // arrange
        when(mockUserRepository.findAllUsers()).thenAnswer(
          (_) async => ErrorResult(error: Exception('Device not connected.')),
        );

        final emittedStates = <UsersState>[];
        viewModel.addListener(() => emittedStates.add(viewModel.state));

        // act
        await viewModel.getAllUsers();

        // assert
        expect(emittedStates.length, equals(2));
        expect(emittedStates[0], isA<LoadingState<List<UserModel>>>());
        expect(emittedStates[1], isA<ErrorState<List<UserModel>>>());

        final error = emittedStates[1] as ErrorState<List<UserModel>>;
        expect(error.message, contains('Device not connected.'));
      });

      // -------------------------------------------------------------------------
      // getAllUsers — SuccessState with empty list
      // -------------------------------------------------------------------------

      test('should emit SuccessState with empty list '
          'when repository returns an empty SuccessResult', () async {
        // arrange
        when(
          mockUserRepository.findAllUsers(),
        ).thenAnswer((_) async => SuccessResult(value: <UserModel>[]));

        final emittedStates = <UsersState>[];
        viewModel.addListener(() => emittedStates.add(viewModel.state));

        // act
        await viewModel.getAllUsers();

        // assert
        expect(emittedStates[1], isA<SuccessState<List<UserModel>>>());
        final success = emittedStates[1] as SuccessState<List<UserModel>>;
        expect(success.data, isEmpty);
      });

      // -------------------------------------------------------------------------
      // getAllUsers — notifyListeners is called correctly
      // -------------------------------------------------------------------------

      test(
        'should notify listeners twice (LoadingState then final state)',
        () async {
          // arrange
          when(
            mockUserRepository.findAllUsers(),
          ).thenAnswer((_) async => SuccessResult(value: tUsers));

          int notifyCount = 0;
          viewModel.addListener(() => notifyCount++);

          // act
          await viewModel.getAllUsers();

          // assert
          expect(notifyCount, equals(2));
        },
      );

      // -------------------------------------------------------------------------
      // getAllUsers — state is LoadingState during execution
      // -------------------------------------------------------------------------

      test(
        'should have LoadingState while repository call is in progress',
        () async {
          // arrange
          UsersState? stateWhileLoading;

          when(mockUserRepository.findAllUsers()).thenAnswer((_) async {
            // capture state synchronously during the async gap
            stateWhileLoading = viewModel.state;
            return SuccessResult(value: tUsers);
          });

          // act
          await viewModel.getAllUsers();

          // assert
          expect(stateWhileLoading, isA<LoadingState<List<UserModel>>>());
        },
      );

      // -------------------------------------------------------------------------
      // getAllUsers — multiple sequential calls
      // -------------------------------------------------------------------------

      test(
        'should reset to LoadingState on each new getAllUsers call',
        () async {
          // arrange
          when(
            mockUserRepository.findAllUsers(),
          ).thenAnswer((_) async => SuccessResult(value: tUsers));

          // act — first call
          await viewModel.getAllUsers();
          expect(viewModel.state, isA<SuccessState<List<UserModel>>>());

          // second call — state should go back to LoadingState first
          when(mockUserRepository.findAllUsers()).thenAnswer(
            (_) async => ErrorResult(error: Exception('Server error')),
          );

          await viewModel.getAllUsers();

          // assert
          expect(viewModel.state, isA<ErrorState<List<UserModel>>>());
          verify(mockUserRepository.findAllUsers()).called(2);
        },
      );
    });
  });
}
