import 'package:flutter/material.dart';
import 'package:medipulse_medical/core/theme/app_text_styles.dart';


class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(title, style: AppTextStyles.title),
        if (trailing case final trailingText?)
          Text(trailingText, style: AppTextStyles.caption),
      ],
    );
  }
}