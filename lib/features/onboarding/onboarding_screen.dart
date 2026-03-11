import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../shared/providers/app_providers.dart';
import '../../models/blocked_app_model.dart';
import '../../models/user_model.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';

final _selectedAppsProvider = StateProvider<Set<String>>((ref) => {});
final _selectedExerciseProvider = StateProvider<ExerciseType?>((ref) => null);
final _selectedRepCountProvider = StateProvider<int>((ref) => 10);
final _selectedGoalProvider = StateProvider<String?>((ref) => null);

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  static const _totalPages = 6;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _completeOnboarding() {
    final selectedApps = ref.read(_selectedAppsProvider);
    final exercise = ref.read(_selectedExerciseProvider) ?? ExerciseType.pushUps;
    final repCount = ref.read(_selectedRepCountProvider);

    for (final appId in selectedApps) {
      final apps = ref.read(blockedAppsProvider);
      final app = apps.firstWhere((a) => a.id == appId, orElse: () => apps.first);
      if (!app.isActive) {
        ref.read(blockedAppsProvider.notifier).toggleApp(appId);
      }
    }

    final user = ref.read(userProvider);
    ref.read(userProvider.notifier).state = user.copyWith(
      preferredExercise: exercise,
      exerciseDifficulty: repCount,
    );

    ref.read(onboardingCompleteProvider.notifier).state = true;
  }

  bool get _canProceed {
    switch (_currentPage) {
      case 0:
        return true;
      case 1:
        return ref.watch(_selectedAppsProvider).isNotEmpty;
      case 2:
        return ref.watch(_selectedExerciseProvider) != null;
      case 3:
        return true;
      case 4:
        return ref.watch(_selectedGoalProvider) != null;
      case 5:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            if (_currentPage > 0 && _currentPage < _totalPages - 1)
              _TopBar(
                currentPage: _currentPage,
                totalPages: _totalPages,
                onBack: _previousPage,
              ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _WelcomeStep(onNext: _nextPage),
                  _SelectAppsStep(onNext: _nextPage),
                  _ChooseExerciseStep(onNext: _nextPage),
                  _RepCountStep(onNext: _nextPage),
                  _GoalStep(onNext: _nextPage),
                  _CelebrationStep(onComplete: _completeOnboarding),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Top Bar with Progress ───

class _TopBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onBack;

  const _TopBar({
    required this.currentPage,
    required this.totalPages,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentPage / (totalPages - 1);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: AppColors.textPrimary,
            splashRadius: 24,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: AppColors.border,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
              ),
            ),
          ),
          const SizedBox(width: 52),
        ],
      ),
    );
  }
}

// ─── Step 1: Welcome ───

