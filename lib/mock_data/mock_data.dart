import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/wallet_model.dart';
import '../models/screen_time_model.dart';
import '../models/raffle_model.dart';
import '../models/referral_level_model.dart';
import '../models/gift_card_model.dart';
import '../models/partner_offer_model.dart';

class MockData {
  MockData._();

  static final user = UserModel(
    id: 'user_001',
    username: 'doomscroller',
    displayName: 'Alex',
    referralCode: 'DOOM2026',
    directInvites: 7,
    joinedAt: DateTime(2026, 1, 15),
    totalPointsEarned: 34500,
  );

  static const wallet = WalletModel(
    totalPoints: 12450,
    pendingPoints: 0,
    todayEarned: 1350,
  );

  static const screenTime = ScreenTimeModel(
    accumulatedMinutes: 14,
    accumulatedPoints: 1400,
    isCapped: false,
  );

  static const raffles = [
    RaffleModel(
      id: 'raffle_daily',
      title: 'Daily Drop',
      type: RaffleType.daily,
      prizePoints: 25000,
      timeRemaining: Duration(hours: 8, minutes: 32),
      totalParticipants: 1247,
      entryTasks: [
        RaffleEntryTask(id: 'dt_1', title: 'Watch 2 ads', icon: Icons.play_circle_outline_rounded, type: RaffleTaskType.watchAds, requiredCount: 2, currentCount: 1),
      ],
    ),
    RaffleModel(
      id: 'raffle_weekly',
      title: 'Weekly Jackpot',
      type: RaffleType.weekly,
      prizePoints: 150000,
      timeRemaining: Duration(days: 3, hours: 14),
      totalParticipants: 8432,
      entryTasks: [
        RaffleEntryTask(id: 'wt_1', title: 'Watch 8 ads', icon: Icons.play_circle_outline_rounded, type: RaffleTaskType.watchAds, requiredCount: 8, currentCount: 3),
        RaffleEntryTask(id: 'wt_2', title: 'Complete 1 offer', icon: Icons.assignment_turned_in_outlined, type: RaffleTaskType.completeOffer, requiredCount: 1, currentCount: 0),
      ],
    ),
    RaffleModel(
      id: 'raffle_monthly',
      title: 'Grand Prize',
      type: RaffleType.monthly,
      prizePoints: 1000000,
      timeRemaining: Duration(days: 18, hours: 6),
      totalParticipants: 42891,
      entryTasks: [
        RaffleEntryTask(id: 'mt_1', title: 'Watch 15 ads', icon: Icons.play_circle_outline_rounded, type: RaffleTaskType.watchAds, requiredCount: 15, currentCount: 5),
        RaffleEntryTask(id: 'mt_2', title: 'Complete 3 offers', icon: Icons.assignment_turned_in_outlined, type: RaffleTaskType.completeOffer, requiredCount: 3, currentCount: 1),
        RaffleEntryTask(id: 'mt_3', title: 'Invite 1 friend', icon: Icons.person_add_outlined, type: RaffleTaskType.inviteFriend, requiredCount: 1, currentCount: 0),
      ],
    ),
  ];

  static const referralLevels = [
    ReferralLevelModel(level: 1, commissionPercent: 10.0, activeUsers: 7, pendingPoints: 520, totalCollected: 4840, isUnlocked: true, requiredInvites: 0),
    ReferralLevelModel(level: 2, commissionPercent: 5.0, activeUsers: 23, pendingPoints: 285, totalCollected: 2180, isUnlocked: true, requiredInvites: 3),
  ];

  static const giftCards = [
    GiftCardModel(id: 'gc_amazon', brand: 'Amazon', icon: Icons.inventory_2_rounded, pointsCost: 5000, faceValue: 5.00, category: 'Shopping'),
    GiftCardModel(id: 'gc_starbucks', brand: 'Starbucks', icon: Icons.coffee_rounded, pointsCost: 3000, faceValue: 3.00, category: 'Food'),
    GiftCardModel(id: 'gc_netflix', brand: 'Netflix', icon: Icons.movie_rounded, pointsCost: 10000, faceValue: 10.00, category: 'Entertainment'),
    GiftCardModel(id: 'gc_spotify', brand: 'Spotify', icon: Icons.headphones_rounded, pointsCost: 5000, faceValue: 5.00, category: 'Entertainment'),
    GiftCardModel(id: 'gc_apple', brand: 'App Store', icon: Icons.phone_iphone_rounded, pointsCost: 10000, faceValue: 10.00, category: 'Tech'),
    GiftCardModel(id: 'gc_google', brand: 'Google Play', icon: Icons.games_rounded, pointsCost: 5000, faceValue: 5.00, category: 'Tech'),
    GiftCardModel(id: 'gc_uber', brand: 'Uber', icon: Icons.local_taxi_rounded, pointsCost: 5000, faceValue: 5.00, category: 'Transport'),
    GiftCardModel(id: 'gc_nike', brand: 'Nike', icon: Icons.directions_run_rounded, pointsCost: 15000, faceValue: 15.00, category: 'Shopping'),
  ];

  static const partnerOffers = [
    PartnerOfferModel(id: 'po_vpn', brand: 'NordVPN', description: '70% off 2-year plan', icon: Icons.vpn_lock_rounded, pointsCost: 500, discountPercent: 70, category: 'Software'),
    PartnerOfferModel(id: 'po_headspace', brand: 'Headspace', description: '3 months free trial', icon: Icons.self_improvement_rounded, pointsCost: 300, discountPercent: 100, category: 'Wellness'),
    PartnerOfferModel(id: 'po_skillshare', brand: 'Skillshare', description: '2 months premium free', icon: Icons.school_rounded, pointsCost: 400, discountPercent: 100, category: 'Education'),
  ];
}
