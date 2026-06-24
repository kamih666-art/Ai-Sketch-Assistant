import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class GlowingContainer extends StatefulWidget {
  final Widget child;
  final Color color;
  final double size;
  final bool animate;
  final double blurRadius;
  final Duration duration;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool isCircular;

  const GlowingContainer({
    super.key,
    required this.child,
    required this.color,
    this.size = 100,
    this.animate = true,
    this.blurRadius = 30,
    this.duration = const Duration(milliseconds: 1500),
    this.padding,
    this.borderRadius,
    this.isCircular = true,
  });

  @override
  State<GlowingContainer> createState() => _GlowingContainerState();
}

class _GlowingContainerState extends State<GlowingContainer> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _pulseController = AnimationController(
        duration: widget.duration,
        vsync: this,
      )..repeat(reverse: true);

      _pulseAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
      );

      _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
      );

      _opacityAnimation = Tween<double>(begin: 0.6, end: 0.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return Container(
        width: widget.size,
        height: widget.size,
        padding: widget.padding,
        decoration: widget.isCircular
            ? BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withOpacity(0.1),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.3),
              blurRadius: widget.blurRadius,
              spreadRadius: 5,
            ),
          ],
        )
            : BoxDecoration(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
          color: widget.color.withOpacity(0.1),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.3),
              blurRadius: widget.blurRadius,
              spreadRadius: 5,
            ),
          ],
        ),
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring
            Container(
              width: widget.size * _pulseAnimation.value,
              height: widget.size * _pulseAnimation.value,
              decoration: widget.isCircular
                  ? BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(_opacityAnimation.value),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.5 * (1.3 - _pulseAnimation.value + 0.7)),
                    blurRadius: widget.blurRadius * _pulseAnimation.value,
                    spreadRadius: 5 * _pulseAnimation.value,
                  ),
                ],
              )
                  : BoxDecoration(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
                color: widget.color.withOpacity(_opacityAnimation.value),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.5),
                    blurRadius: widget.blurRadius * _pulseAnimation.value,
                    spreadRadius: 5 * _pulseAnimation.value,
                  ),
                ],
              ),
            ),
            // Inner container
            Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                padding: widget.padding,
                decoration: widget.isCircular
                    ? BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [widget.color, widget.color.withOpacity(0.8)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.4),
                      blurRadius: widget.blurRadius,
                      spreadRadius: 2,
                    ),
                  ],
                )
                    : BoxDecoration(
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [widget.color, widget.color.withOpacity(0.8)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.4),
                      blurRadius: widget.blurRadius,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: widget.child,
              ),
            ),
          ],
        );
      },
    );
  }
}

// Multi-color glowing container (rainbow effect)
class RainbowGlowingContainer extends StatefulWidget {
  final Widget child;
  final double size;
  final bool animate;
  final Duration duration;

  const RainbowGlowingContainer({
    super.key,
    required this.child,
    this.size = 100,
    this.animate = true,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<RainbowGlowingContainer> createState() => _RainbowGlowingContainerState();
}

class _RainbowGlowingContainerState extends State<RainbowGlowingContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _controller = AnimationController(
        duration: widget.duration,
        vsync: this,
      )..repeat(reverse: true);

      _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );

      _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );

      _opacityAnimation = Tween<double>(begin: 0.5, end: 0.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppTheme.rainbowGradient,
          boxShadow: [
            BoxShadow(
              color: Colors.white24,
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final colors = [
          AppTheme.neonPink,
          AppTheme.neonPurple,
          AppTheme.electricBlue,
          AppTheme.neonGreen,
          AppTheme.neonYellow,
        ];

        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow rings
            for (int i = 0; i < colors.length; i++)
              Container(
                width: widget.size * (_scaleAnimation.value + i * 0.05),
                height: widget.size * (_scaleAnimation.value + i * 0.05),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors[i].withOpacity(_opacityAnimation.value * (1 - i * 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: colors[i].withOpacity(0.5),
                      blurRadius: 30 * (1 + i * 0.3),
                      spreadRadius: 10 * (1 - i * 0.2),
                    ),
                  ],
                ),
              ),
            // Inner container
            Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.rainbowGradient,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white38,
                      blurRadius: 40,
                      spreadRadius: 15,
                    ),
                  ],
                ),
                child: widget.child,
              ),
            ),
          ],
        );
      },
    );
  }
}

// Neon Text Glow
class NeonText extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final bool animate;

  const NeonText({
    super.key,
    required this.text,
    required this.color,
    this.fontSize = 24,
    this.fontWeight = FontWeight.bold,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget textWidget = Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: Colors.white,
        shadows: [
          Shadow(
            blurRadius: 10,
            color: color.withOpacity(0.8),
          ),
          Shadow(
            blurRadius: 20,
            color: color.withOpacity(0.5),
          ),
          Shadow(
            blurRadius: 30,
            color: color.withOpacity(0.3),
          ),
        ],
      ),
    );

    if (animate) {
      textWidget = AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 500),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Colors.white,
          shadows: [
            Shadow(
              blurRadius: 10,
              color: color.withOpacity(0.8),
            ),
          ],
        ),
        child: textWidget,
      );
    }

    return textWidget;
  }
}