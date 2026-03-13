import 'package:flutter/material.dart';
import '../models/offerwall_item_model.dart';

class OfferwallService {
  static List<OfferwallItemModel> getOffers() => _mockOffers;

  static const _mockOffers = [
    OfferwallItemModel(
      id: 'offer_raid',
      title: 'RAID: Shadow Legends',
      description: 'Install & reach level 10',
      icon: Icons.shield_rounded,
      rewardPoints: 4500,
      type: OfferType.reachLevel,
      actionUrl: 'https://example.com/raid',
    ),
    OfferwallItemModel(
      id: 'offer_cashapp',
      title: 'Cash App',
      description: 'Sign up & send first payment',
      icon: Icons.account_balance_wallet_rounded,
      rewardPoints: 3200,
      type: OfferType.register,
      actionUrl: 'https://example.com/cashapp',
    ),
    OfferwallItemModel(
      id: 'offer_temu',
      title: 'Temu',
      description: 'Install & make first purchase',
      icon: Icons.shopping_bag_rounded,
      rewardPoints: 2800,
      type: OfferType.installApp,
      actionUrl: 'https://example.com/temu',
    ),
    OfferwallItemModel(
      id: 'offer_evony',
      title: 'Evony',
      description: 'Install & upgrade castle to Lv.15',
      icon: Icons.castle_rounded,
      rewardPoints: 6000,
      type: OfferType.reachLevel,
      actionUrl: 'https://example.com/evony',
    ),
    OfferwallItemModel(
      id: 'offer_nord',
      title: 'NordVPN',
      description: 'Subscribe to any plan',
      icon: Icons.vpn_lock_rounded,
      rewardPoints: 5500,
      type: OfferType.subscribe,
      actionUrl: 'https://example.com/nord',
    ),
    OfferwallItemModel(
      id: 'offer_coinmaster',
      title: 'Coin Master',
      description: 'Install & complete village 5',
      icon: Icons.monetization_on_rounded,
      rewardPoints: 3800,
      type: OfferType.reachLevel,
      actionUrl: 'https://example.com/coinmaster',
    ),
    OfferwallItemModel(
      id: 'offer_survey1',
      title: 'Quick Survey',
      description: 'Answer 10 questions (~3 min)',
      icon: Icons.poll_rounded,
      rewardPoints: 500,
      type: OfferType.survey,
      actionUrl: 'https://example.com/survey',
    ),
    OfferwallItemModel(
      id: 'offer_survey2',
      title: 'Shopping Habits',
      description: 'Share your preferences (~5 min)',
      icon: Icons.bar_chart_rounded,
      rewardPoints: 800,
      type: OfferType.survey,
      actionUrl: 'https://example.com/survey2',
    ),
    OfferwallItemModel(
      id: 'offer_survey3',
      title: 'Tech Usage Study',
      description: 'About your devices & apps (~7 min)',
      icon: Icons.insights_rounded,
      rewardPoints: 1200,
      type: OfferType.survey,
      actionUrl: 'https://example.com/survey3',
    ),
    OfferwallItemModel(
      id: 'offer_revolut',
      title: 'Revolut',
      description: 'Open account & order card',
      icon: Icons.credit_card_rounded,
      rewardPoints: 4200,
      type: OfferType.register,
      actionUrl: 'https://example.com/revolut',
    ),
  ];
}
