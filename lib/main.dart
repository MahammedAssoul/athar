import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'app_shell.dart';
import 'core/localization/app_locales.dart';
import 'core/localization/app_strings.dart';
import 'core/localization/locale_controller.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/di/app_dependencies.dart';
import 'data/services/local_storage.dart';
import 'features/auth/presentation/auth_cubit.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/onboarding/presentation/onboarding_page.dart';

/// ─────────────────────────────────────────────────────────
/// PHASE 1 — SINGLE MOCK SWITCH
///
/// When `isMock == true` the app uses mock repositories and
/// services only. When `false`, real API repositories can be
/// plugged in via `AppDependencies` (not implemented yet).
/// ─────────────────────────────────────────────────────────
bool isMock = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppDependencies.isMock = isMock;
  runApp(const AtharApp());
}

class AtharApp extends StatefulWidget {
  const AtharApp({super.key});

  @override
  State<AtharApp> createState() => _AtharAppState();
}

class _AtharAppState extends State<AtharApp> {
  final LocaleController _localeController = LocaleController();

  @override
  void initState() {
    super.initState();
    _restoreLanguage();
  }

  Future<void> _restoreLanguage() async {
    final saved = await LocalStorage.getLanguage();
    if (saved != null) {
      _localeController.setLocale(saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _localeController,
      builder: (context, _) {
        // AuthCubit and LocaleController are provided at the app level so
        // every route (login, OTP, register, profile, ...) can access them.
        // ChangeNotifierProvider is used because LocaleController is a
        // ChangeNotifier — plain Provider would not rebuild dependents.
        return ChangeNotifierProvider<LocaleController>.value(
          value: _localeController,
          child: BlocProvider(
            create: (_) => AuthCubit(),
            child: MaterialApp(
              title: 'أثر',
              debugShowCheckedModeBanner: false,
              onGenerateTitle: (context) => AppStrings.of(context).appName,
              locale: _localeController.locale,
              supportedLocales: const [
                Locale(AppLocales.ar),
                Locale(AppLocales.en),
              ],
              localizationsDelegates: const [
                AppStrings.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: AppTheme.light,
              initialRoute: '/',
              onGenerateRoute: AppRouter.onGenerateRoute,
              home: const StartupGate(),
            ),
          ),
        );
      },
    );
  }
}

/// Decides the first screen: onboarding → login → shell.
///
/// Listens to [AuthCubit] so that logging out (from the profile page)
/// automatically returns to the login screen.
class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  bool _loading = true;
  bool _onboardingDone = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final onboardingDone = await LocalStorage.isOnboardingDone();
    // Restore any persisted session into the AuthCubit state.
    // Guard with `mounted` because the context is used after an await.
    if (!mounted) return;
    await context.read<AuthCubit>().restoreSession();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _onboardingDone = onboardingDone;
    });
  }

  void _onOnboardingDone() {
    setState(() => _onboardingDone = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_onboardingDone) {
      return OnboardingPage(onDone: _onOnboardingDone);
    }
    // React to auth state: when the user logs out, AuthCubit emits a
    // fresh state and we show the login screen again.
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final loggedIn = state.user != null;
        if (!loggedIn) {
          return const LoginPage();
        }
        return const AppShell();
      },
    );
  }
}
