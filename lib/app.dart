import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/setup/setup_bloc.dart';
import 'bloc/setup/setup_event.dart';
import 'bloc/setup/setup_state.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/preferences_service.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SetupBloc(preferencesService: PreferencesService())
        ..add(SetupStarted()),
      child: MaterialApp(
        title: 'ME2 Pack Loader',
        debugShowCheckedModeBanner: false,

        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: BlocBuilder<SetupBloc, SetupState>(
          builder: (context, state) {
            if (state is SetupNeedsFolder) {
              return const OnboardingScreen();
            }
            if (state is SetupComplete) {
              return HomeScreen(modEngineDir: state.modEngineDir);
            }

            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}
