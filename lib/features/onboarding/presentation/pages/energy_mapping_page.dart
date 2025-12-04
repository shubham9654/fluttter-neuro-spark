import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/theme/text_styles.dart';
import '../../../../common/widgets/themed_button.dart';
import '../../../../common/widgets/progress_header.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/utils/hive_service.dart';
import '../../../../common/utils/haptic_helper.dart';
import '../../data/models/energy_block.dart';

/// Screen 3: Energy Mapping
/// FR-A2: Energy Mapping - Users define high and low energy blocks
class EnergyMappingPage extends StatefulWidget {
  const EnergyMappingPage({super.key});

  @override
  State<EnergyMappingPage> createState() => _EnergyMappingPageState();
}

class _EnergyMappingPageState extends State<EnergyMappingPage> {
  // Default energy blocks
  final List<EnergyBlock> _energyBlocks = [
    const EnergyBlock(
      startHour: 9,
      startMinute: 0,
      endHour: 12,
      endMinute: 0,
      energyLevel: EnergyLevel.high,
    ),
    const EnergyBlock(
      startHour: 14,
      startMinute: 0,
      endHour: 16,
      endMinute: 0,
      energyLevel: EnergyLevel.low,
    ),
  ];

  int? _selectedBlockIndex;

  Future<void> _saveSchedule() async {
    await HapticHelper.success();

    // Save energy map
    final energyMap = EnergyMap(
      blocks: _energyBlocks,
      createdAt: DateTime.now(),
    );
    await HiveService.saveEnergyMap(energyMap);
    await HiveService.completeOnboarding();

    if (mounted) {
      context.go('/dashboard');
    }
  }

  void _addBlock(EnergyLevel level) async {
    await HapticHelper.lightImpact();
    
    setState(() {
      // Add a new default block
      _energyBlocks.add(
        EnergyBlock(
          startHour: 10,
          startMinute: 0,
          endHour: 11,
          endMinute: 0,
          energyLevel: level,
        ),
      );
    });
  }

  void _deleteBlock(int index) async {
    await HapticHelper.mediumImpact();
    
    setState(() {
      _energyBlocks.removeAt(index);
      _selectedBlockIndex = null;
    });
  }

  void _updateBlock(int index, EnergyBlock newBlock) {
    setState(() {
      _energyBlocks[index] = newBlock;
    });
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
                currentStep: 2,
                totalSteps: 2,
                title: 'Map Your Energy',
                subtitle: 'When are you most productive? When do you need breaks?',
                onBack: () => context.pop(),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingL,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppConstants.paddingM),

                    // Legend
                    Row(
                      children: [
                        _LegendItem(
                          color: AppColors.goldenHour,
                          label: 'High Energy (Golden Hour)',
                          onTap: () => _addBlock(EnergyLevel.high),
                        ),
                        const SizedBox(width: AppConstants.paddingM),
                        _LegendItem(
                          color: AppColors.potatoHour,
                          label: 'Low Energy (Potato Hour)',
                          onTap: () => _addBlock(EnergyLevel.low),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppConstants.paddingL),

                    // Energy blocks list
                    if (_energyBlocks.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.paddingXL),
                          child: Text(
                            'Tap the legend above to add energy blocks',
                            style: AppTextStyles.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      ..._energyBlocks.asMap().entries.map((entry) {
                        final index = entry.key;
                        final block = entry.value;
                        return _EnergyBlockCard(
                          block: block,
                          isSelected: _selectedBlockIndex == index,
                          onTap: () {
                            setState(() {
                              _selectedBlockIndex = index;
                            });
                          },
                          onDelete: () => _deleteBlock(index),
                          onUpdate: (newBlock) => _updateBlock(index, newBlock),
                        );
                      }),

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
                            Icons.info_outline_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: AppConstants.paddingM),
                          Expanded(
                            child: Text(
                              'We\'ll suggest tasks during your high energy blocks and save lighter tasks for low energy times.',
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
              child: ThemedPrimaryButton(
                text: 'Save Schedule',
                onPressed: _saveSchedule,
                isExpanded: true,
                icon: Icons.check_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Legend Item Widget
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.labelSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.add, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Energy Block Card Widget
class _EnergyBlockCard extends StatelessWidget {
  final EnergyBlock block;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Function(EnergyBlock) onUpdate;

  const _EnergyBlockCard({
    required this.block,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final blockColor = block.energyLevel == EnergyLevel.high
        ? AppColors.goldenHour
        : AppColors.potatoHour;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.borderLight,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Row(
              children: [
                // Color indicator
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: blockColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingM),

                // Time display
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        block.energyLevel == EnergyLevel.high
                            ? 'High Energy'
                            : 'Low Energy',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: blockColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${block.startTimeFormatted} - ${block.endTimeFormatted}',
                        style: AppTextStyles.bodyMedium,
                      ),
                      Text(
                        '${block.durationMinutes} minutes',
                        style: AppTextStyles.captionText,
                      ),
                    ],
                  ),
                ),

                // Delete button
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: AppColors.errorRed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

