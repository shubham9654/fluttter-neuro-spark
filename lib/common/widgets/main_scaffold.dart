import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

/// Main Scaffold with Bottom Navigation
/// Wrapper for all main pages with consistent navigation
class MainScaffold extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const MainScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: widget.currentIndex,
            onTap: (index) => _onItemTapped(context, index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textLight,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: FaIcon(FontAwesomeIcons.house, size: 22),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: FaIcon(FontAwesomeIcons.house, size: 24),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: FaIcon(FontAwesomeIcons.brain, size: 22),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: FaIcon(FontAwesomeIcons.brain, size: 24),
                ),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: FaIcon(FontAwesomeIcons.shop, size: 22),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: FaIcon(FontAwesomeIcons.shop, size: 24),
                ),
                label: 'Shop',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: FaIcon(FontAwesomeIcons.gear, size: 22),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: FaIcon(FontAwesomeIcons.gear, size: 24),
                ),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    if (widget.currentIndex == index) return; // Don't navigate if already on tab
    
    // Use GoRouter for navigation
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/dashboard/inbox');
        break;
      case 2:
        context.go('/shop');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }
}

