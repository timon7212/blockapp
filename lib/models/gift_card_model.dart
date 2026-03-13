import 'package:flutter/material.dart';

class GiftCardModel {
  final String id;
  final String brand;
  final IconData icon;
  final int pointsCost;
  final double faceValue;
  final String category;

  const GiftCardModel({
    required this.id,
    required this.brand,
    required this.icon,
    required this.pointsCost,
    required this.faceValue,
    required this.category,
  });
}