class _WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;
  const _WelcomeStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 3),
          Text(
            '🛡️',
            style: const TextStyle(fontSize: 72),
          )
              .animate()
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1, 1),
                duration: 600.ms,
                curve: Curves.elasticOut,
              ),
          const SizedBox(height: 32),
          Text(
            'Vitality',
            style: AppTypography.displayLarge.copyWith(
              fontSize: 52,
              fontWeight: FontWeight.w800,
              letterSpacing: -2,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 200.ms)
              .slideY(begin: 0.3, end: 0, duration: 500.ms, delay: 200.ms),
          const SizedBox(height: 16),
          Text(
            'Block distracting apps.\nEarn rewards.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              fontSize: 20,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 400.ms)
              .slideY(begin: 0.3, end: 0, duration: 500.ms, delay: 400.ms),
          const SizedBox(height: 12),
          Text(
            'Do exercises to unlock your phone.\nStay focused & get fit.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 550.ms),
          const Spacer(flex: 4),
          _PrimaryButton(
            label: 'Start Quiz',
            onPressed: onNext,
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 700.ms)
              .slideY(begin: 0.4, end: 0, duration: 500.ms, delay: 700.ms),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

// ─── Step 2: Select Distracting Apps ───

class _SelectAppsStep extends ConsumerWidget {
  final VoidCallback onNext;
  const _SelectAppsStep({required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedApps = ref.watch(_selectedAppsProvider);
    final apps = defaultBlockableApps();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Which apps distract\nyou the most?',
            style: AppTypography.displaySmall.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 28,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideX(begin: -0.1, end: 0, duration: 400.ms),
          const SizedBox(height: 8),
          Text(
            'Select at least 1 app to block',
            style: AppTypography.bodyMedium,
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.2,
              ),
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
                final isSelected = selectedApps.contains(app.id);
                return _AppCard(
                  app: app,
                  isSelected: isSelected,
                  onTap: () {
                    final current = Set<String>.from(selectedApps);
                    if (current.contains(app.id)) {
                      current.remove(app.id);
                    } else {
                      current.add(app.id);
                    }
                    ref.read(_selectedAppsProvider.notifier).state = current;
                  },
                )
                    .animate()
                    .fadeIn(
                      duration: 300.ms,
                      delay: (80 * index).ms,
                    )
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                      duration: 300.ms,
                      delay: (80 * index).ms,
                    );
              },
            ),
          ),
          _PrimaryButton(
            label: 'Continue',
            onPressed: selectedApps.isNotEmpty ? onNext : null,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  final BlockedAppModel app;
  final bool isSelected;
  final VoidCallback onTap;

  const _AppCard({
    required this.app,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.textPrimary.withOpacity(0.06)
              : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.textPrimary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(app.iconEmoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                app.name,
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.textPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 14, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Step 3: Choose Exercise ───

class _ChooseExerciseStep extends ConsumerWidget {
  final VoidCallback onNext;
  const _ChooseExerciseStep({required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(_selectedExerciseProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Pick your exercise',
            style: AppTypography.displaySmall.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 28,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideX(begin: -0.1, end: 0, duration: 400.ms),
          const SizedBox(height: 8),
          Text(
            'This is what you\'ll do to unlock apps',
            style: AppTypography.bodyMedium,
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
          const SizedBox(height: 32),
          Expanded(
            child: Row(
              children: ExerciseType.values.asMap().entries.map((entry) {
                final index = entry.key;
                final exercise = entry.value;
                final isSelected = selected == exercise;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 0 : 6,
                      right: index == 2 ? 0 : 6,
                    ),
                    child: _ExerciseCard(
                      exercise: exercise,
                      isSelected: isSelected,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(_selectedExerciseProvider.notifier).state =
                            exercise;
                      },
                    )
                        .animate()
                        .fadeIn(
                          duration: 350.ms,
                          delay: (120 * index).ms,
                        )
                        .slideY(
                          begin: 0.15,
                          end: 0,
                          duration: 400.ms,
                          delay: (120 * index).ms,
                        ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          _PrimaryButton(
            label: 'Continue',
            onPressed: selected != null ? onNext : null,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final ExerciseType exercise;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.06)
              : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              exercise.emoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            Text(
              exercise.label,
              textAlign: TextAlign.center,
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 12),
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Step 4: Rep Count ───

class _RepCountStep extends ConsumerWidget {
  final VoidCallback onNext;
  const _RepCountStep({required this.onNext});

  static const _presets = [5, 10, 15, 20, 25, 30];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCount = ref.watch(_selectedRepCountProvider);
    final exercise = ref.watch(_selectedExerciseProvider) ?? ExerciseType.pushUps;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'How many ${exercise.label.toLowerCase()}\ncan you do?',
            style: AppTypography.displaySmall.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 28,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideX(begin: -0.1, end: 0, duration: 400.ms),
          const SizedBox(height: 8),
          Text(
            'We\'ll set your starting difficulty',
            style: AppTypography.bodyMedium,
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
          const SizedBox(height: 40),
          Center(
            child: Text(
              '$selectedCount',
              style: AppTypography.repCount.copyWith(
                fontSize: 80,
                fontWeight: FontWeight.w900,
              ),
            )
                .animate(key: ValueKey(selectedCount))
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  duration: 200.ms,
                  curve: Curves.easeOut,
                )
                .fadeIn(duration: 200.ms),
          ),
          Center(
            child: Text(
              exercise.label.toLowerCase(),
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textTertiary,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _presets.asMap().entries.map((entry) {
              final index = entry.key;
              final count = entry.value;
              final isSelected = selectedCount == count;
              return _RepChip(
                count: count,
                isSelected: isSelected,
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(_selectedRepCountProvider.notifier).state = count;
                },
              )
                  .animate()
                  .fadeIn(
                    duration: 300.ms,
                    delay: (60 * index).ms,
                  )
                  .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1, 1),
                    duration: 300.ms,
                    delay: (60 * index).ms,
                  );
            }).toList(),
          ),
          const Spacer(),
          _PrimaryButton(
            label: 'Continue',
            onPressed: onNext,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _RepChip extends StatelessWidget {
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _RepChip({
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 90,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.textPrimary
              : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.textPrimary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            '$count',
            style: AppTypography.headlineLarge.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Step 5: Goal Selection ───

class _GoalStep extends ConsumerWidget {
  final VoidCallback onNext;
  const _GoalStep({required this.onNext});

  static const _goals = [
    ('📱', 'Reduce Screen Time', 'Spend less time on distracting apps'),
    ('💪', 'Get Fit', 'Build a consistent exercise habit'),
    ('🎁', 'Earn Rewards', 'Collect coins and redeem gift cards'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGoal = ref.watch(_selectedGoalProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'What\'s your main goal?',
            style: AppTypography.displaySmall.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 28,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideX(begin: -0.1, end: 0, duration: 400.ms),
          const SizedBox(height: 8),
          Text(
            'We\'ll personalize your experience',
            style: AppTypography.bodyMedium,
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
          const SizedBox(height: 32),
          ...List.generate(_goals.length, (index) {
            final (emoji, title, subtitle) = _goals[index];
            final isSelected = selectedGoal == title;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _GoalCard(
                emoji: emoji,
                title: title,
                subtitle: subtitle,
                isSelected: isSelected,
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(_selectedGoalProvider.notifier).state = title;
                },
              )
                  .animate()
                  .fadeIn(
                    duration: 350.ms,
                    delay: (100 * index).ms,
                  )
                  .slideX(
                    begin: 0.08,
                    end: 0,
                    duration: 400.ms,
                    delay: (100 * index).ms,
                  ),
            );
          }),
          const Spacer(),
          _PrimaryButton(
            label: 'Continue',
            onPressed: selectedGoal != null ? onNext : null,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.textPrimary.withOpacity(0.05)
              : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.textPrimary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: AppColors.textPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 6: Celebration ───

class _CelebrationStep extends StatelessWidget {
  final VoidCallback onComplete;
  const _CelebrationStep({required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 3),
          Text(
            '🎉',
            style: const TextStyle(fontSize: 80),
          )
              .animate()
              .scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                duration: 600.ms,
                curve: Curves.elasticOut,
              ),
          const SizedBox(height: 32),
          Text(
            'You\'re all set!',
            style: AppTypography.displayMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 300.ms)
              .slideY(begin: 0.3, end: 0, duration: 500.ms, delay: 300.ms),
          const SizedBox(height: 16),
          Text(
            'Your personalized plan is ready.\nLet\'s build healthier habits together.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              fontSize: 18,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 500.ms),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MiniStat(emoji: '🛡️', label: 'Apps blocked'),
              const SizedBox(width: 32),
              _MiniStat(emoji: '🏋️', label: 'Exercise set'),
              const SizedBox(width: 32),
              _MiniStat(emoji: '🎯', label: 'Goal chosen'),
            ],
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 700.ms)
              .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 700.ms),
          const Spacer(flex: 4),
          _PrimaryButton(
            label: 'Get Started',
            onPressed: onComplete,
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 900.ms)
              .slideY(begin: 0.4, end: 0, duration: 500.ms, delay: 900.ms),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String emoji;
  final String label;
  const _MiniStat({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ─── Shared Primary Button ───

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _PrimaryButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isEnabled ? 1.0 : 0.4,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.textPrimary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.textPrimary.withOpacity(0.4),
            disabledForegroundColor: Colors.white60,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            label,
            style: AppTypography.button.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
