import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../shared/providers/app_providers.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/surface_card.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../core/utils/formatters.dart';
import '../../models/offerwall_item_model.dart';
import '../../design_system/utils/app_page_route.dart';
import 'offer_detail_screen.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final allOffers = ref.watch(offerwallProvider);
    final allTasks = allOffers.where((o) => o.type == OfferType.register || o.type == OfferType.subscribe).toList();
    final availableTasks = allTasks.where((o) => o.status == OfferStatus.available).toList();
    final myTasks = allTasks.where((o) => o.status != OfferStatus.available).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('Sign up for services, complete offers, and earn rewards.', style: AppTypography.bodySmall),
              ),
              const SizedBox(height: 16),
              _buildTabs(),
              const SizedBox(height: 12),
              Expanded(
                child: _tab == 0
                    ? _buildAvailableList(availableTasks)
                    : _buildMyList(myTasks),
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.assignment_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Text('Tasks', style: AppTypography.headlineLarge),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceMid,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            _TabButton(label: 'Tasks', active: _tab == 0, onTap: () => setState(() => _tab = 0)),
            const SizedBox(width: 4),
            _TabButton(label: 'My Tasks', active: _tab == 1, onTap: () => setState(() => _tab = 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableList(List<OfferwallItemModel> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.assignment_outlined, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text('No tasks available right now', style: AppTypography.bodyMedium),
          const SizedBox(height: 4),
          Text('Check back soon', style: AppTypography.bodySmall),
        ]),
      );
    }
    return AnimationLimiter(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        physics: const BouncingScrollPhysics(),
        itemCount: tasks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          return AnimationConfiguration.staggeredList(
            position: i,
            duration: const Duration(milliseconds: 400),
            child: SlideAnimation(
              verticalOffset: 30,
              child: FadeInAnimation(child: _TaskCard(offer: tasks[i])),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMyList(List<OfferwallItemModel> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.assignment_outlined, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text('No tasks started yet', style: AppTypography.bodyMedium),
          const SizedBox(height: 4),
          Text('Start a task from the list to track it here', style: AppTypography.bodySmall),
        ]),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      physics: const BouncingScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final o = tasks[i];
        final isComplete = o.status == OfferStatus.completed;
        return SurfaceCard(
          padding: const EdgeInsets.all(16),
          borderRadius: 16,
          borderColor: isComplete ? AppColors.success.withValues(alpha: 0.2) : AppColors.border,
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.of(context).push(AppPageRoute(page: OfferDetailScreen(offer: o)));
          },
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (isComplete ? AppColors.success : AppColors.warning).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(o.icon, color: isComplete ? AppColors.success : AppColors.warning, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.title, style: AppTypography.headlineSmall),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isComplete ? AppColors.success : AppColors.warning).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isComplete ? 'Completed' : 'In Progress',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isComplete ? AppColors.success : AppColors.warning),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isComplete)
                    Text('+${Formatters.points(o.rewardPoints)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.success))
                  else
                    Text('${Formatters.points(o.earnedPoints)}/${Formatters.points(o.rewardPoints)}', style: AppTypography.labelSmall),
                  const SizedBox(height: 2),
                  Text(isComplete ? 'earned' : 'pts', style: AppTypography.caption),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: active ? Border.all(color: AppColors.border) : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, fontWeight: active ? FontWeight.w600 : FontWeight.w400, color: active ? AppColors.textPrimary : AppColors.textTertiary),
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final OfferwallItemModel offer;
  const _TaskCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).push(AppPageRoute(page: OfferDetailScreen(offer: offer)));
      },
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(offer.icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(offer.title, style: AppTypography.headlineSmall),
                const SizedBox(height: 3),
                Text(offer.description, style: AppTypography.bodySmall),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(offer.type.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.primary)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('+${Formatters.points(offer.rewardPoints)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text('pts', style: AppTypography.caption),
            ],
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
        ],
      ),
    );
  }
}
