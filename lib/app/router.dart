import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shared/widgets/app_shell.dart';
import '../features/tasks/presentation/screens/tasks_screen.dart';
import '../features/habits/presentation/screens/habits_screen.dart';
import '../features/journal/presentation/screens/journal_screen.dart';
import '../features/pomodoro/presentation/screens/pomodoro_screen.dart';
import '../features/music/presentation/screens/music_screen.dart';
import '../features/files/presentation/screens/files_screen.dart';

/// Route path constants — never hardcode route strings outside this file.
abstract final class AppRoutes {
  static const String tasks = '/tasks';
  static const String habits = '/habits';
  static const String journal = '/journal';
  static const String pomodoro = '/pomodoro';
  static const String music = '/music';
  static const String files = '/files';
}

/// Navigation destination model.
/// Drives both the desktop NavigationRail and mobile BottomNavigationBar.
class NavDestination {
  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const NavDestination({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

/// All top-level navigation destinations.
/// Order here determines render order in nav components.
const List<NavDestination> appDestinations = [
  NavDestination(
    path: AppRoutes.tasks,
    label: 'Tasks',
    icon: Icons.check_box_outline_blank_rounded,
    selectedIcon: Icons.check_box_rounded,
  ),
  NavDestination(
    path: AppRoutes.habits,
    label: 'Habits',
    icon: Icons.loop_outlined,
    selectedIcon: Icons.loop_rounded,
  ),
  NavDestination(
    path: AppRoutes.journal,
    label: 'Journal',
    icon: Icons.book_outlined,
    selectedIcon: Icons.book_rounded,
  ),
  NavDestination(
    path: AppRoutes.pomodoro,
    label: 'Focus',
    icon: Icons.timer_outlined,
    selectedIcon: Icons.timer_rounded,
  ),
  NavDestination(
    path: AppRoutes.music,
    label: 'Music',
    icon: Icons.music_note_outlined,
    selectedIcon: Icons.music_note_rounded,
  ),
  NavDestination(
    path: AppRoutes.files,
    label: 'Files',
    icon: Icons.folder_outlined,
    selectedIcon: Icons.folder_rounded,
  ),
];

/// GoRouter instance.
///
/// ShellRoute wraps all top-level routes in AppShell.
/// The shell (nav rail / bottom nav) persists across route transitions.
/// No shell rebuild on navigation — only the child content area re-renders.
///
/// Design decision: No nested navigators per feature yet.
/// If a feature needs its own sub-navigation stack (e.g. task detail),
/// add a nested ShellRoute inside that feature's route block.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.tasks,
  debugLogDiagnostics: false, // Set true during development if needed
  routes: [
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return AppShell(
          currentPath: state.matchedLocation,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: AppRoutes.tasks,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TasksScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.habits,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HabitsScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.journal,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: JournalScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.pomodoro,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PomodoroScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.music,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: MusicScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.files,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: FilesScreen(),
          ),
        ),
      ],
    ),
  ],
);