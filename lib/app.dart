import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bloc/setup/setup_bloc.dart';
import 'bloc/setup/setup_event.dart';
import 'bloc/setup/setup_state.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/preferences_service.dart';

const _background    = Color(0xFF070607);
const _surface1      = Color(0xFF100E10);
const _surface2      = Color(0xFF161316);
const _surface3      = Color(0xFF1D191D);
const _border        = Color(0xFF2C272B);
const _accent        = Color(0xFFFF8A70);
const _accentHover   = Color(0xFFFFA18C);
const _textPrimary   = Color(0xFFF1E9E5);
const _textMuted     = Color(0xFFB9AAA5);
const _error         = Color(0xFFCF6679);

final _colorScheme = const ColorScheme(
  brightness:          Brightness.dark,
  primary:             _accent,
  onPrimary:           _background,
  primaryContainer:    _surface3,
  onPrimaryContainer:  _textPrimary,
  secondary:           _accentHover,
  onSecondary:         _background,
  secondaryContainer:  _surface2,
  onSecondaryContainer:_textPrimary,
  tertiary:            _accentHover,
  onTertiary:          _background,
  tertiaryContainer:   _surface2,
  onTertiaryContainer: _textPrimary,
  error:               _error,
  onError:             _background,
  errorContainer:      Color(0xFF5C2028),
  onErrorContainer:    Color(0xFFFFB3BC),
  surface:             _surface1,
  onSurface:           _textPrimary,
  surfaceContainerHighest: _surface3,
  surfaceContainerHigh:    _surface2,
  surfaceContainer:        _surface2,
  surfaceContainerLow:     _surface1,
  surfaceContainerLowest:  _background,
  onSurfaceVariant:    _textMuted,
  outline:             _border,
  outlineVariant:      _surface3,
  shadow:              Colors.black,
  scrim:               Colors.black,
  inverseSurface:      _textPrimary,
  onInverseSurface:    _background,
  inversePrimary:      _surface3,
);

ThemeData _buildTheme() {
  final base = ThemeData(
    colorScheme: _colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor: _background,
  );
  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: _textPrimary,
      displayColor: _textPrimary,
    ),
    dividerTheme: const DividerThemeData(color: _border, space: 1, thickness: 1),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: _surface1,
      indicatorColor: _surface3,
      unselectedIconTheme: IconThemeData(color: _textMuted),
      selectedIconTheme: IconThemeData(color: _accent),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? _accent : _textMuted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? _accent.withValues(alpha: 0.4)
            : _surface3,
      ),
    ),
  );
}

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
        darkTheme: _buildTheme(),
        home: BlocBuilder<SetupBloc, SetupState>(
          builder: (context, state) {
            if (state is SetupNeedsFolder) return const OnboardingScreen();
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
