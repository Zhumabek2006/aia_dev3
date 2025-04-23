import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../domain/providers/theme_provider.dart';
import 'presentation/themes/app_theme.dart';
import 'presentation/screens/admin_add_category_screen.dart';
import 'presentation/screens/admin_add_contest_screen.dart';
import 'presentation/screens/admin_add_question_screen.dart';
import 'presentation/screens/admin_add_study_material_screen.dart';
import 'presentation/screens/admin_add_test_type_screen.dart';
import 'presentation/screens/admin_edit_category_screen.dart';
import 'presentation/screens/admin_edit_contest_screen.dart';
import 'presentation/screens/admin_edit_question_screen.dart';
import 'presentation/screens/admin_edit_study_material_screen.dart';
import 'presentation/screens/admin_edit_test_type_screen.dart';
import 'presentation/screens/admin_panel_screen.dart';
import 'presentation/screens/contests_screen.dart';
import 'presentation/screens/history_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/results_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/test_screen.dart';
import 'presentation/screens/training_screen.dart';
import 'presentation/screens/verify_code_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  final _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) {
          print('App: Navigating to / (LoginScreen)');
          return CustomTransitionPage(
            key: state.pageKey,
            child: LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) {
          print('App: Navigating to /register');
          return CustomTransitionPage(
            key: state.pageKey,
            child: RegisterScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/verify-code',
        pageBuilder: (context, state) {
          print('App: Navigating to /verify-code');
          return CustomTransitionPage(
            key: state.pageKey,
            child: VerifyCodeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/main',
        pageBuilder: (context, state) {
          print('App: Navigating to /main');
          return CustomTransitionPage(
            key: state.pageKey,
            child: MainScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/admin',
        pageBuilder: (context, state) {
          print('App: Navigating to /admin');
          return CustomTransitionPage(
            key: state.pageKey,
            child: AdminPanelScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/admin/add-test-type',
        pageBuilder: (context, state) {
          print('App: Navigating to /admin/add-test-type');
          return CustomTransitionPage(
            key: state.pageKey,
            child: AdminAddTestTypeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/admin/edit-test-type',
        pageBuilder: (context, state) {
          print('App: Navigating to /admin/edit-test-type');
          return CustomTransitionPage(
            key: state.pageKey,
            child: AdminEditTestTypeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/admin/add-category',
        pageBuilder: (context, state) {
          print('App: Navigating to /admin/add-category');
          return CustomTransitionPage(
            key: state.pageKey,
            child: AdminAddCategoryScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/admin/edit-category',
        pageBuilder: (context, state) {
          print('App: Navigating to /admin/edit-category');
          return CustomTransitionPage(
            key: state.pageKey,
            child: AdminEditCategoryScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/admin/add-question',
        pageBuilder: (context, state) {
          print('App: Navigating to /admin/add-question');
          return CustomTransitionPage(
            key: state.pageKey,
            child: AdminAddQuestionScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/admin/edit-question',
        pageBuilder: (context, state) {
          print('App: Navigating to /admin/edit-question');
          return CustomTransitionPage(
            key: state.pageKey,
            child: AdminEditQuestionScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/admin/add-contest',
        pageBuilder: (context, state) {
          print('App: Navigating to /admin/add-contest');
          return CustomTransitionPage(
            key: state.pageKey,
            child: AdminAddContestScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/admin/edit-contest',
        pageBuilder: (context, state) {
          print('App: Navigating to /admin/edit-contest');
          return CustomTransitionPage(
            key: state.pageKey,
            child: AdminEditContestScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/admin/add-study-material',
        pageBuilder: (context, state) {
          print('App: Navigating to /admin/add-study-material');
          return CustomTransitionPage(
            key: state.pageKey,
            child: AdminAddStudyMaterialScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/admin/edit-study-material',
        pageBuilder: (context, state) {
          print('App: Navigating to /admin/edit-study-material');
          return CustomTransitionPage(
            key: state.pageKey,
            child: AdminEditStudyMaterialScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/training',
        pageBuilder: (context, state) {
          print('App: Navigating to /training');
          return CustomTransitionPage(
            key: state.pageKey,
            child: TrainingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/contests',
        pageBuilder: (context, state) {
          print('App: Navigating to /contests');
          return CustomTransitionPage(
            key: state.pageKey,
            child: ContestsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/history',
        pageBuilder: (context, state) {
          print('App: Navigating to /history');
          return CustomTransitionPage(
            key: state.pageKey,
            child: HistoryScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) {
          print('App: Navigating to /settings');
          return CustomTransitionPage(
            key: state.pageKey,
            child: SettingsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/results',
        pageBuilder: (context, state) {
          print('App: Navigating to /results');
          return CustomTransitionPage(
            key: state.pageKey,
            child: ResultsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/test',
        pageBuilder: (context, state) {
          print('App: Navigating to /test');
          return CustomTransitionPage(
            key: state.pageKey,
            child: TestScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    print('App: Building MaterialApp.router');
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          print('App: Rendering with themeMode: ${themeProvider.themeMode}');
          return MaterialApp.router(
            routerConfig: _router,
            title: 'Testing Platform',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
          );
        },
      ),
    );
  }
}