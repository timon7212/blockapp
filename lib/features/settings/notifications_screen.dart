import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/surface_card.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../services/storage_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late bool _pointsReady;
  late bool _raffleResults;
  late bool _newOffers;
  late bool _referralActivity;
  late bool _weeklySummary;

  @override
  void initState() {
    super.initState();
    _pointsReady = StorageService.notifPointsReady;
    _raffleResults = StorageService.notifRaffleResults;
    _newOffers = StorageService.notifNewOffers;
    _referralActivity = StorageService.notifReferral;
    _weeklySummary = StorageService.notifWeeklySummary;
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
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    SurfaceCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _toggle(
                            icon: Icons.monetization_on_outlined,
                            label: 'Points Ready to Claim',
                            value: _pointsReady,
                            onChanged: (v) {
                              setState(() => _pointsReady = v);
                              StorageService.setNotifPointsReady(v);
                            },
                          ),
                          Divider(height: 1, color: AppColors.border, indent: 52),
                          _toggle(
                            icon: Icons.emoji_events_outlined,
                            label: 'Raffle Results',
                            value: _raffleResults,
                            onChanged: (v) {
                              setState(() => _raffleResults = v);
                              StorageService.setNotifRaffleResults(v);
                            },
                          ),
                          Divider(height: 1, color: AppColors.border, indent: 52),
                          _toggle(
                            icon: Icons.local_offer_outlined,
                            label: 'New Offers Available',
                            value: _newOffers,
                            onChanged: (v) {
                              setState(() => _newOffers = v);
                              StorageService.setNotifNewOffers(v);
                            },
                          ),
                          Divider(height: 1, color: AppColors.border, indent: 52),
                          _toggle(
                            icon: Icons.people_outline_rounded,
                            label: 'Referral Activity',
                            value: _referralActivity,
                            onChanged: (v) {
                              setState(() => _referralActivity = v);
                              StorageService.setNotifReferral(v);
                            },
                          ),
                          Divider(height: 1, color: AppColors.border, indent: 52),
                          _toggle(
                            icon: Icons.summarize_outlined,
                            label: 'Weekly Summary',
                            value: _weeklySummary,
                            onChanged: (v) {
                              setState(() => _weeklySummary = v);
                              StorageService.setNotifWeeklySummary(v);
                            },
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                  ],
                ),
              ),
            ],
          ),
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
              child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Text('Notifications', style: AppTypography.headlineLarge),
        ],
      ),
    );
  }

  Widget _toggle({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary)),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(!value);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: value ? AppColors.primary : AppColors.surfaceLight,
                border: Border.all(color: value ? AppColors.primary : AppColors.border),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: value ? Colors.white : AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
