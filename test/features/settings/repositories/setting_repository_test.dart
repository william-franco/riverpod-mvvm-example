import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod_mvvm_example/src/features/settings/models/setting_model.dart';
import 'package:riverpod_mvvm_example/src/features/settings/repositories/setting_repository.dart';

import '../setting_mocks.mocks.dart';

void main() {
  group('SettingRepository Test', () {
    late MockStorageService mockStorageService;
    late SettingRepository repository;

    setUp(() {
      mockStorageService = MockStorageService();
      repository = SettingRepositoryImpl(storageService: mockStorageService);
    });

    // ---------------------------------------------------------------------------
    // readTheme
    // ---------------------------------------------------------------------------

    group('readTheme', () {
      test('should return SettingModel with isDarkTheme true '
          'when storage returns true', () async {
        // arrange
        when(
          mockStorageService.getBoolValue(key: anyNamed('key')),
        ).thenAnswer((_) async => true);

        // act
        final result = await repository.readTheme();

        // assert
        expect(result, isA<SettingModel>());
        expect(result.isDarkTheme, isTrue);
        verify(mockStorageService.getBoolValue(key: anyNamed('key'))).called(1);
      });

      test('should return SettingModel with isDarkTheme false '
          'when storage returns false', () async {
        // arrange
        when(
          mockStorageService.getBoolValue(key: anyNamed('key')),
        ).thenAnswer((_) async => false);

        // act
        final result = await repository.readTheme();

        // assert
        expect(result.isDarkTheme, isFalse);
      });

      test('should return SettingModel with isDarkTheme false '
          'when storage returns null (key not set)', () async {
        // arrange
        when(
          mockStorageService.getBoolValue(key: anyNamed('key')),
        ).thenAnswer((_) async => null);

        // act
        final result = await repository.readTheme();

        // assert
        expect(result.isDarkTheme, isFalse);
      });

      test('should throw Exception when storage throws', () async {
        // arrange
        when(
          mockStorageService.getBoolValue(key: anyNamed('key')),
        ).thenThrow(Exception('Storage failure'));

        // act & assert
        expect(
          () => repository.readTheme(),
          throwsA(
            predicate<Exception>(
              (e) => e.toString().contains('SettingRepository:'),
            ),
          ),
        );
      });
    });

    // ---------------------------------------------------------------------------
    // updateTheme
    // ---------------------------------------------------------------------------

    group('updateTheme', () {
      test(
        'should call storageService.setBoolValue with isDarkTheme true',
        () async {
          // arrange
          when(
            mockStorageService.setBoolValue(
              key: anyNamed('key'),
              value: anyNamed('value'),
            ),
          ).thenAnswer((_) async {
            return;
          });

          // act
          await repository.updateTheme(isDarkTheme: true);

          // assert
          verify(
            mockStorageService.setBoolValue(key: anyNamed('key'), value: true),
          ).called(1);
        },
      );

      test(
        'should call storageService.setBoolValue with isDarkTheme false',
        () async {
          // arrange
          when(
            mockStorageService.setBoolValue(
              key: anyNamed('key'),
              value: anyNamed('value'),
            ),
          ).thenAnswer((_) async {
            return;
          });

          // act
          await repository.updateTheme(isDarkTheme: false);

          // assert
          verify(
            mockStorageService.setBoolValue(key: anyNamed('key'), value: false),
          ).called(1);
        },
      );

      test(
        'should throw Exception when storageService.setBoolValue throws',
        () async {
          // arrange
          when(
            mockStorageService.setBoolValue(
              key: anyNamed('key'),
              value: anyNamed('value'),
            ),
          ).thenThrow(Exception('Write failure'));

          // act & assert
          expect(
            () => repository.updateTheme(isDarkTheme: true),
            throwsA(
              predicate<Exception>(
                (e) => e.toString().contains('SettingRepository:'),
              ),
            ),
          );
        },
      );

      test('should complete without returning a value on success', () async {
        // arrange
        when(
          mockStorageService.setBoolValue(
            key: anyNamed('key'),
            value: anyNamed('value'),
          ),
        ).thenAnswer((_) async {
          return;
        });

        // act & assert
        await expectLater(repository.updateTheme(isDarkTheme: true), completes);
      });
    });
  });
}
