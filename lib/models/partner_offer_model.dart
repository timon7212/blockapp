import 'package:flutter/material.dart';

class PartnerOfferModel {
  final String id;
  final String brand;
  final String description;
  final IconData icon;
  final int pointsCost;
  final double discountPercent;
  final String category;

  const PartnerOfferModel({
    required this.id,
    required this.brand,
    required this.description,
    required this.icon,
    required this.pointsCost,
    required this.discountPercent,
    required this.category,
  });
}
