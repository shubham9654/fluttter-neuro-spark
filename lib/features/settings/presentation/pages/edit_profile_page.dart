import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/theme/text_styles.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/utils/haptic_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/providers/game_stats_providers.dart';
import '../../../../core/services/firestore_service.dart';

/// Edit Profile Page
/// User can edit their profile information and avatar
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  bool _isSaving = false;
  final _firestore = FirestoreService();

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _bioController = TextEditingController(text: '');
    _loadUserProfile();
  }
  
  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    try {
      final firestore = FirebaseFirestore.instance;
      final userDoc = await firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && mounted) {
          setState(() {
            _bioController.text = data['bio'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final gameStats = ref.watch(gameStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar Section
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 57,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? Text(
                              (user?.displayName?[0] ?? 'N').toUpperCase(),
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          HapticHelper.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Photo upload coming soon!'),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.paddingL),

            // Level Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accentPurple],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.bolt,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Level ${gameStats.level}',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.paddingXL),

            // Form Section
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingL),

                  // Display Name
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Display Name',
                      prefixIcon: const Icon(Icons.person_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingM),

                  // Email (Read-only)
                  TextField(
                    controller: _emailController,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: 'Email cannot be changed',
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingM),

                  // Bio
                  TextField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      hintText: 'Tell us about yourself...',
                      prefixIcon: const Icon(Icons.notes_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: 'Max 150 characters',
                    ),
                    maxLength: 150,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.paddingXL),

            // Stats Overview
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Stats',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  _buildStatRow(
                    icon: FontAwesomeIcons.fire,
                    label: 'Current Streak',
                    value: '${gameStats.currentStreak} days',
                    color: AppColors.warningOrange,
                  ),
                  const Divider(height: 24),
                  _buildStatRow(
                    icon: FontAwesomeIcons.trophy,
                    label: 'Best Streak',
                    value: '${gameStats.longestStreak} days',
                    color: AppColors.accentYellow,
                  ),
                  const Divider(height: 24),
                  _buildStatRow(
                    icon: FontAwesomeIcons.checkCircle,
                    label: 'Tasks Completed',
                    value: '${gameStats.tasksCompleted}',
                    color: AppColors.successGreen,
                  ),
                  const Divider(height: 24),
                  _buildStatRow(
                    icon: FontAwesomeIcons.clock,
                    label: 'Focus Time',
                    value: '${gameStats.totalFocusMinutes} min',
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.paddingXL),

            // Delete Account
            TextButton.icon(
              onPressed: () {
                _showDeleteAccountDialog(context);
              },
              icon: const Icon(Icons.delete_forever_rounded),
              label: const Text('Delete Account'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.errorRed,
              ),
            ),

            const SizedBox(height: AppConstants.paddingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: FaIcon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AppConstants.paddingM),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.titleSmall.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;
    
    if (!mounted) return;
    
    setState(() {
      _isSaving = true;
    });
    
    HapticHelper.mediumImpact();
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Update display name in Firebase Auth
      final newDisplayName = _nameController.text.trim();
      if (newDisplayName.isNotEmpty && newDisplayName != user.displayName) {
        try {
          await user.updateDisplayName(newDisplayName);
          await user.reload();
          debugPrint('✅ Display name updated in Firebase Auth');
        } catch (e) {
          debugPrint('⚠️ Warning: Could not update display name in Auth: $e');
          // Continue even if Auth update fails
        }
      }
      
      // Update profile data in Firestore
      final updates = <String, dynamic>{
        'displayName': newDisplayName,
        'bio': _bioController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      bool firestoreSuccess = false;
      try {
        debugPrint('🔄 Attempting to save profile to Firestore...');
        debugPrint('📍 User ID: ${user.uid}');
        debugPrint('📍 Updates: ${updates.keys.join(", ")}');
        
        await _firestore.updateUserDocument(updates);
        debugPrint('✅ Profile saved to Firestore successfully');
        firestoreSuccess = true;
      } catch (firestoreError) {
        debugPrint('❌ Firestore update failed: $firestoreError');
        
        // Check if it's a permission error
        final errorString = firestoreError.toString().toLowerCase();
        if (errorString.contains('permission_denied') || 
            errorString.contains('api has not been used') ||
            errorString.contains('disabled')) {
          // Firestore API not enabled - show helpful message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Profile name updated! Note: Firestore API needs to be enabled for full sync.'),
                backgroundColor: AppColors.warningOrange,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } else {
          // Other Firestore error - show detailed error
          debugPrint('⚠️ Firestore error details: $firestoreError');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Firestore error: ${firestoreError.toString().substring(0, 100)}...'),
                backgroundColor: AppColors.errorRed,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      }
      
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(firestoreSuccess 
                ? 'Profile updated! 🎉' 
                : 'Profile name updated! (Some features may need Firestore enabled)'),
            backgroundColor: firestoreSuccess 
                ? AppColors.successGreen 
                : AppColors.warningOrange,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Wait a moment before popping to show the success message
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      debugPrint('❌ Error saving profile: $e');
      if (mounted) {
        final errorString = e.toString().toLowerCase();
        String errorMessage = 'Error updating profile: ${e.toString()}';
        
        if (errorString.contains('permission_denied') || 
            errorString.contains('api has not been used') ||
            errorString.contains('disabled')) {
          errorMessage = 'Firestore API not enabled. Please enable it in Google Cloud Console.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.errorRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete account logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion coming soon'),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

