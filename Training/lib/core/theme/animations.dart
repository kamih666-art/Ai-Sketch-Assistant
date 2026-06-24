import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class PageAnimations {
  // Fade + Slide Transition
  static Route<T> fadeSlideTransition<T>(Widget page, {Duration duration = const Duration(milliseconds: 500)}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.3, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        var fadeAnimation = animation.drive(CurveTween(curve: Curves.easeOut)).drive(Tween(begin: 0.0, end: 1.0));

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: duration,
    );
  }

  // Scale + Fade Transition
  static Route<T> scaleFadeTransition<T>(Widget page, {Duration duration = const Duration(milliseconds: 400)}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var scaleAnimation = animation.drive(CurveTween(curve: Curves.elasticOut))
            .drive(Tween(begin: 0.8, end: 1.0));
        var fadeAnimation = animation.drive(CurveTween(curve: Curves.easeOut))
            .drive(Tween(begin: 0.0, end: 1.0));

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: duration,
    );
  }

  // Zoom Transition
  static Route<T> zoomTransition<T>(Widget page, {Duration duration = const Duration(milliseconds: 500)}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var zoomAnimation = animation.drive(CurveTween(curve: Curves.easeOutBack))
            .drive(Tween(begin: 0.5, end: 1.0));

        return ScaleTransition(
          scale: zoomAnimation,
          child: FadeTransition(
            opacity: animation.drive(CurveTween(curve: Curves.easeOut)).drive(Tween(begin: 0.0, end: 1.0)),
            child: child,
          ),
        );
      },
      transitionDuration: duration,
    );
  }

  // Rotate + Fade Transition
  static Route<T> rotateTransition<T>(Widget page, {Duration duration = const Duration(milliseconds: 500)}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var rotateAnimation = animation.drive(CurveTween(curve: Curves.easeOutBack))
            .drive(Tween(begin: -0.5, end: 0.0));
        var fadeAnimation = animation.drive(CurveTween(curve: Curves.easeOut))
            .drive(Tween(begin: 0.0, end: 1.0));

        return FadeTransition(
          opacity: fadeAnimation,
          child: Transform.rotate(
            angle: rotateAnimation.value,
            child: child,
          ),
        );
      },
      transitionDuration: duration,
    );
  }

  // Slide from bottom
  static Route<T> slideFromBottom<T>(Widget page, {Duration duration = const Duration(milliseconds: 400)}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  // Slide from top
  static Route<T> slideFromTop<T>(Widget page, {Duration duration = const Duration(milliseconds: 400)}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, -1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }
}

// ==================== ANIMATED WIDGETS ====================

// Animated Button with Ripple Effect
class AnimatedPremiumButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  final Color? color;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;

  const AnimatedPremiumButton({
    super.key,
    required this.onTap,
    required this.child,
    this.color,
    this.gradient,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.boxShadow,
  });

  @override
  State<AnimatedPremiumButton> createState() => _AnimatedPremiumButtonState();
}

class _AnimatedPremiumButtonState extends State<AnimatedPremiumButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: widget.gradient ?? (widget.color != null ? LinearGradient(colors: [widget.color!, widget.color!]) : null),
                color: widget.gradient == null ? widget.color : null,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: widget.boxShadow,
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

// Animated Card
class AnimatedPremiumCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double elevation;
  final double borderRadius;

  const AnimatedPremiumCard({
    super.key,
    required this.child,
    this.onTap,
    this.elevation = 8,
    this.borderRadius = 20,
  });

  @override
  State<AnimatedPremiumCard> createState() => _AnimatedPremiumCardState();
}

class _AnimatedPremiumCardState extends State<AnimatedPremiumCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _elevationAnimation = Tween<double>(begin: widget.elevation, end: widget.elevation * 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool hovering) {
    if (hovering) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Material(
                color: Colors.transparent,
                elevation: _elevationAnimation.value,
                shadowColor: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
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

// Pulsing Container
class PulsingContainer extends StatefulWidget {
  final Widget child;
  final Color color;
  final double size;
  final Duration duration;

  const PulsingContainer({
    super.key,
    required this.child,
    required this.color,
    this.size = 100,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<PulsingContainer> createState() => _PulsingContainerState();
}

class _PulsingContainerState extends State<PulsingContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 0.0).animate(
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
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              width: widget.size * _scaleAnimation.value,
              height: widget.size * _scaleAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(_opacityAnimation.value),
              ),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

// Shimmer Effect Widget
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<Offset>(
      begin: const Offset(-1.5, -1.5),
      end: const Offset(1.5, 1.5),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.3),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcATop,
      child: widget.child,
    );
  }
}

// Animated Text with Typewriter Effect
class TypewriterText extends StatefulWidget {
  final String text;
  final Duration duration;
  final TextStyle? style;
  final TextAlign textAlign;

  const TypewriterText({
    super.key,
    required this.text,
    this.duration = const Duration(milliseconds: 2000),
    this.style,
    this.textAlign = TextAlign.center,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  String _displayText = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..forward();

    _animation = IntTween(begin: 0, end: widget.text.length).animate(_controller);
    _animation.addListener(() {
      setState(() {
        _displayText = widget.text.substring(0, _animation.value);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayText,
      style: widget.style,
      textAlign: widget.textAlign,
    );
  }
}