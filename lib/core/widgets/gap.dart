import 'package:flutter/material.dart';

/// A reusable spacing widget for consistent gaps
class Gap extends StatelessWidget {
  final double size;
  final bool isHorizontal;

  const Gap(this.size, {super.key, this.isHorizontal = false});

  /// Extra small gap (4)
  const Gap.xs({super.key, this.isHorizontal = false}) : size = 4;

  /// Small gap (8)
  const Gap.sm({super.key, this.isHorizontal = false}) : size = 8;

  /// Medium gap (16)
  const Gap.md({super.key, this.isHorizontal = false}) : size = 16;

  /// Large gap (24)
  const Gap.lg({super.key, this.isHorizontal = false}) : size = 24;

  /// Extra large gap (32)
  const Gap.xl({super.key, this.isHorizontal = false}) : size = 32;

  /// Horizontal extra small gap (4)
  const Gap.hXs({super.key}) : size = 4, isHorizontal = true;

  /// Horizontal small gap (8)
  const Gap.hSm({super.key}) : size = 8, isHorizontal = true;

  /// Horizontal medium gap (16)
  const Gap.hMd({super.key}) : size = 16, isHorizontal = true;

  /// Horizontal large gap (24)
  const Gap.hLg({super.key}) : size = 24, isHorizontal = true;

  /// Horizontal extra large gap (32)
  const Gap.hXl({super.key}) : size = 32, isHorizontal = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isHorizontal ? size : null,
      height: isHorizontal ? null : size,
    );
  }
}
