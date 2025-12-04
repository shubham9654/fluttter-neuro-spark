import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/theme/text_styles.dart';
import '../../../../common/widgets/themed_button.dart';
import '../../../../common/widgets/progress_header.dart';
import '../../../../common/widgets/custom_card.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/utils/hive_service.dart';
import '../../../../common/utils/haptic_helper.dart';
import '../../data/models/neurotype_profile.dart';

/// Screen 2: Dopamine Profile Setup
/// FR-A1: Neuro-type Assessment
class NeuroTypeSetupPage extends StatefulWidget {
  const NeuroTypeSetupPage({super.key});

  @override
  State<NeuroTypeSetupPage> createState() => _NeuroTypeSetupPageState();
}

class _NeuroTypeSetupPageState extends State<NeuroTypeSetupPage> {
  final Set<StruggleType> _selectedStruggles = {};

  // Map struggle types to icons
  final Map<StruggleType, IconData> _struggleIcons = {
    StruggleType.paralysis: FontAwesomeIcons.handsClapping,
    StruggleType.overwhelm: FontAwesomeIcons.headSideMask,
    StruggleType.timeCeacuity: FontAwesomeIcons.clock,
    StruggleType.procrastination: FontAwesomeIcons.hourglassHalf,
    StruggleType.hyperfocus: FontAwesomeIcons.crosshairs,
    StruggleType.motivation: FontAwesomeIcons.batteryEmpty,
  };

  void _toggleStruggle(StruggleType struggle) async {
    await HapticHelper.lightImpact();
    setState(() {
      if (_selectedStruggles.contains(struggle)) {
        _selectedStruggles.remove(struggle);
      } else {
        _selectedStruggles.add(struggle);
      }
    });
  }

  Future<void> _continue() async {
    if (_selectedStruggles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one struggle'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      await HapticHelper.error();
      return;
    }

    await HapticHelper.mediumImpact();

    // Save neurotype profile
    final profile = NeurotypeProfile(
      selectedStruggles: _selectedStruggles.toList(),
      createdAt: DateTime.now(),
    );
    await HiveService.saveNeurotypeProfile(profile);

    if (mounted) {
      context.push('/onboarding/energy');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header with progress
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: ProgressHeader(
                currentStep: 1,
                totalSteps: 2,
                title: 'Tell Us About You',
                subtitle: 'Select all that apply. This helps us personalize your experience.',
                onBack: () => context.pop(),
              ),
            ),

            // Selection grid
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingL,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppConstants.paddingM),
                    
                    // Grid of struggle cards
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: AppConstants.paddingM,
                      mainAxisSpacing: AppConstants.paddingM,
                      childAspectRatio: 0.9,
                      children: StruggleType.values.map((struggle) {
                        final isSelected = _selectedStruggles.contains(struggle);
                        return SelectionCard(
                          title: struggle.displayName,
                          icon: _struggleIcons[struggle]!,
                          isSelected: isSelected,
                          onTap: () => _toggleStruggle(struggle),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppConstants.paddingL),

                    // Help text
                    Container(
                      padding: const EdgeInsets.all(AppConstants.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(
                          AppConstants.cardBorderRadius,
                        ),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: AppConstants.paddingM),
                          Expanded(
                            child: Text(
                              'Be honest! The more we know, the better we can help you succeed.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.paddingXL),
                  ],
                ),
              ),
            ),

            // Bottom button
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingL),
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
              child: Column(
                children: [
                  // Selected count
                  if (_selectedStruggles.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppConstants.paddingM,
                      ),
                      child: Text(
                        '${_selectedStruggles.length} selected',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                  // Continue button
                  ThemedPrimaryButton(
                    text: 'Continue',
                    onPressed: _continue,
                    isExpanded: true,
                    icon: Icons.arrow_forward_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

