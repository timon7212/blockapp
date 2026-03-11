import 'package:flutter/material.dart';
import '../typography/app_typography.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: AppTypography.sectionHeader,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
