import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod_mvvm_example/src/features/settings/models/setting_model.dart';
import 'package:riverpod_mvvm_example/src/features/settings/view_models/setting_view_model.dart';

import '../setting_mocks.mocks.dart';

void main() {
  group('SettingViewModel Test', () {
    late MockSettingRepository mockSettingRepository;
    late SettingViewModel viewModel;

    setUpAll(() {
      // SettingModel não é sealed/genérico, mas provideDummy garante que
      // o mockito consiga lidar com o tipo em qualquer stub interno.
      provideDummy<SettingModel>(SettingModel());
    });

    setUp(() {
      mockSettingRepository = MockSettingRepository();
      viewModel = SettingViewModelImpl(
        settingRepository: mockSettingRepository,
      );
    });

    tearDown(() {
      viewModel.dispose();
    });

    // ---------------------------------------------------------------------------
    // Initial state
    // ---------------------------------------------------------------------------

    test('should start with a default SettingModel (isDarkTheme false)', () {
      expect(viewModel.state, isA<SettingModel>());
      expect(viewModel.state.isDarkTheme, isFalse);
    });

    // ---------------------------------------------------------------------------
    // getTheme
    // ---------------------------------------------------------------------------

    group('getTheme', () {
      test('should emit SettingModel with isDarkTheme true '
          'when repository returns isDarkTheme true', () async {
        // arrange
        when(
          mockSettingRepository.readTheme(),
        ).thenAnswer((_) async => SettingModel(isDarkTheme: true));

        final emittedStates = <SettingModel>[];
        viewModel.addListener(() => emittedStates.add(viewModel.state));

        // act
        await viewModel.getTheme();

        // assert
        expect(emittedStates.length, equals(1));
        expect(emittedStates.first.isDarkTheme, isTrue);
        verify(mockSettingRepository.readTheme()).called(1);
      });

      test('should emit SettingModel with isDarkTheme false '
          'when repository returns isDarkTheme false', () async {
        // arrange
        when(
          mockSettingRepository.readTheme(),
        ).thenAnswer((_) async => SettingModel(isDarkTheme: false));

        final emittedStates = <SettingModel>[];
        viewModel.addListener(() => emittedStates.add(viewModel.state));

        // act
        await viewModel.getTheme();

        // assert
        expect(emittedStates.first.isDarkTheme, isFalse);
      });

      test('should notify listeners once when getTheme completes', () async {
        // arrange
        when(
          mockSettingRepository.readTheme(),
        ).thenAnswer((_) async => SettingModel(isDarkTheme: true));

        int notifyCount = 0;
        viewModel.addListener(() => notifyCount++);

        // act
        await viewModel.getTheme();

        // assert
        expect(notifyCount, equals(1));
      });

      test('should propagate exception thrown by repository', () async {
        // arrange
        when(
          mockSettingRepository.readTheme(),
        ).thenThrow(Exception('SettingRepository: Storage failure'));

        // act & assert
        expect(() => viewModel.getTheme(), throwsA(isA<Exception>()));
      });
    });

    // ---------------------------------------------------------------------------
    // changeTheme
    // ---------------------------------------------------------------------------

    group('changeTheme', () {
      test('should emit SettingModel with isDarkTheme true '
          'and call repository.updateTheme with true', () async {
        // arrange
        when(
          mockSettingRepository.updateTheme(
            isDarkTheme: anyNamed('isDarkTheme'),
          ),
        ).thenAnswer((_) async {
          return;
        });

        final emittedStates = <SettingModel>[];
        viewModel.addListener(() => emittedStates.add(viewModel.state));

        // act
        await viewModel.changeTheme(isDarkTheme: true);

        // assert
        expect(emittedStates.length, equals(1));
        expect(emittedStates.first.isDarkTheme, isTrue);
        verify(mockSettingRepository.updateTheme(isDarkTheme: true)).called(1);
      });

      test('should emit SettingModel with isDarkTheme false '
          'and call repository.updateTheme with false', () async {
        // arrange
        when(
          mockSettingRepository.updateTheme(
            isDarkTheme: anyNamed('isDarkTheme'),
          ),
        ).thenAnswer((_) async {
          return;
        });

        final emittedStates = <SettingModel>[];
        viewModel.addListener(() => emittedStates.add(viewModel.state));

        // act
        await viewModel.changeTheme(isDarkTheme: false);

        // assert
        expect(emittedStates.first.isDarkTheme, isFalse);
        verify(mockSettingRepository.updateTheme(isDarkTheme: false)).called(1);
      });

      test('should preserve other SettingModel fields when toggling theme '
          'via copyWith', () async {
        // arrange — simulate a prior state via getTheme
        when(
          mockSettingRepository.readTheme(),
        ).thenAnswer((_) async => SettingModel(isDarkTheme: false));
        when(
          mockSettingRepository.updateTheme(
            isDarkTheme: anyNamed('isDarkTheme'),
          ),
        ).thenAnswer((_) async {
          return;
        });

        await viewModel.getTheme();

        // act
        await viewModel.changeTheme(isDarkTheme: true);

        // assert — state reflects the toggle
        expect(viewModel.state.isDarkTheme, isTrue);
      });

      test(
        'should notify listeners exactly once per changeTheme call',
        () async {
          // arrange
          when(
            mockSettingRepository.updateTheme(
              isDarkTheme: anyNamed('isDarkTheme'),
            ),
          ).thenAnswer((_) async {
            return;
          });

          int notifyCount = 0;
          viewModel.addListener(() => notifyCount++);

          // act
          await viewModel.changeTheme(isDarkTheme: true);

          // assert
          expect(notifyCount, equals(1));
        },
      );

      test(
        'should not emit new state when repository.updateTheme throws',
        () async {
          // arrange
          when(
            mockSettingRepository.updateTheme(
              isDarkTheme: anyNamed('isDarkTheme'),
            ),
          ).thenThrow(Exception('Write failure'));

          final emittedStates = <SettingModel>[];
          viewModel.addListener(() => emittedStates.add(viewModel.state));

          // act & assert
          expect(
            () => viewModel.changeTheme(isDarkTheme: true),
            throwsA(isA<Exception>()),
          );
          // listener was never called because emitState was not reached
          expect(emittedStates, isEmpty);
        },
      );

      test(
        'should reflect correct state after multiple sequential changeTheme calls',
        () async {
          // arrange
          when(
            mockSettingRepository.updateTheme(
              isDarkTheme: anyNamed('isDarkTheme'),
            ),
          ).thenAnswer((_) async {
            return;
          });

          // act
          await viewModel.changeTheme(isDarkTheme: true);
          expect(viewModel.state.isDarkTheme, isTrue);

          await viewModel.changeTheme(isDarkTheme: false);
          expect(viewModel.state.isDarkTheme, isFalse);

          verify(
            mockSettingRepository.updateTheme(
              isDarkTheme: anyNamed('isDarkTheme'),
            ),
          ).called(2);
        },
      );
    });
  });
}
