import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_mvvm_example/src/common/dependency_injectors/dependency_injector.dart';
import 'package:riverpod_mvvm_example/src/common/routes/routes.dart';

void main() {
  final Routes appRoutes = Routes();
  runApp(ProviderScope(child: MyApp(appRoutes: appRoutes)));
}

class MyApp extends ConsumerWidget {
  final Routes appRoutes;

  const MyApp({super.key, required this.appRoutes});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingViewModel = ref.watch(settingViewModelProv);
    return ListenableBuilder(
      listenable: settingViewModel,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Riverpod MVVM Example',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(useMaterial3: true),
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: settingViewModel.settingModel.isDarkTheme
              ? ThemeMode.dark
              : ThemeMode.light,
          routerConfig: appRoutes.routes,
        );
      },
    );
  }
}
