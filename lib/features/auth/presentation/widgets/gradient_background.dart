import 'package:flutter/material.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/utils/constants.dart';

/// Breathing Gradient Background
/// Animated gradient that pulses to create a calming effect
class BreathingGradientBackground extends StatefulWidget {
  const BreathingGradientBackground({super.key});

  @override
  State<BreathingGradientBackground> createState() =>
      _BreathingGradientBackgroundState();
}

class _BreathingGradientBackgroundState
    extends State<BreathingGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(
        milliseconds: AppConstants.breathingAnimationDuration,
      ),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  AppColors.backgroundLight,
                  AppColors.primary.withOpacity(0.1),
                  _animation.value,
                )!,
                Color.lerp(
                  AppColors.backgroundLight,
                  AppColors.primaryLight.withOpacity(0.15),
                  _animation.value,
                )!,
                AppColors.backgroundLight,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

