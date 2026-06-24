import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glowing_container.dart';

class EnhancedModeSelectionScreen extends StatefulWidget {
  const EnhancedModeSelectionScreen({super.key});

  @override
  State<EnhancedModeSelectionScreen> createState() => _EnhancedModeSelectionScreenState();
}

class _EnhancedModeSelectionScreenState extends State<EnhancedModeSelectionScreen> with TickerProviderStateMixin {
  late AnimationController _aiButtonController;
  late Animation<double> _aiButtonAnimation;

  final List<FeatureCard> _features = [
    FeatureCard(
      title: 'Canvas Drawing',
      subtitle: 'Traditional Touch Drawing',
      description: 'Draw directly on screen with precision tools and AI assistance.',
      icon: Icons.brush,
      gradient: [AppTheme.electricBlue, AppTheme.primaryPurple],
      features: const ['Touch & Stylus', 'Multiple Brushes', 'Layer Management', 'Undo/Redo', 'AI Enhancement'],
      stats: const {'Tools': '15+', 'Brushes': '12+'},
      route: '/home',
      isRecommended: true,
    ),
    FeatureCard(
      title: 'Air Drawing',
      subtitle: 'Gesture-Based Drawing',
      description: 'Draw in the air using camera hand tracking. No touch required!',
      icon: Icons.camera_alt,
      gradient: [AppTheme.neonPink, AppTheme.neonPurple],
      features: const ['Hand Tracking', 'Gesture Controls', 'Real-time AI', 'Contactless', 'Voice Commands'],
      stats: const {'FPS': '60+', 'Gestures': '8+'},
      route: '/air-drawing',
      isBeta: true,
    ),
    FeatureCard(
      title: 'AI Image Generator',
      subtitle: 'Text to Masterpiece',
      description: 'Generate stunning artwork from text descriptions.',
      icon: Icons.image,
      gradient: [AppTheme.neonGreen, AppTheme.primaryPurple],
      features: const ['Text to Image', 'Multiple Styles', 'HD Quality', 'Fast Generation'],
      stats: const {'Styles': '50+', 'Resolution': '4K'},
      route: '/ai-image',
      isNew: true,
    ),
    FeatureCard(
      title: 'Sketch to Art',
      subtitle: 'Transform Your Sketches',
      description: 'Convert rough sketches into professional artwork.',
      icon: Icons.auto_awesome,
      gradient: [AppTheme.neonYellow, AppTheme.neonOrange],
      features: const ['Auto Coloring', 'Style Transfer', 'Line Smoothing', 'Detail Enhancement'],
      stats: const {'Styles': '30+', 'Speed': '<5s'},
      route: '/sketch-to-art',
      isNew: true,
    ),
    FeatureCard(
      title: 'Photo to Sketch',
      subtitle: 'Turn Photos into Art',
      description: 'Convert any photo into a beautiful pencil sketch.',
      icon: Icons.photo_camera,
      gradient: [AppTheme.neonPurple, AppTheme.electricBlue],
      features: const ['Pencil Sketch', 'Color Sketch', 'Cartoon Style', 'Watercolor'],
      stats: const {'Filters': '25+', 'Export': 'HD'},
      route: '/photo-sketch',
    ),
    FeatureCard(
      title: 'Magic Eraser',
      subtitle: 'Remove Anything',
      description: 'Intelligently remove unwanted objects from your drawings.',
      icon: Icons.remove,
      gradient: [AppTheme.neonPink, AppTheme.neonGreen],
      features: const ['Object Removal', 'Text Removal', 'Background Cleanup', 'Smart Fill'],
      stats: const {'Accuracy': '98%', 'Speed': '<2s'},
      route: '/eraser',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _aiButtonController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _aiButtonAnimation = CurvedAnimation(
      parent: _aiButtonController,
      curve: Curves.elasticOut,
    );

    _aiButtonController.forward();
  }

  @override
  void dispose() {
    _aiButtonController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      floatingActionButton: ScaleTransition(
        scale: _aiButtonAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(context, '/ai-assistant');
            },
            backgroundColor: AppTheme.neonYellow,
            foregroundColor: Colors.white,
            elevation: 12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(color: AppTheme.neonYellow, width: 2),
            ),
            icon: const Icon(Icons.auto_awesome, size: 24),
            label: const Text(
              'AI Assistant',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Animated Background
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.5,
                colors: [
                  AppTheme.primaryPurple.withOpacity(0.3),
                  AppTheme.darkBg,
                  AppTheme.darkerBg,
                ],
              ),
            ),
          ),

          // Floating Particles
          ...List.generate(20, (index) => _ModeSelectionParticle(index: index)),

          SafeArea(
            child: Column(
              children: [
                // Premium Header - Reduced padding
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FadeInLeft(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.glassBg,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                color: AppTheme.neonYellow,
                                size: 20,
                              ),
                            ),
                          ),
                          FadeInRight(
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(context, '/guide');
                                  },
                                  icon: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.glassBg,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.help_outline,
                                      color: Colors.white70,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.neonYellow.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppTheme.neonYellow.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.auto_awesome,
                                        color: AppTheme.neonYellow,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'AI Ready',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppTheme.neonYellow,
                                          fontWeight: FontWeight.w600,
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

                      const SizedBox(height: 16),

                      // Greeting - Simplified
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeInUp(
                            delay: const Duration(milliseconds: 100),
                            child: Row(
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.electricBlue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  '👋',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          FadeInUp(
                            delay: const Duration(milliseconds: 200),
                            child: const Text(
                              'Choose Your Mode',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Feature Grid - FIXED: Now scrollable
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 215, // Fixed height for each card
                      ),
                      itemCount: _features.length,
                      itemBuilder: (context, index) {
                        return FadeInUp(
                          delay: Duration(milliseconds: 300 + (index * 50)),
                          child: _PremiumFeatureCard(
                            feature: _features[index],
                            onTap: () {
                              Navigator.pushNamed(context, _features[index].route);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 70), // Space for FAB
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureCard {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final List<String> features;
  final Map<String, String> stats;
  final String route;
  final bool isRecommended;
  final bool isBeta;
  final bool isNew;

  FeatureCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.features,
    required this.stats,
    required this.route,
    this.isRecommended = false,
    this.isBeta = false,
    this.isNew = false,
  });
}

class _PremiumFeatureCard extends StatelessWidget {
  final FeatureCard feature;
  final VoidCallback onTap;

  const _PremiumFeatureCard({
    required this.feature,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.glassBg,
              AppTheme.glassBg.withOpacity(0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [feature.gradient.first, feature.gradient.last],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(feature.icon, color: Colors.white, size: 22),
                  ),
                  if (feature.isRecommended)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: const Text(
                        'TOP',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    )
                  else if (feature.isBeta)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: const Text(
                        'BETA',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    )
                  else if (feature.isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.electricBlue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.electricBlue.withOpacity(0.3)),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.electricBlue,
                          ),
                        ),
                      ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    feature.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    feature.subtitle,
                    style: TextStyle(
                      fontSize: 9,
                      color: feature.gradient.first,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Stats
                  Row(
                    children: feature.stats.entries.map((entry) {
                      return Expanded(
                        child: Column(
                          children: [
                            Text(
                              entry.value,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 7,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    feature.description,
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white.withOpacity(0.7),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Action Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [feature.gradient.first.withOpacity(0.2), feature.gradient.last.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: feature.gradient.first.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Try Now',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: feature.gradient.first,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 10,
                    color: feature.gradient.first,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeSelectionParticle extends StatefulWidget {
  final int index;
  const _ModeSelectionParticle({required this.index});

  @override
  State<_ModeSelectionParticle> createState() => _ModeSelectionParticleState();
}

class _ModeSelectionParticleState extends State<_ModeSelectionParticle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _verticalAnimation;
  late Animation<double> _horizontalAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3 + widget.index % 5),
      vsync: this,
    )..repeat(reverse: true);

    _verticalAnimation = Tween<double>(begin: 0, end: 80 + (widget.index % 120)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    _horizontalAnimation = Tween<double>(begin: 0, end: 20 + (widget.index % 50)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuad),
    );
    _opacityAnimation = Tween<double>(begin: 0.1, end: 0.6).animate(
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
        return Positioned(
          left: 20 + (widget.index * 35) % MediaQuery.of(context).size.width.toInt() + _horizontalAnimation.value,
          top: _verticalAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: 2 + (widget.index % 3).toDouble(),
              height: 2 + (widget.index % 3).toDouble(),
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