import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/providers/app_providers.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/surface_card.dart';
import '../../design_system/widgets/primary_button.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../design_system/widgets/app_toast.dart';
import '../../core/utils/formatters.dart';
import '../../models/offerwall_item_model.dart';

class OfferDetailScreen extends ConsumerWidget {
  final OfferwallItemModel offer;
  const OfferDetailScreen({super.key, required this.offer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentOffer = ref.watch(offerwallProvider).firstWhere(
      (o) => o.id == offer.id,
      orElse: () => offer,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMid,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Text('Offer Details', style: AppTypography.headlineLarge)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(currentOffer.icon, size: 36, color: AppColors.primary),
                        ),
                      ).animate().scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 400.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 20),
                      Center(child: Text(currentOffer.title, style: AppTypography.headlineLarge, textAlign: TextAlign.center)),
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(currentOffer.type.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary)),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SurfaceCard(
                        padding: const EdgeInsets.all(20),
                        borderColor: AppColors.success.withValues(alpha: 0.15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('+${Formatters.number(currentOffer.rewardPoints)}', style: AppTypography.number.copyWith(fontSize: 28)),
                            const SizedBox(width: 8),
                            Text('points', style: AppTypography.bodyMedium),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text('What to do', style: AppTypography.headlineMedium),
                      const SizedBox(height: 12),
                      SurfaceCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(currentOffer.description, style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary)),
                            const SizedBox(height: 16),
                            _Step(number: '1', text: _getStep1(currentOffer)),
                            const SizedBox(height: 10),
                            _Step(number: '2', text: _getStep2(currentOffer)),
                            const SizedBox(height: 10),
                            _Step(number: '3', text: 'Points will be credited automatically within 24h'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Important', style: AppTypography.headlineMedium),
                      const SizedBox(height: 12),
                      SurfaceCard(
                        padding: const EdgeInsets.all(16),
                        borderColor: AppColors.warning.withValues(alpha: 0.15),
                        child: Column(
                          children: [
                            _Note(icon: Icons.new_releases_outlined, text: 'Must be a new user of this service'),
                            const SizedBox(height: 8),
                            _Note(icon: Icons.timer_outlined, text: 'Complete within 30 days of starting'),
                            const SizedBox(height: 8),
                            _Note(icon: Icons.link_rounded, text: 'Use our link to get tracked properly'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        label: _buttonLabel(currentOffer.status),
                        enabled: currentOffer.status != OfferStatus.completed,
                        gradient: currentOffer.status == OfferStatus.completed ? AppColors.successGradient : AppColors.primaryGradient,
                        icon: currentOffer.status == OfferStatus.completed
                            ? Icons.check_circle_rounded
                            : currentOffer.status == OfferStatus.inProgress
                                ? Icons.open_in_new_rounded
                                : Icons.open_in_new_rounded,
                        onPressed: () async {
                          HapticFeedback.heavyImpact();
                          if (currentOffer.status == OfferStatus.available) {
                            ref.read(offerwallProvider.notifier).startOffer(currentOffer.id);
                          }
                          if (currentOffer.actionUrl != null) {
                            final uri = Uri.tryParse(currentOffer.actionUrl!);
                            if (uri != null) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          }
                          if (context.mounted) {
                            AppToast.show(context, message: 'Offer started! Complete the steps to earn points.', type: ToastType.success);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            AppToast.show(context, message: 'Report submitted. We\'ll look into it.', type: ToastType.info);
                          },
                          child: Text('Report an issue', style: AppTypography.labelMedium.copyWith(color: AppColors.textTertiary)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStep1(OfferwallItemModel o) {
    switch (o.type) {
      case OfferType.installApp:
      case OfferType.reachLevel:
        return 'Download and install the app via our link';
      case OfferType.register:
        return 'Click the link and create a new account';
      case OfferType.subscribe:
        return 'Visit the service through our link';
      case OfferType.survey:
        return 'Click start and answer all questions honestly';
    }
  }

  String _getStep2(OfferwallItemModel o) {
    switch (o.type) {
      case OfferType.installApp:
        return 'Open the app and complete the tutorial';
      case OfferType.reachLevel:
        return 'Play and reach the required level/milestone';
      case OfferType.register:
        return 'Verify your email and complete profile setup';
      case OfferType.subscribe:
        return 'Choose a plan and complete the subscription';
      case OfferType.survey:
        return 'Complete the entire survey (~3-10 min)';
    }
  }

  String _buttonLabel(OfferStatus status) {
    switch (status) {
      case OfferStatus.available:
        return 'Start Offer';
      case OfferStatus.inProgress:
        return 'Continue';
      case OfferStatus.completed:
        return 'Completed';
    }
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String text;
  const _Step({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: Text(number, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(text, style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary)),
        )),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Note({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.warning),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary))),
      ],
    );
  }
}
