import 'package:flutter/material.dart';
import '../core/constants/economy_constants.dart';

/// User's current rank / level progression
class RankModel {
  final int totalPointsEarned;

  const RankModel({
    this.totalPointsEarned = 0,
  });

  RankTier get currentRank {
    RankTier current = EconomyConstants.ranks.first;
    for (final tier in EconomyConstants.ranks) {
      if (totalPointsEarned >= tier.minPoints) {
        current = tier;
      }
    }
    return current;
  }

  RankTier? get nextRank {
    final ranks = EconomyConstants.ranks;
    final currentIndex = ranks.indexOf(currentRank);
    if (currentIndex < ranks.length - 1) {
      return ranks[currentIndex + 1];
    }
    return null;
  }

  int get currentRankIndex {
    return EconomyConstants.ranks.indexOf(currentRank);
  }

  double get progressToNextRank {
    final next = nextRank;
    if (next == null) return 1.0;
    final current = currentRank;
    final range = next.minPoints - current.minPoints;
    final progress = totalPointsEarned - current.minPoints;
    return (progress / range).clamp(0.0, 1.0);
  }

  int get pointsToNextRank {
    final next = nextRank;
    if (next == null) return 0;
    return (next.minPoints - totalPointsEarned).clamp(0, next.minPoints);
  }

  Color get rankColor => Color(currentRank.color);

  RankModel copyWith({
    int? totalPointsEarned,
  }) {
    return RankModel(
      totalPointsEarned: totalPointsEarned ?? this.totalPointsEarned,
    );
  }
}
