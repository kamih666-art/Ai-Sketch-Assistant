import 'package:flutter/material.dart';
import 'dart:math';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glowing_container.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _dotController;
  int _currentPage = 0;

  final List<GuidePage> _pages = [
    GuidePage(
      title: 'Welcome to AI Sketch Assistant',
      description: 'An intelligent drawing app powered by cutting-edge AI that helps you create perfect sketches with professional-grade assistance.',
      icon: Icons.auto_awesome,
      color: AppTheme.primaryPurple,
      image: Icons.draw,
      features: const ['AI Powered', 'Smart Tools', 'Real-time Processing', 'Cloud Sync'],
      stats: const {'Users': '10K+', 'Drawings': '50K+', 'AI Models': '15+'},
    ),
    GuidePage(
      title: 'Canvas Drawing',
      description: 'Experience professional-grade digital drawing with precision tools, multiple brushes, and advanced AI assistance that understands your strokes.',
      icon: Icons.brush,
      color: AppTheme.electricBlue,
      image: Icons.format_paint,
      features: const ['Multiple Brushes', 'Pressure Sensitivity', 'Layer Support', 'Undo/Redo', 'Color Palettes', 'Zoom & Pan'],
      stats: const {'Brushes': '12+', 'Colors': '16.7M', 'Layers': '10+'},
    ),
    GuidePage(
      title: 'Air Drawing',
      description: 'Revolutionary gesture-based drawing using your camera! Draw in the air with hand tracking - no touch required, just your creativity.',
      icon: Icons.camera_alt,
      color: AppTheme.neonPink,
      image: Icons.air,
      features: const ['Hand Tracking', 'Gesture Controls', 'Real-time AI', 'Contactless', 'Voice Commands', 'Motion Smoothing'],
      stats: const {'FPS': '60+', 'Gestures': '8+', 'Accuracy': '99%'},
    ),
    GuidePage(
      title: 'AI Auto-Correction',
      description: 'Our advanced AI analyzes your sketches in real-time and automatically corrects shapes, smooths lines, and perfects your artwork.',
      icon: Icons.auto_fix_high,
      color: AppTheme.neonGreen,
      image: Icons.assistant_outlined,
      features: const ['Shape Detection', 'Line Smoothing', 'Auto Complete', 'Intelligent Fill', 'Smart Guides', 'Pattern Recognition'],
      stats: const {'Accuracy': '95%', 'Shapes': '50+', 'Speed': '10ms'},
    ),
    GuidePage(
      title: 'AI Tools Suite',
      description: 'Access 15+ powerful AI tools including Image Generator, Background Remover, Auto Colorizer, and more creative features.',
      icon: Icons.grid_view,
      color: AppTheme.neonYellow,
      image: Icons.auto_awesome_mosaic,
      features: const ['Text to Image', 'Sketch to Art', 'Magic Eraser', 'Photo to Sketch', 'Avatar Creator', 'Logo Generator'],
      stats: const {'Tools': '15+', 'Styles': '100+', 'Export': 'HD'},
    ),
    GuidePage(
      title: 'Premium Features',
      description: 'Unlock the full potential with premium features including cloud backup, HD export, layer management, and priority AI processing.',
      icon: Icons.star,
      color: AppTheme.neonPurple,
      image: Icons.workspace_premium,
      features: const ['Cloud Backup', 'HD Export', 'No Ads', 'Priority AI', 'Custom Brushes', 'Animation Support'],
      stats: const {'Storage': '10GB', 'Export': '4K', 'Formats': '8+'},
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _dotController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          // Animated Background
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  AppTheme.primaryPurple.withOpacity(0.15),
                  AppTheme.darkBg,
                  AppTheme.darkerBg,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Floating Particles
          ...List.generate(25, (index) => _GuideFloatingParticle(index: index)),

          SafeArea(
            child: Column(
              children: [
                // Top Bar with Skip Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FadeInLeft(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.glassBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome, size: 16, color: AppTheme.neonYellow),
                              const SizedBox(width: 6),
                              Text(
                                'AI SKETCH',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.electricBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      FadeInRight(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/mode-selection');
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white.withOpacity(0.7),
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Animated Progress Indicator
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _currentPage == index ? 32 : 10,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          gradient: _currentPage == index
                              ? LinearGradient(
                            colors: [AppTheme.electricBlue, AppTheme.neonPurple],
                          )
                              : null,
                          color: _currentPage == index
                              ? null
                              : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ),

                // Page View
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return _PremiumGuidePageContent(
                        page: page,
                        currentPage: index,
                        totalPages: _pages.length,
                      );
                    },
                  ),
                ),

                // Navigation Buttons
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      if (_currentPage > 0)
                        FadeInLeft(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOutCubic,
                                );
                              },
                              borderRadius: BorderRadius.circular(50),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppTheme.glassBg,
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.arrow_back, size: 20),
                                    SizedBox(width: 8),
                                    Text('Back'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 100),

                      // Next/Get Started Button
                      FadeInRight(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage < _pages.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutCubic,
                              );
                            } else {
                              Navigator.pushReplacementNamed(context, '/mode-selection');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _pages[_currentPage].color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: 8,
                            shadowColor: _pages[_currentPage].color.withOpacity(0.5),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentPage < _pages.length - 1
                                    ? Icons.arrow_forward
                                    : Icons.rocket_launch,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GuidePage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final IconData image;
  final List<String> features;
  final Map<String, String> stats;

  GuidePage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.image,
    required this.features,
    required this.stats,
  });
}

