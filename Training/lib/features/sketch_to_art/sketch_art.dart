import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/glowing_container.dart';
import 'package:training/widgets/comming_soon_widgets.dart';

class SketchToArtScreen extends StatelessWidget {
  const SketchToArtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  AppTheme.neonYellow.withOpacity(0.3),
                  AppTheme.darkBg,
                  AppTheme.darkerBg,
                ],
              ),
            ),
          ),

          ...List.generate(20, (index) => ComingSoonParticle(index: index)),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      FadeInLeft(
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.glassBg,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                          ),
                        ),
                      ),
                      const Spacer(),
                      FadeInRight(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.neonYellow.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.neonYellow.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.auto_awesome, size: 14, color: AppTheme.neonYellow),
                              const SizedBox(width: 6),
                              Text('AI Powered', style: TextStyle(fontSize: 11, color: AppTheme.neonYellow)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Column(
                  children: [
                    FadeInUp(
                      child: GlowingContainer(
                        size: 140,
                        color: AppTheme.neonYellow,
                        child: const Icon(Icons.auto_awesome, size: 60, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 30),
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: const Text(
                        'Sketch to Art',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        'Coming Soon',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.neonYellow,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.glassBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Transform your rough sketches into\nmasterpieces with AI',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              alignment: WrapAlignment.center,
                              children: const [
                                FeatureChip(label: 'Auto Coloring'),
                                FeatureChip(label: 'Style Transfer'),
                                FeatureChip(label: 'Line Smoothing'),
                                FeatureChip(label: 'Detail Enhancement'),
                                FeatureChip(label: 'HD Export'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: Container(
                    margin: const EdgeInsets.all(30),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.neonYellow.withOpacity(0.2), AppTheme.neonYellow.withOpacity(0.05)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppTheme.neonYellow.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonYellow),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'In Development',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.neonYellow,
                            fontWeight: FontWeight.w500,
                          ),
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
    );
  }
}