import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'theme.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/duel_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/training_screen.dart';
import 'screens/chrono_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MathQuestApp());
}

class MathQuestApp extends StatelessWidget {
  const MathQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService  = ApiService();
    final authService = AuthService(apiService);

    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => apiService),
        ChangeNotifierProvider<AuthService>(create: (_) => authService),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
      ],
      child: _AppRouter(authService: authService, apiService: apiService),
    );
  }
}

class _AppRouter extends StatefulWidget {
  final AuthService authService;
  final ApiService  apiService;
  const _AppRouter({required this.authService, required this.apiService});

  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  late final GoRouter _router;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initRouter();
  }

  Future<void> _initRouter() async {
    final loggedIn = await widget.authService.tryRestoreSession();
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    setState(() {
      _initialized = true;
      _router = _buildRouter(loggedIn, onboardingDone);
    });
  }

  GoRouter _buildRouter(bool loggedIn, bool onboardingDone) => GoRouter(
    initialLocation: !onboardingDone ? '/onboarding' : (loggedIn ? '/home' : '/login'),
    redirect: (context, state) {
      final isAuth = widget.authService.isLoggedIn;
      final loc = state.matchedLocation;
      if (loc == '/onboarding') return null;
      final onAuth = loc == '/login' || loc == '/signup';
      if (!isAuth && !onAuth) return '/login';
      if (isAuth && onAuth) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login',  builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      ShellRoute(
        builder: (context, state, child) =>
            MainShell(child: child, state: state),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => HomeScreen(apiService: widget.apiService),
          ),
          GoRoute(
            path: '/duel',
            builder: (_, state) {
              final subjectId = state.uri.queryParameters['subjectId'] ?? '';
              final subjectName = state.uri.queryParameters['subjectName'] ?? '';
              return DuelScreen(
                subjectId: subjectId,
                subjectName: subjectName,
                apiService: widget.apiService,
              );
            },
          ),
          GoRoute(
            path: '/leaderboard',
            builder: (_, __) => LeaderboardScreen(apiService: widget.apiService),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => ProfileScreen(apiService: widget.apiService),
          ),
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/achievements',
            builder: (_, __) => const AchievementsScreen(),
          ),
          GoRoute(
            path: '/training',
            builder: (_, state) {
              final slug = state.uri.queryParameters['subjectSlug'] ?? 'math';
              final name = state.uri.queryParameters['subjectName'] ?? 'Mathématiques';
              return TrainingScreen(subjectSlug: slug, subjectName: name);
            },
          ),
          GoRoute(
            path: '/chrono',
            builder: (_, state) {
              final slug = state.uri.queryParameters['subjectSlug'] ?? 'math';
              final name = state.uri.queryParameters['subjectName'] ?? 'Mathématiques';
              return ChronoScreen(subjectSlug: slug, subjectName: name);
            },
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const _SplashScreen(),
      );
    }
    return Consumer<ThemeProvider>(
      builder: (context, themeProv, _) => MaterialApp.router(
        title: 'MathQuest',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeProv.mode,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}


/// Shell with persistent bottom navigation bar — animated icons
class MainShell extends StatelessWidget {
  final Widget child;
  final GoRouterState state;
  const MainShell({super.key, required this.child, required this.state});

  static const _tabs = ['/home', '/duel', '/leaderboard', '/profile'];

  int _currentIndex(String location) {
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _currentIndex(state.matchedLocation);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (i) {
                final icons = [Icons.home_rounded, Icons.bolt_rounded, Icons.emoji_events, Icons.person_rounded];
                final labels = ['Accueil', 'Duel', 'Classement', 'Profil'];
                final isActive = idx == i;
                return GestureDetector(
                  onTap: () => context.go(_tabs[i]),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.symmetric(horizontal: isActive ? 16 : 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.primary.withOpacity(0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icons[i],
                          size: isActive ? 24 : 22,
                          color: isActive ? AppTheme.primary : (isDark ? AppTheme.darkMuted : AppTheme.textMuted),
                        ),
                        if (isActive) ...[
                          const SizedBox(width: 6),
                          Text(
                            labels[i],
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated branded splash screen shown during initialization.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(color: Colors.white.withOpacity(0.1), blurRadius: 40, spreadRadius: 10),
                  ],
                ),
                child: const Icon(Icons.calculate_rounded, size: 60, color: Colors.white),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.05, 1.05), duration: 1200.ms, curve: Curves.easeInOut),
              const SizedBox(height: 24),
              const Text(
                'MathQuest',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
              const SizedBox(height: 8),
              Text(
                'Chargement...',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
              ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
              const SizedBox(height: 32),
              const SizedBox(
                width: 28, height: 28,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              ).animate().fadeIn(delay: 700.ms),
            ],
          ),
        ),
      ),
    );
  }
}
