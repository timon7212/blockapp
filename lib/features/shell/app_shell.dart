import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/app_providers.dart';
import '../../design_system/colors/app_colors.dart';
import '../home/home_screen.dart';
import '../raffles/raffles_screen.dart';
import '../store/store_screen.dart';
import '../network/network_screen.dart';
import '../profile/profile_screen.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const _screens = [
    HomeScreen(),
    RafflesScreen(),
    StoreScreen(),
    NetworkScreen(),
    ProfileScreen(),
  ];

  static const _tabs = [
    _TabDef(Icons.home_rounded, Icons.home_outlined, 'Home'),
    _TabDef(Icons.emoji_events_rounded, Icons.emoji_events_outlined, 'Raffles'),
    _TabDef(Icons.storefront_rounded, Icons.storefront_outlined, 'Store'),
    _TabDef(Icons.people_rounded, Icons.people_outline_rounded, 'Network'),
    _TabDef(Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(currentTabProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: KeyedSubtree(
          key: ValueKey<int>(tab),
          child: _screens[tab],
        ),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: tab,
        onTap: (i) {
          HapticFeedback.selectionClick();
          ref.read(currentTabProvider.notifier).state = i;
        },
      ),
    );
  }
}

class _TabDef {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  const _TabDef(this.activeIcon, this.inactiveIcon, this.label);
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.9),
            border: Border(top: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: List.generate(AppShell._tabs.length, (i) {
                  final def = AppShell._tabs[i];
                  final active = i == currentIndex;
                  return _NavItem(
                    icon: active ? def.activeIcon : def.inactiveIcon,
                    label: def.label,
                    active: active,
                    onTap: () => onTap(i),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: active ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: active ? AppColors.primary : AppColors.navInactive,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? AppColors.primary : AppColors.navInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
