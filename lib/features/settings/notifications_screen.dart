import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/surface_card.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../services/storage_service.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late bool _streakAlerts;
  late bool _pointsReady;
  late bool _dailyGoals;
  late bool _raffleResults;
  late bool _referralActivity;
  late bool _milestones;
  late bool _newOffers;
  late bool _weeklySummary;

  @override
  void initState() {
    super.initState();
    _streakAlerts = true; // Always on by default — most important for retention
    _pointsReady = StorageService.notifPointsReady;
    _dailyGoals = true;
    _raffleResults = StorageService.notifRaffleResults;
    _referralActivity = StorageService.notifReferral;
    _milestones = true;
    _newOffers = StorageService.notifNewOffers;
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
                    // Critical notifications section
                    Text('Critical',
                        style: AppTypography.labelMedium
                            .copyWith(color: AppColors.textTertiary)),
                    const SizedBox(height: 8),
                    SurfaceCard(
                      padding: EdgeInsets.zero,
                      borderColor: AppColors.error.withValues(alpha: 0.15),
                      child: Column(
                        children: [
                          _toggle(
                            icon: Icons.local_fire_department_rounded,
                            iconColor: AppColors.warning,
                            label: NotifChannel.streak.displayName,
                            subtitle: NotifChannel.streak.description,
                            value: _streakAlerts,
                            onChanged: (v) =>
                                setState(() => _streakAlerts = v),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 20),

                    // Engagement notifications
                    Text('Engagement',
                        style: AppTypography.labelMedium
                            .copyWith(color: AppColors.textTertiary)),
                    const SizedBox(height: 8),
                    SurfaceCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _toggle(
                            icon: Icons.bolt_rounded,
                            iconColor: AppColors.success,
                            label: NotifChannel.points.displayName,
                            subtitle: NotifChannel.points.description,
                            value: _pointsReady,
                            onChanged: (v) {
                              setState(() => _pointsReady = v);
                              StorageService.setNotifPointsReady(v);
                            },
                          ),
                          _divider(),
                          _toggle(
                            icon: Icons.flag_rounded,
                            iconColor: AppColors.primary,
                            label: NotifChannel.dailyGoals.displayName,
                            subtitle: NotifChannel.dailyGoals.description,
                            value: _dailyGoals,
                            onChanged: (v) =>
                                setState(() => _dailyGoals = v),
                          ),
                          _divider(),
                          _toggle(
                            icon: Icons.emoji_events_rounded,
                            iconColor: AppColors.accent,
                            label: NotifChannel.raffle.displayName,
                            subtitle: NotifChannel.raffle.description,
                            value: _raffleResults,
                            onChanged: (v) {
                              setState(() => _raffleResults = v);
                              StorageService.setNotifRaffleResults(v);
                            },
                          ),
                          _divider(),
                          _toggle(
                            icon: Icons.people_rounded,
                            iconColor: AppColors.primary,
                            label: NotifChannel.social.displayName,
                            subtitle: NotifChannel.social.description,
                            value: _referralActivity,
                            onChanged: (v) {
                              setState(() => _referralActivity = v);
                              StorageService.setNotifReferral(v);
                            },
                          ),
                          _divider(),
                          _toggle(
                            icon: Icons.emoji_events_outlined,
                            iconColor: AppColors.success,
                            label: NotifChannel.milestone.displayName,
                            subtitle: NotifChannel.milestone.description,
                            value: _milestones,
                            onChanged: (v) =>
                                setState(() => _milestones = v),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                    const SizedBox(height: 20),

                    // Other notifications
                    Text('Other',
                        style: AppTypography.labelMedium
                            .copyWith(color: AppColors.textTertiary)),
                    const SizedBox(height: 8),
                    SurfaceCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _toggle(
                            icon: Icons.local_offer_outlined,
                            iconColor: AppColors.textSecondary,
                            label: 'New Offers',
                            subtitle: 'When new tasks are available',
                            value: _newOffers,
                            onChanged: (v) {
                              setState(() => _newOffers = v);
                              StorageService.setNotifNewOffers(v);
                            },
                          ),
                          _divider(),
                          _toggle(
                            icon: Icons.summarize_outlined,
                            iconColor: AppColors.textSecondary,
                            label: 'Weekly Summary',
                            subtitle: 'Your weekly earnings report',
                            value: _weeklySummary,
                            onChanged: (v) {
                              setState(() => _weeklySummary = v);
                              StorageService.setNotifWeeklySummary(v);
                            },
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                    const SizedBox(height: 16),

                    // Info card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMuted,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 18, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'We recommend keeping Streak Alerts on — it\'s the #1 way to protect your progress!',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() =>
      Divider(height: 1, color: AppColors.border, indent: 52);

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
          Text('Notifications', style: AppTypography.headlineLarge),
        ],
      ),
    );
  }

  Widget _toggle({
    required IconData icon,
    Color? iconColor,
    required String label,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor ?? AppColors.textSecondary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTypography.bodyLarge
                        .copyWith(color: AppColors.textPrimary, fontSize: 14)),
                if (subtitle != null)
                  Text(subtitle,
                      style: AppTypography.caption.copyWith(fontSize: 11)),
              ],
            ),
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
                border: Border.all(
                    color: value ? AppColors.primary : AppColors.border),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment:
                    value ? Alignment.centerRight : Alignment.centerLeft,
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
