import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod_mvvm_example/src/common/patterns/result_pattern.dart';
import 'package:riverpod_mvvm_example/src/features/users/exceptions/user_exception.dart';
import 'package:riverpod_mvvm_example/src/features/users/models/user_model.dart';
import 'package:riverpod_mvvm_example/src/features/users/repositories/user_repository.dart';

import '../user_mocks.mocks.dart';

void main() {
  group('UserRepository Test', () {
    late MockConnectionService mockConnectionService;
    late MockHttpService mockHttpService;
    late UserRepository repository;

    setUp(() {
      mockConnectionService = MockConnectionService();
      mockHttpService = MockHttpService();
      repository = UserRepositoryImpl(
        connectionService: mockConnectionService,
        httpService: mockHttpService,
      );
    });

    // ---------------------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------------------

    final tUserJson = [
      {
        'id': 1,
        'name': 'Leanne Graham',
        'username': 'Bret',
        'email': 'Sincere@april.biz',
        'phone': '1-770-736-0860',
        'website': 'hildegard.org',
        'address': {
          'street': 'Kulas Light',
          'suite': 'Apt. 556',
          'city': 'Gwenborough',
          'zipcode': '92998-3874',
          'geo': {'lat': '-37.3159', 'lng': '81.1496'},
        },
        'company': {
          'name': 'Romaguera-Crona',
          'catchPhrase': 'Multi-layered client-server neural-net',
          'bs': 'harness real-time e-markets',
        },
      },
    ];

    final tUsers = tUserJson.map((e) => UserModel.fromJson(e)).toList();

    // ---------------------------------------------------------------------------
    // findAllUsers — success path
    // ---------------------------------------------------------------------------

    group('findAllUsers', () {
      test('should return SuccessResult with a list of UserModel '
          'when device is connected and API returns 200', () async {
        // arrange
        when(mockConnectionService.checkConnection()).thenAnswer((_) async {
          return;
        });
        when(mockConnectionService.isConnected).thenReturn(true);
        when(mockHttpService.getData(path: anyNamed('path'))).thenAnswer(
          (_) async => (statusCode: 200, data: tUserJson, error: null),
        );

        // act
        final result = await repository.findAllUsers();

        // assert
        expect(result, isA<SuccessResult<List<UserModel>, UserException>>());
        final users =
            (result as SuccessResult<List<UserModel>, UserException>).value;
        expect(users.length, equals(tUsers.length));
        expect(users.first.id, equals(tUsers.first.id));
        expect(users.first.name, equals(tUsers.first.name));
        verify(mockConnectionService.checkConnection()).called(1);
        verify(mockConnectionService.isConnected).called(1);
        verify(mockHttpService.getData(path: anyNamed('path'))).called(1);
      });

      // -------------------------------------------------------------------------
      // findAllUsers — device not connected
      // -------------------------------------------------------------------------

      test('should return ErrorResult when device is not connected', () async {
        // arrange
        when(mockConnectionService.checkConnection()).thenAnswer((_) async {
          return;
        });
        when(mockConnectionService.isConnected).thenReturn(false);

        // act
        final result = await repository.findAllUsers();

        // assert
        expect(result, isA<ErrorResult<List<UserModel>, UserException>>());
        final error =
            (result as ErrorResult<List<UserModel>, UserException>).error;
        expect(error.message, contains('Device not connected.'));
        verifyNever(mockHttpService.getData(path: anyNamed('path')));
      });

      // -------------------------------------------------------------------------
      // findAllUsers — API error (non-200)
      // -------------------------------------------------------------------------

      test(
        'should return ErrorResult when API returns a non-200 status code',
        () async {
          // arrange
          when(mockConnectionService.checkConnection()).thenAnswer((_) async {
            return;
          });
          when(mockConnectionService.isConnected).thenReturn(true);
          when(mockHttpService.getData(path: anyNamed('path'))).thenAnswer(
            (_) async =>
                (statusCode: 500, data: null, error: 'Internal Server Error'),
          );

          // act
          final result = await repository.findAllUsers();

          // assert
          expect(result, isA<ErrorResult<List<UserModel>, UserException>>());
          final error =
              (result as ErrorResult<List<UserModel>, UserException>).error;
          expect(error.message, contains('Failed to fetch users: 500'));
        },
      );

      // -------------------------------------------------------------------------
      // findAllUsers — API returns 200 but data is null
      // -------------------------------------------------------------------------

      test(
        'should return ErrorResult when API returns 200 but data is null',
        () async {
          // arrange
          when(mockConnectionService.checkConnection()).thenAnswer((_) async {
            return;
          });
          when(mockConnectionService.isConnected).thenReturn(true);
          when(
            mockHttpService.getData(path: anyNamed('path')),
          ).thenAnswer((_) async => (statusCode: 200, data: null, error: null));

          // act
          final result = await repository.findAllUsers();

          // assert
          expect(result, isA<ErrorResult<List<UserModel>, UserException>>());
        },
      );

      // -------------------------------------------------------------------------
      // findAllUsers — unexpected exception
      // -------------------------------------------------------------------------

      test(
        'should return ErrorResult when an unexpected exception is thrown',
        () async {
          // arrange
          when(
            mockConnectionService.checkConnection(),
          ).thenThrow(Exception('Network failure'));

          // act
          final result = await repository.findAllUsers();

          // assert
          expect(result, isA<ErrorResult<List<UserModel>, UserException>>());
          final error =
              (result as ErrorResult<List<UserModel>, UserException>).error;
          expect(error.message, contains('Unexpected error'));
        },
      );

      // -------------------------------------------------------------------------
      // findAllUsers — Result.fold integration
      // -------------------------------------------------------------------------

      test(
        'should allow fold to extract the user list on SuccessResult',
        () async {
          // arrange
          when(mockConnectionService.checkConnection()).thenAnswer((_) async {
            return;
          });
          when(mockConnectionService.isConnected).thenReturn(true);
          when(mockHttpService.getData(path: anyNamed('path'))).thenAnswer(
            (_) async => (statusCode: 200, data: tUserJson, error: null),
          );

          // act
          final result = await repository.findAllUsers();
          final users = result.fold(
            onSuccess: (value) => value,
            onError: (_) => <UserModel>[],
          );

          // assert
          expect(users, isNotEmpty);
          expect(users.first.email, equals(tUsers.first.email));
        },
      );

      test('should allow fold to return empty list on ErrorResult', () async {
        // arrange
        when(mockConnectionService.checkConnection()).thenAnswer((_) async {
          return;
        });
        when(mockConnectionService.isConnected).thenReturn(false);

        // act
        final result = await repository.findAllUsers();
        final users = result.fold(
          onSuccess: (value) => value,
          onError: (_) => <UserModel>[],
        );

        // assert
        expect(users, isEmpty);
      });
    });
  });
}
