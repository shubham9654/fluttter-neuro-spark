import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../utils/haptic_helper.dart';

/// Bottom Navigation Bar for main app screens
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  
  const AppBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.dashboard_rounded,
                label: 'Now',
                isSelected: currentIndex == 0,
                onTap: () async {
                  await HapticHelper.lightImpact();
                  onTap(0);
                },
              ),
              _NavBarItem(
                icon: FontAwesomeIcons.brain,
                label: 'Inbox',
                isSelected: currentIndex == 1,
                onTap: () async {
                  await HapticHelper.lightImpact();
                  onTap(1);
                },
              ),
              _NavBarItem(
                icon: FontAwesomeIcons.users,
                label: 'Together',
                isSelected: currentIndex == 2,
                onTap: () async {
                  await HapticHelper.lightImpact();
                  onTap(2);
                },
              ),
              _NavBarItem(
                icon: Icons.store_rounded,
                label: 'Shop',
                isSelected: currentIndex == 3,
                onTap: () async {
                  await HapticHelper.lightImpact();
                  onTap(3);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isSelected ? AppColors.primary : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

