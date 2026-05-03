// lib/main.dart
import 'package:cv_app/l10n/app_localizations.dart';
import 'package:cv_app/providers/locale_provider.dart';
import 'package:cv_app/providers/theme_provider.dart';
import 'package:cv_app/screens/ai_cv_builder_screen.dart';
import 'package:cv_app/screens/analysis_screen.dart';
import 'package:cv_app/screens/builder_screen.dart';
import 'package:cv_app/screens/dashboard_screen.dart';
import 'package:cv_app/screens/home_page.dart';
import 'package:cv_app/screens/login_page.dart';
import 'package:cv_app/screens/onboarding_screen.dart';
import 'package:cv_app/screens/settings_screen.dart';
import 'package:cv_app/services/auth_service.dart';
import 'package:cv_app/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'blocs/resume_bloc.dart';
import 'blocs/resume_event.dart';
import 'data/models/resume.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ResumeBuilderApp());
}

class ResumeBuilderApp extends StatelessWidget {
  const ResumeBuilderApp({super.key});

  Future<bool> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_complete') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        BlocProvider<ResumeBloc>(
          create: (context) => ResumeBloc()..add(LoadResumes()),
          lazy: false,
        ),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'ProfiFlow',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme.copyWith(
              textTheme:
                  localeProvider.locale.languageCode == 'ar'
                      ? ThemeData.light().textTheme.apply(fontFamily: 'Cairo')
                      : ThemeData.light().textTheme.apply(fontFamily: 'Inter'),
            ),
            darkTheme: AppTheme.darkTheme.copyWith(
              textTheme:
                  localeProvider.locale.languageCode == 'ar'
                      ? ThemeData.dark().textTheme.apply(fontFamily: 'Cairo')
                      : ThemeData.dark().textTheme.apply(fontFamily: 'Inter'),
            ),
            locale: localeProvider.locale,
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: FutureBuilder<bool>(
              future: _checkOnboarding(),
              builder: (context, onboardingSnapshot) {
                if (onboardingSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (onboardingSnapshot.data == false) {
                  return const OnboardingScreen();
                }
                return const LoginPage();
              },
            ),
            routes: {
              '/home': (context) => HomePage(),
              '/dashboard': (context) => const DashboardPage(),
              '/builder': (context) => const BuilderPage(),
              '/ai-cv-builder': (context) => const AICVBuilderScreen(),
              '/analysis': (context) {
                final resume =
                    ModalRoute.of(context)!.settings.arguments as Resume;
                return AnalysisPage(resume: resume);
              },
              '/settings': (context) => const SettingsPage(),
              '/login': (context) => const LoginPage(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/analysis') {
                final resume = settings.arguments as Resume;
                return MaterialPageRoute(
                  builder: (_) => AnalysisPage(resume: resume),
                );
              }
              return null;
            },
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder:
                    (_) => FutureBuilder<bool>(
                      future: _checkOnboarding(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Scaffold(
                            body: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (snapshot.data == false) {
                          return const OnboardingScreen();
                        }
                        return StreamBuilder(
                          stream: AuthService().authStateChanges,
                          builder: (context, authSnapshot) {
                            if (authSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Scaffold(
                                body: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (authSnapshot.hasData) {
                              return const HomePage();
                            }
                            return const LoginPage();
                          },
                        );
                      },
                    ),
              );
            },
          );
        },
      ),
    );
  }
}
