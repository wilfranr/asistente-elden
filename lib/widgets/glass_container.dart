import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Border? border;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.margin,
    this.padding,
    this.color,
    this.border,
    this.onTap,
  });

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _blurAnimation = Tween<double>(begin: 10.0, end: 15.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
      widget.onTap!();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedBuilder(
          animation: _blurAnimation,
          builder: (context, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: _blurAnimation.value, sigmaY: _blurAnimation.value),
                child: Container(
                  margin: widget.margin,
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    color: widget.color ?? Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: widget.border ?? Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.0,
                    ),
                  ),
                  child: widget.child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
