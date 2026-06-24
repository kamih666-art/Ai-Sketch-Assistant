import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;
  late Timer _drawingSimulationTimer;
  late Timer _loadingTextTimer;

  final List<PaintPoint> _paintPoints = [];
  final List<Color> _paintColors = [
    AppTheme.neonPink,
    AppTheme.electricBlue,
    AppTheme.neonPurple,
    AppTheme.neonGreen,
    AppTheme.neonYellow,
    AppTheme.primaryPurple,
  ];

  final List<String> _loadingMessages = [
    'Initializing AI Engine...',
    'Loading Neural Networks...',
    'Calibrating Drawing Sensors...',
    'Warming up AI Models...',
    'Almost Ready...',
  ];

  int _currentLoadingIndex = 0;
  double _loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();

    // Main animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Glow pulse controller
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Setup animations
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _controller.forward();

    // Start loading progress
    _startLoadingProgress();

    // Start drawing simulation
    _startDrawingSimulation();

    // Rotate loading messages
    _startLoadingMessagesRotation();

    // Navigate after animation
    Timer(const Duration(seconds: 12), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/guide');
      }
    });
  }

  void _startLoadingProgress() {
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_loadingProgress < 1.0) {
          _loadingProgress += 0.01;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _startLoadingMessagesRotation() {
    _loadingTextTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _currentLoadingIndex = (_currentLoadingIndex + 1) % _loadingMessages.length;
      });
    });
  }

  void _startDrawingSimulation() {
    const simulationDuration = Duration(milliseconds: 4000);
    const updateInterval = Duration(milliseconds: 25);
    final totalUpdates = simulationDuration.inMilliseconds ~/ updateInterval.inMilliseconds;

    int updateCount = 0;

    _drawingSimulationTimer = Timer.periodic(updateInterval, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (updateCount >= totalUpdates) {
        timer.cancel();
        return;
      }

      setState(() {
        // Enhanced spiral pattern with more complexity
        final progress = updateCount / totalUpdates;
        final angle = 2 * pi * progress * 6;
        final radius = 100.0 + 40.0 * sin(progress * pi * 3);

        // Create a flower-like pattern
        final x = MediaQuery.of(context).size.width / 2 + radius * cos(angle) * (0.8 + 0.2 * sin(progress * pi * 5));
        final y = MediaQuery.of(context).size.height / 2 + radius * sin(angle) * (0.8 + 0.2 * cos(progress * pi * 4));

        _paintPoints.add(PaintPoint(
          offset: Offset(x, y),
          color: _paintColors[updateCount % _paintColors.length],
          size: 6.0 + 14.0 * sin(progress * pi),
          timestamp: DateTime.now(),
        ));

        // Keep only recent points for performance
        if (_paintPoints.length > 150) {
          _paintPoints.removeAt(0);
        }
      });

      updateCount++;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _glowController.dispose();
    _drawingSimulationTimer.cancel();
    _loadingTextTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Animated gradient background
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.5,
                        colors: [
                          AppTheme.primaryPurple.withOpacity(0.3 * _glowAnimation.value),
                          AppTheme.darkBg,
                          AppTheme.darkBg,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  );
                },
              ),

              // Animated grid background
              CustomPaint(
                painter: _PremiumGridPainter(),
                size: screenSize,
              ),

              // Floating particles
              ...List.generate(30, (index) => _PremiumFloatingParticle(index: index)),

              // Rotating rings
              Center(
                child: AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value * 0.3,
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.electricBlue.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Transform.rotate(
                          angle: -_rotationAnimation.value * 0.2,
                          child: Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.neonPink.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Simulated paint strokes in background
              CustomPaint(
                painter: _PremiumCanvasPainter(points: _paintPoints),
              ),

              // Main content - FIXED: Added SingleChildScrollView to prevent overflow
              SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),

                        // Animated logo container
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppTheme.primaryGradient,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryPurple.withOpacity(0.5 * _glowAnimation.value),
                                      blurRadius: 40 * _glowAnimation.value,
                                      spreadRadius: 10 * _glowAnimation.value,
                                    ),
                                    BoxShadow(
                                      color: AppTheme.neonPurple.withOpacity(0.3),
                                      blurRadius: 60,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 170,
                                      height: 170,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.15),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    Lottie.asset(
                                      'assets/animations/paint_brush.json',
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.auto_awesome,
                                          size: 70,
                                          color: Colors.white,
                                        );
                                      },
                                    ),
                                    Positioned.fill(
                                      child: ClipOval(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.white.withOpacity(0.2),
                                                Colors.transparent,
                                                Colors.white.withOpacity(0.1),
                                              ],
                                              stops: const [0.0, 0.5, 1.0],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 40),

                        // App name - FIXED: Added flexible width
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => AppTheme.rainbowGradient.createShader(
                                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                                  ),
                                  child: const Text(
                                    'AI SKETCH',
                                    style: TextStyle(
                                      fontSize: 44,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Premium Assistant',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.electricBlue,
                                    letterSpacing: 3,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 10,
                                        color: AppTheme.electricBlue.withOpacity(0.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Premium tagline - FIXED: Added padding constraints
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: FadeInUp(
                            delay: const Duration(milliseconds: 500),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.electricBlue.withOpacity(0.2),
                                    AppTheme.neonPink.withOpacity(0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: AppTheme.electricBlue.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.electricBlue.withOpacity(0.2),
                                    blurRadius: 15,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.auto_awesome,
                                    color: AppTheme.neonYellow,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Draw Smart • Create Perfect • AI Powered',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withOpacity(0.9),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Loading indicator
                        FadeInUp(
                          delay: const Duration(milliseconds: 800),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: CircularProgressIndicator(
                                      value: _loadingProgress,
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.electricBlue,
                                      ),
                                      backgroundColor: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  AnimatedBuilder(
                                    animation: _glowAnimation,
                                    builder: (context, child) {
                                      return Container(
                                        width: 45,
                                        height: 45,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: AppTheme.primaryGradient,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.primaryPurple.withOpacity(0.5 * _glowAnimation.value),
                                              blurRadius: 15 * _glowAnimation.value,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.auto_awesome,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  _loadingMessages[_currentLoadingIndex],
                                  key: ValueKey(_currentLoadingIndex),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.electricBlue,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 180,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: _loadingProgress,
                                    backgroundColor: Colors.white.withOpacity(0.1),
                                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonPink),
                                    minHeight: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Footer with team info - FIXED: Wrapped with Padding
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: FadeInUp(
                            delay: const Duration(milliseconds: 1200),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      _buildPremiumTeamMember('NEHA SALEEM', AppTheme.neonPink),
                                      Text('•', style: TextStyle(color: Colors.white.withOpacity(0.3))),
                                      _buildPremiumTeamMember('SEHAR SHAHID', AppTheme.electricBlue),
                                      Text('•', style: TextStyle(color: Colors.white.withOpacity(0.3))),
                                      _buildPremiumTeamMember('ALEENA KAMRAN', AppTheme.neonGreen),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Under the Supervision of Miss Anila Majeed',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white.withOpacity(0.4),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'LAHORE COLLEGE FOR WOMEN UNIVERSITY',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.white.withOpacity(0.3),
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPremiumTeamMember(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// Helper class for paint points
class PaintPoint {
  final Offset offset;
  final Color color;
  final double size;
  final DateTime timestamp;

  PaintPoint({
    required this.offset,
    required this.color,
    required this.size,
    required this.timestamp,
  });
}

// Premium Custom painter for canvas texture
class _PremiumGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 0.5;

    const gridSize = 30.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final diagonalPaint = Paint()
      ..color = Colors.white.withOpacity(0.01)
      ..strokeWidth = 0.3;

    for (double i = -size.height; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), diagonalPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Premium Canvas Painter
class _PremiumCanvasPainter extends CustomPainter {
  final List<PaintPoint> points;

  _PremiumCanvasPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final age = DateTime.now().difference(point.timestamp).inMilliseconds / 1000.0;
      final opacity = 1.0 - (age / 4.0).clamp(0.0, 1.0);

      if (opacity > 0) {
        final paint = Paint()
          ..color = point.color.withOpacity(opacity * 0.2)
          ..strokeWidth = point.size
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

        canvas.drawCircle(point.offset, point.size / 2, paint);

        if (i < points.length - 1) {
          final nextPoint = points[i + 1];
          final nextOpacity = 1.0 -
              (DateTime.now().difference(nextPoint.timestamp).inMilliseconds / 1000.0).clamp(0.0, 1.0);

          if (nextOpacity > 0) {
            final linePaint = Paint()
              ..color = point.color.withOpacity((opacity + nextOpacity) * 0.1)
              ..strokeWidth = point.size * 0.7
              ..strokeCap = StrokeCap.round
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

            canvas.drawLine(point.offset, nextPoint.offset, linePaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Premium Floating Particle
class _PremiumFloatingParticle extends StatefulWidget {
  final int index;
  const _PremiumFloatingParticle({required this.index});

  @override
  State<_PremiumFloatingParticle> createState() => _PremiumFloatingParticleState();
}

class _PremiumFloatingParticleState extends State<_PremiumFloatingParticle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _verticalAnimation;
  late Animation<double> _horizontalAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 4 + widget.index % 6),
      vsync: this,
    )..repeat(reverse: true);

    _verticalAnimation = Tween<double>(begin: 0, end: 60 + (widget.index % 80)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _horizontalAnimation = Tween<double>(begin: 0, end: 30 + (widget.index % 50)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuad),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
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
        return Positioned(
          left: 10 + (widget.index * 35) % MediaQuery.of(context).size.width.toInt() + _horizontalAnimation.value,
          top: _verticalAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 2 + (widget.index % 5).toDouble(),
              height: 2 + (widget.index % 5).toDouble(),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    [
                      AppTheme.electricBlue,
                      AppTheme.neonPink,
                      AppTheme.neonPurple,
                      AppTheme.neonGreen,
                    ][widget.index % 4].withOpacity(0.7),
                    [
                      AppTheme.electricBlue,
                      AppTheme.neonPink,
                      AppTheme.neonPurple,
                      AppTheme.neonGreen,
                    ][widget.index % 4].withOpacity(0),
                  ],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Simple fallback splash screen
class SimpleSplashScreen extends StatelessWidget {
  const SimpleSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryPurple.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                ShaderMask(
                  shaderCallback: (bounds) => AppTheme.rainbowGradient.createShader(bounds),
                  child: const Text(
                    'AI SKETCH',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Premium Assistant',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.electricBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.electricBlue),
                  strokeWidth: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}