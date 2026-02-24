import 'package:flutter/material.dart';
import 'dart:ui';

class GradientCard extends StatefulWidget {
  final Widget child;
  final List<Color> gradientColors;
  final double borderRadius;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool enableHover;

  const GradientCard({
    super.key,
    required this.child,
    required this.gradientColors,
    this.borderRadius = 24,
    this.padding,
    this.onTap,
    this.enableHover = true,
  });

  @override
  State<GradientCard> createState() => _GradientCardState();
}

class _GradientCardState extends State<GradientCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: widget.enableHover ? (_) => setState(() => _isHovering = true) : null,
      onExit: widget.enableHover ? (_) => setState(() => _isHovering = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovering ? 1.02 : 1.0),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.gradientColors,
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: widget.gradientColors.first.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: widget.padding ?? const EdgeInsets.all(24),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets? padding;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          padding: padding ?? const EdgeInsets.all(24),
          child: child,
        ),
      ),
    );
  }
}