class _PremiumGuidePageContent extends StatefulWidget {
  final GuidePage page;
  final int currentPage;
  final int totalPages;

  const _PremiumGuidePageContent({
    required this.page,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  State<_PremiumGuidePageContent> createState() => _PremiumGuidePageContentState();
}

class _PremiumGuidePageContentState extends State<_PremiumGuidePageContent> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(_rotationController);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Animated Icon Container with Rotation
          FadeInUp(
            child: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return GlowingContainer(
                  size: 200,
                  color: widget.page.color,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rotating ring
                      Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.page.color.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      // Icon
                      Icon(
                        widget.page.image,
                        size: 80,
                        color: Colors.white,
                      ),
                      // Orbiting dots
                      ...List.generate(4, (index) {
                        final angle = (index * 2 * pi / 4) + _rotationAnimation.value;
                        final radius = 90.0;
                        return Positioned(
                          left: 100 + radius * cos(angle),
                          top: 100 + radius * sin(angle),
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.page.color,
                              boxShadow: [
                                BoxShadow(
                                  color: widget.page.color.withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 30),

          // Title
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: Text(
              widget.page.title,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              widget.page.description,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 30),

          // Stats Cards
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: Row(
              children: widget.page.stats.entries.map((entry) {
                return Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: widget.page.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 30),

          // Features Section
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: widget.page.color, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Key Features',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: widget.page.features.map((feature) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.page.color.withOpacity(0.2),
                              widget.page.color.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: widget.page.color.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: widget.page.color,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              feature,
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.page.color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Pro Tip (show for all pages except first and last)
          if (widget.currentPage != 0 && widget.currentPage != widget.totalPages - 1)
            const SizedBox(height: 20)
          else
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.page.color.withOpacity(0.1), Colors.transparent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.page.color.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: widget.page.color, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pro Tip',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: widget.page.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getProTip(widget.page.title),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _getProTip(String title) {
    switch (title) {
      case 'Canvas Drawing':
        return 'Use two fingers to zoom and pan. Long press for color picker.';
      case 'Air Drawing':
        return 'Keep your hand steady and ensure good lighting for best tracking.';
      case 'AI Auto-Correction':
        return 'Draw simple shapes first - AI will enhance them automatically!';
      case 'AI Tools Suite':
        return 'Try "Text to Image" for instant AI-generated artwork.';
      case 'Premium Features':
        return 'Upgrade to premium for unlimited access to all AI tools!';
      default:
        return 'Explore all features to unlock your creative potential!';
    }
  }
}

class _GuideFloatingParticle extends StatefulWidget {
  final int index;
  const _GuideFloatingParticle({required this.index});

  @override
  State<_GuideFloatingParticle> createState() => _GuideFloatingParticleState();
}

class _GuideFloatingParticleState extends State<_GuideFloatingParticle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _verticalAnimation;
  late Animation<double> _horizontalAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3 + widget.index % 5),
      vsync: this,
    )..repeat(reverse: true);
    _verticalAnimation = Tween<double>(begin: 0, end: 100 + (widget.index % 100)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    _horizontalAnimation = Tween<double>(begin: 0, end: 50 + (widget.index % 80)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuad),
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
          left: 20 + (widget.index * 45) % MediaQuery.of(context).size.width.toInt() + _horizontalAnimation.value,
          top: _verticalAnimation.value,
          child: Container(
            width: 2 + (widget.index % 4).toDouble(),
            height: 2 + (widget.index % 4).toDouble(),
            decoration: BoxDecoration(
              color: [
                AppTheme.electricBlue,
                AppTheme.neonPink,
                AppTheme.neonPurple,
                AppTheme.neonGreen,
              ][widget.index % 4].withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}