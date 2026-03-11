import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/app_card.dart';

class SurveysPage extends StatelessWidget {
  const SurveysPage({super.key});

  static const _surveys = [
    _SurveyOffer(title: 'Shopping Habits 2026', provider: 'MarketPulse', icon: '🛒', duration: '5 min', reward: 50, color: Color(0xFF007AFF)),
    _SurveyOffer(title: 'Tech Usage Survey', provider: 'TechInsights', icon: '📱', duration: '8 min', reward: 120, color: Color(0xFF5856D6)),
    _SurveyOffer(title: 'Food & Lifestyle', provider: 'NutriStudy', icon: '🥗', duration: '3 min', reward: 30, color: Color(0xFF34C759)),
    _SurveyOffer(title: 'Travel Preferences', provider: 'TravelQ', icon: '✈️', duration: '6 min', reward: 80, color: Color(0xFFFF9500)),
    _SurveyOffer(title: 'Streaming & Media', provider: 'MediaWatch', icon: '🎬', duration: '4 min', reward: 45, color: Color(0xFFE50914)),
    _SurveyOffer(title: 'Financial Wellness', provider: 'FinScope', icon: '💰', duration: '10 min', reward: 200, color: Color(0xFF00875A)),
    _SurveyOffer(title: 'Social Media Usage', provider: 'SocialMetrics', icon: '📊', duration: '5 min', reward: 60, color: Color(0xFFFF2D55)),
    _SurveyOffer(title: 'Gaming Preferences', provider: 'GamePoll', icon: '🎮', duration: '7 min', reward: 90, color: Color(0xFF5AC8FA)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                itemCount: _surveys.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _SurveyCard(survey: _surveys[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back_rounded, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Text('Surveys', style: AppTypography.headlineLarge),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppColors.coinLight, borderRadius: BorderRadius.circular(8)),
            child: Text('${_surveys.length} available', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.coin)),
          ),
        ],
      ),
    );
  }
}

class _SurveyOffer {
  final String title;
  final String provider;
  final String icon;
  final String duration;
  final int reward;
  final Color color;
  const _SurveyOffer({required this.title, required this.provider, required this.icon, required this.duration, required this.reward, required this.color});
}

class _SurveyCard extends StatelessWidget {
  final _SurveyOffer survey;
  const _SurveyCard({required this.survey});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: survey.color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(survey.icon, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(survey.title, style: AppTypography.headlineSmall),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(survey.provider, style: AppTypography.caption.copyWith(fontSize: 11)),
                    const SizedBox(width: 8),
                    Container(width: 3, height: 3, decoration: BoxDecoration(color: AppColors.textTertiary, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Icon(Icons.timer_outlined, size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 3),
                    Text(survey.duration, style: AppTypography.caption.copyWith(fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14, height: 14,
                    decoration: const BoxDecoration(gradient: AppColors.coinGradient, shape: BoxShape.circle),
                    child: const Center(child: Text('M', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w800, color: Colors.white))),
                  ),
                  const SizedBox(width: 4),
                  Text('+${survey.reward}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.coin)),
                ],
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Starting "${survey.title}"...'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    margin: const EdgeInsets.all(16),
                  ));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(color: survey.color, borderRadius: BorderRadius.circular(8)),
                  child: const Text('Start', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
