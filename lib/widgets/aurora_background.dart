import 'package:flutter/material.dart';
import 'dart:math';

class AuroraBackground extends StatelessWidget {
  const AuroraBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base color
        Container(
          color: const Color(0xFF111827), // backgroundColor from AppTheme
        ),
        // Aurora effects
        _buildAuroraCircle(context, color: const Color(0xFFF59E0B).withOpacity(0.15), top: -150, left: -200, radius: 400),
        _buildAuroraCircle(context, color: const Color(0xFF374151).withOpacity(0.2), bottom: -200, right: -250, radius: 500),
        _buildAuroraCircle(context, color: const Color(0xFF1F2937).withOpacity(0.3), top: 200, right: -300, radius: 450),
        _buildAuroraCircle(context, color: const Color(0xFFF59E0B).withOpacity(0.1), bottom: -100, left: 50, radius: 350),
      ],
    );
  }

  Widget _buildAuroraCircle(BuildContext context, {
    required Color color,
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double radius,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withOpacity(0),
            ],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}
