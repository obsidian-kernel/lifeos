import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Root shell widget that wraps all top-level screens.
///
/// Design decisions:
/// - Desktop: Persistent NavigationRail on the left. Content fills the right.
/// - Mobile: BottomNavigationBar. Content fills above.
/// - Breakpoint at 600px logical width. Below = mobile, above = desktop.
/// - NoTransitionPage on all routes — instant switch, no slide animations.
///   This is a productivity tool, not a showcase. Speed > transition polish.
/// - Keyboard shortcuts registered here for desktop navigation.
///   Ctrl+1 through Ctrl+6 jump to each module.
class AppShell extends StatelessWidget {
  final String currentPath;
  final Widget child;

  const AppShell({
    super.key,
    required this.currentPath,
    required this.child,
  });

  int get _currentIndex {
    final index = appDestinations.indexWhere((d) => d.path == currentPath);
    return index < 0 ? 0 : index;
  }

  void _navigate(BuildContext context, int index) {
    final destination = appDestinations[index];
    if (currentPath != destination.path) {
      context.go(destination.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 600;

    return CallbackShortcuts(
      bindings: {
        // Ctrl+1 through Ctrl+6 for instant module switching on desktop
        for (int i = 0; i < appDestinations.length; i++)
          SingleActivator(
            LogicalKeyboardKey(0x00000031 + i), // '1' through '6'
            control: true,
          ): () => _navigate(context, i),
      },
      child: Focus(
        autofocus: true,
        child: isDesktop
            ? _DesktopShell(
                currentIndex: _currentIndex,
                onDestinationSelected: (i) => _navigate(context, i),
                child: child,
              )
            : _MobileShell(
                currentIndex: _currentIndex,
                onDestinationSelected: (i) => _navigate(context, i),
                child: child,
              ),
      ),
    );
  }
}

/// Desktop layout: NavigationRail + content area.
class _DesktopShell extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  const _DesktopShell({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: AppColors.surface,
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.selected,
            minWidth: 64,
            selectedLabelTextStyle: AppTypography.labelLarge.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelTextStyle: AppTypography.labelSmall,
            selectedIconTheme: const IconThemeData(
              color: AppColors.accent,
              size: 22,
            ),
            unselectedIconTheme: const IconThemeData(
              color: AppColors.onSurfaceMuted,
              size: 20,
            ),
            indicatorColor: AppColors.accentMuted,
            leading: const SizedBox(height: 16),
            destinations: appDestinations
                .map(
                  (d) => NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: AppColors.border,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Mobile layout: Content + BottomNavigationBar.
class _MobileShell extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  const _MobileShell({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: NavigationBar(
          backgroundColor: AppColors.surface,
          selectedIndex: currentIndex,
          onDestinationSelected: onDestinationSelected,
          height: 60,
          elevation: 0,
          indicatorColor: AppColors.accentMuted,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: appDestinations
              .map(
                (d) => NavigationDestination(
                  icon: Icon(d.icon, color: AppColors.onSurfaceMuted, size: 20),
                  selectedIcon:
                      Icon(d.selectedIcon, color: AppColors.accent, size: 22),
                  label: d.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}