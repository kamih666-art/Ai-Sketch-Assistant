import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:training/features/ai_assistant/ai_assistant.dart';

import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'features/guide/guide_screen.dart';
import 'features/mode_selection/mode_selection.dart';
import 'features/air_drawing/air_drawing.dart';
import 'features/canvas/screens/home_screen.dart';
import 'package:training/features/magic/magic_eraser.dart';
import 'package:training/features/sketch_to_art/sketch_art.dart';
import 'package:training/features/photo_to_sketch/photo_sketch.dart';
import 'package:training/features/ai_Image_generator/image_generator.dart';
import 'providers/ai_provider.dart';
import 'providers/drawing_provider.dart';
import 'providers/air_drawing_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DrawingProvider()),
        ChangeNotifierProvider(create: (_) => AIProvider()),
        ChangeNotifierProvider(create: (_) => AirDrawingProvider())
      ],
      child: MaterialApp(
        title: 'AI Sketch Assistant',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark, // Changed to dark for premium look
        debugShowCheckedModeBanner: false,

        // Initial route - starts with splash
        initialRoute: '/splash',

        // Routes configuration
        routes: {
          // Main Screens
          '/splash': (context) => const SplashScreen(),
          '/guide': (context) => const GuideScreen(),
          '/mode-selection': (context) => const EnhancedModeSelectionScreen(),
          '/air-drawing': (context) => const AirDrawingScreen(),
          '/home': (context) => const CompleteCanvasScreen(),
          '/ai-assistant': (context) => const AIAssistantScreen(),

          // New AI Feature Screens
          '/ai-image': (context) => const AIImageGeneratorScreen(),
          '/sketch-to-art': (context) => const SketchToArtScreen(),
          '/photo-sketch': (context) => const PhotoToSketchScreen(),
          '/eraser': (context) => const MagicEraserScreen(),
        },

        // Fallback for unknown routes
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              backgroundColor: AppTheme.darkBg,
              appBar: AppBar(
                title: const Text('Page Not Found'),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: AppTheme.neonPink,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '404 - Page Not Found',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'The page you are looking for does not exist',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/mode-selection');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Go Back Home'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}