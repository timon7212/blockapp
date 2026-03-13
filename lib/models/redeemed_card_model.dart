import 'package:flutter/material.dart';

class RedeemedCardModel {
  final String id;
  final String brand;
  final IconData icon;
  final String code;
  final int pointsSpent;
  final double faceValue;
  final DateTime redeemedAt;

  const RedeemedCardModel({
    required this.id,
    required this.brand,
    required this.icon,
    required this.code,
    required this.pointsSpent,
    required this.faceValue,
    required this.redeemedAt,
  });
}
