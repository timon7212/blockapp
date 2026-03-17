import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/auth_notifier.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/dto/user_dto.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/surface_card.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../design_system/widgets/app_toast.dart';

final _userRepoProvider = Provider((_) => UserRepository());

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _displayNameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;
    _displayNameController =
        TextEditingController(text: user?.displayName ?? '');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  void _save() async {
    final name = _displayNameController.text.trim();
    if (name.isEmpty) {
      AppToast.show(context,
          message: 'Name cannot be empty', type: ToastType.error);
      return;
    }
    setState(() => _isSaving = true);
    try {
      await ref
          .read(_userRepoProvider)
          .updateProfile(UpdateProfileRequest(displayName: name));
      ref.read(authNotifierProvider.notifier).refreshProfile();
      HapticFeedback.mediumImpact();
      if (mounted) {
        AppToast.show(context,
            message: 'Profile updated', type: ToastType.success);
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Update profile failed: $e');
      if (mounted) {
        AppToast.show(context,
            message: 'Update failed: ${e.toString()}',
            type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    SurfaceCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text('Display Name',
                              style: AppTypography.labelMedium),
                          const SizedBox(height: 8),
                          _field(_displayNameController),
                        ],
                      ),
                    ).animate().fadeIn(
                        duration: 400.ms, delay: 100.ms),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _isSaving ? null : _save,
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: _isSaving
                              ? null
                              : AppColors.primaryGradient,
                          color: _isSaving
                              ? AppColors.surfaceLight
                              : null,
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors
                                        .textSecondary,
                                  ),
                                )
                              : Text('Save Changes',
                                  style: AppTypography.button
                                      .copyWith(
                                          color: AppColors
                                              .textInverse)),
                        ),
                      ),
                    ).animate().fadeIn(
                        duration: 400.ms, delay: 200.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller) {
    return TextField(
      controller: controller,
      style: AppTypography.bodyLarge
          .copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceMid,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).pop();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceMid,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.textPrimary, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Text('Edit Profile',
              style: AppTypography.headlineLarge),
        ],
      ),
    );
  }
}
