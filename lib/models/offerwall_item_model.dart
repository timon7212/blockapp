import 'package:flutter/material.dart';

class OfferwallItemModel {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int rewardPoints;
  final OfferType type;
  final OfferStatus status;
  final String? actionUrl;
  final int earnedPoints;

  const OfferwallItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.rewardPoints,
    required this.type,
    this.status = OfferStatus.available,
    this.actionUrl,
    this.earnedPoints = 0,
  });

  OfferwallItemModel copyWith({OfferStatus? status, int? earnedPoints}) {
    return OfferwallItemModel(
      id: id,
      title: title,
      description: description,
      icon: icon,
      rewardPoints: rewardPoints,
      type: type,
      status: status ?? this.status,
      actionUrl: actionUrl,
      earnedPoints: earnedPoints ?? this.earnedPoints,
    );
  }
}

enum OfferType {
  installApp('Install App'),
  register('Register'),
  reachLevel('Reach Level'),
  subscribe('Subscribe'),
  survey('Survey');

  final String label;
  const OfferType(this.label);
}

enum OfferStatus {
  available,
  inProgress,
  completed,
}
