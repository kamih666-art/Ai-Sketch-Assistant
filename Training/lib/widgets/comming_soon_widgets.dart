import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// Shared Feature Chip Widget
class FeatureChip extends StatelessWidget {
  final String label;
  const FeatureChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white70,
        ),
      ),
    );
  }
}

// Shared Coming Soon Particle
class ComingSoonParticle extends StatefulWidget {
  final int index;
  const ComingSoonParticle({super.key, required this.index});

  @override
  State<ComingSoonParticle> createState() => _ComingSoonParticleState();
}

class _ComingSoonParticleState extends State<ComingSoonParticle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _verticalAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3 + widget.index % 5),
      vsync: this,
    )..repeat(reverse: true);

    _verticalAnimation = Tween<double>(begin: 0, end: 100 + (widget.index % 150)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    _opacityAnimation = Tween<double>(begin: 0.1, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Calculate left position as double
        final screenWidth = MediaQuery.of(context).size.width;
        final leftValue = (20 + (widget.index * 45) % screenWidth.toInt()).toDouble();

        return Positioned(
          left: leftValue,
          top: _verticalAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: 2 + (widget.index % 4).toDouble(),
              height: 2 + (widget.index % 4).toDouble(),
              decoration: BoxDecoration(
                color: [
                  AppTheme.electricBlue,
                  AppTheme.neonPink,
                  AppTheme.neonPurple,
                  AppTheme.neonGreen,
                  AppTheme.neonYellow,
                ][widget.index % 5].withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}