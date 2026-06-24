import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:image_picker/image_picker.dart';
import '../../../providers/drawing_provider.dart';
import '../../../providers/ai_provider.dart';
import 'dart:math';
import 'package:training/providers/asset_loader.dart';
import 'package:training/providers/png_loader.dart';
import 'Canvas_image.dart';



class CompleteCanvasScreen extends StatefulWidget {
  const CompleteCanvasScreen({super.key});

  @override
  State<CompleteCanvasScreen> createState() => _CompleteCanvasScreenState();
}

class _CompleteCanvasScreenState extends State<CompleteCanvasScreen> {
  bool _showTools = true;
  bool _showAIOverlay = true;
  double _brushSize = 5.0;
  Color _selectedColor = Colors.black;
  String _selectedTool = 'brush';
  int _repaintKey = 0;

  final Map<String, bool> _assetCache = {};
  bool _assetsLoaded = false;

  final ScreenshotController _screenshotController = ScreenshotController();
  final AssetLoader _assetLoader = AssetLoader();
  final ImagePicker _imagePicker = ImagePicker();

  // Complete 3D Objects List
  final List<Map<String, dynamic>> _threeDObjectsList = [
    // Basic Shapes
    {'name': 'Cube', 'icon': Icons.crop_square, 'imagePath': 'assets/3d/cube.png', 'id': 'cube', 'size': 100.0, 'category': 'Basic'},
    {'name': 'Sphere', 'icon': Icons.circle, 'imagePath': 'assets/3d/sphere.png', 'id': 'sphere', 'size': 100.0, 'category': 'Basic'},
    {'name': 'Cylinder', 'icon': Icons.view_in_ar, 'imagePath': 'assets/3d/cylinder.png', 'id': 'cylinder', 'size': 100.0, 'category': 'Basic'},
    {'name': 'Cone', 'icon': Icons.change_history, 'imagePath': 'assets/3d/cone.png', 'id': 'cone', 'size': 100.0, 'category': 'Basic'},
    {'name': 'Pyramid', 'icon': Icons.change_history, 'imagePath': 'assets/3d/pyramid.png', 'id': 'pyramid', 'size': 100.0, 'category': 'Basic'},
    // Buildings
    {'name': 'House', 'icon': Icons.home, 'imagePath': 'assets/3d/house.png', 'id': 'house', 'size': 120.0, 'category': 'Buildings'},
    {'name': 'Window', 'icon': Icons.crop_original, 'imagePath': 'assets/3d/window.png', 'id': 'window', 'size': 80.0, 'category': 'Buildings'},
    {'name': 'Door', 'icon': Icons.door_front_door, 'imagePath': 'assets/3d/door.png', 'id': 'door', 'size': 90.0, 'category': 'Buildings'},
    // Furniture
    {'name': 'Sofa', 'icon': Icons.weekend, 'imagePath': 'assets/3d/sofa.png', 'id': 'sofa', 'size': 140.0, 'category': 'Furniture'},
    {'name': 'Table', 'icon': Icons.table_restaurant, 'imagePath': 'assets/3d/table.png', 'id': 'table', 'size': 100.0, 'category': 'Furniture'},
    {'name': 'Chair', 'icon': Icons.chair, 'imagePath': 'assets/3d/chair.png', 'id': 'chair', 'size': 80.0, 'category': 'Furniture'},
    {'name': 'Bed', 'icon': Icons.bed, 'imagePath': 'assets/3d/bed.png', 'id': 'bed', 'size': 160.0, 'category': 'Furniture'},
    {'name': 'Lamp', 'icon': Icons.emoji_objects, 'imagePath': 'assets/3d/lamp.png', 'id': 'lamp', 'size': 60.0, 'category': 'Furniture'},
    {'name': 'Bookshelf', 'icon': Icons.menu_book, 'imagePath': 'assets/3d/bookshelf.png', 'id': 'bookshelf', 'size': 100.0, 'category': 'Furniture'},
    // Nature
    {'name': 'Tree', 'icon': Icons.park, 'imagePath': 'assets/3d/tree.png', 'id': 'tree', 'size': 130.0, 'category': 'Nature'},
    {'name': 'Flower', 'icon': Icons.local_florist, 'imagePath': 'assets/3d/flower.png', 'id': 'flower', 'size': 60.0, 'category': 'Nature'},
    {'name': 'Bench', 'icon': Icons.weekend, 'imagePath': 'assets/3d/bench.png', 'id': 'bench', 'size': 120.0, 'category': 'Nature'},
    {'name': 'Mountain', 'icon': Icons.landscape, 'imagePath': 'assets/3d/mountain.png', 'id': 'mountain', 'size': 150.0, 'category': 'Nature'},
    {'name': 'Sun', 'icon': Icons.wb_sunny, 'imagePath': 'assets/3d/sun.png', 'id': 'sun', 'size': 80.0, 'category': 'Nature'},
    {'name': 'Cloud', 'icon': Icons.cloud, 'imagePath': 'assets/3d/cloud.png', 'id': 'cloud', 'size': 90.0, 'category': 'Nature'},
    {'name': 'Star', 'icon': Icons.star, 'imagePath': 'assets/3d/star.png', 'id': 'star', 'size': 50.0, 'category': 'Nature'},
    // Vehicles
    {'name': 'Car', 'icon': Icons.directions_car, 'imagePath': 'assets/3d/car.png', 'id': 'car', 'size': 120.0, 'category': 'Vehicles'},
    {'name': 'Bicycle', 'icon': Icons.directions_bike, 'imagePath': 'assets/3d/bicycle.png', 'id': 'bicycle', 'size': 100.0, 'category': 'Vehicles'},
    // Objects
    {'name': 'Clock', 'icon': Icons.access_time, 'imagePath': 'assets/3d/clock.png', 'id': 'clock', 'size': 80.0, 'category': 'Objects'},
    {'name': 'TV', 'icon': Icons.tv, 'imagePath': 'assets/3d/tv.png', 'id': 'tv', 'size': 100.0, 'category': 'Objects'},
    {'name': 'Laptop', 'icon': Icons.laptop, 'imagePath': 'assets/3d/laptop.png', 'id': 'laptop', 'size': 90.0, 'category': 'Objects'},
    {'name': 'Microwave', 'icon': Icons.kitchen, 'imagePath': 'assets/3d/microwave.png', 'id': 'microwave', 'size': 100.0, 'category': 'Objects'},
    {'name': 'Dishsoap', 'icon': Icons.cleaning_services, 'imagePath': 'assets/3d/dishsoap.png', 'id': 'dishsoap', 'size': 100.0, 'category': 'Objects'},
    {'name': 'Glass', 'icon': Icons.local_drink, 'imagePath': 'assets/3d/glass.png', 'id': 'glass', 'size': 100.0, 'category': 'Objects'},
    {'name': 'Cup', 'icon': Icons.coffee, 'imagePath': 'assets/3d/cup.png', 'id': 'cup', 'size': 100.0, 'category': 'Objects'},
    {'name': 'Swing', 'icon': Icons.toys, 'imagePath': 'assets/3d/swing.png', 'id': 'swing', 'size': 100.0, 'category': 'Objects'},
    {'name': 'Mirror', 'icon': Icons.flip, 'imagePath': 'assets/3d/mirror.png', 'id': 'mirror', 'size': 100.0, 'category': 'Objects'},
    {'name': 'Frame', 'icon': Icons.crop_square, 'imagePath': 'assets/3d/frame.png', 'id': 'frame', 'size': 100.0, 'category': 'Objects'},
    {'name': 'Seesaw', 'icon': Icons.balance, 'imagePath': 'assets/3d/seesaw.png', 'id': 'seesaw', 'size': 100.0, 'category': 'Objects'},
];


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAssets();
      final drawingProvider = context.read<DrawingProvider>();

      drawingProvider.onObjectPlaced = (objectName) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$objectName placed! Tap again to place more'),
              duration: const Duration(seconds: 1),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      };

      setState(() {
        _brushSize = drawingProvider.currentStrokeWidth;
        _selectedColor = drawingProvider.currentColor;
        _selectedTool = drawingProvider.currentTool;
      });
    });
  }

  @override
  void dispose() {
    context.read<DrawingProvider>().onObjectPlaced = null;
    super.dispose();
  }

  Future<void> _initializeAssets() async {
    final aiProvider = Provider.of<AIProvider>(context, listen: false);

    for (var bg in aiProvider.backgrounds) {
      if (bg.path.isNotEmpty) {
        final exists = await _assetLoader.assetExists(bg.path);
        _assetCache[bg.path] = exists;
      }
    }

    // Load all 3D assets
    for (var obj in _threeDObjectsList) {
      final exists = await _assetLoader.assetExists(obj['imagePath'] as String);
      _assetCache[obj['imagePath'] as String] = exists;
    }

    setState(() {
      _assetsLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final drawingProvider = Provider.of<DrawingProvider>(context);
    final aiProvider = Provider.of<AIProvider>(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Screenshot(
        controller: _screenshotController,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: _buildBackground(aiProvider),
            ),

            Positioned.fill(
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (event) {
                  final position = event.localPosition;
                  final dp = context.read<DrawingProvider>();

                  // CHECK IF TAPPING ON AN OBJECT/IMAGE FIRST
                  bool hitObject = false;

                  // Check uploaded images (top layer)
                  for (int i = dp.uploadedImages.length - 1; i >= 0; i--) {
                    final img = dp.uploadedImages[i];
                    if (img.bounds.contains(position)) {
                      dp.selectUploadedImage(img.id);
                      dp.startDragging(position); // <-- ENABLE DRAGGING
                      hitObject = true;
                      break;
                    }
                  }

                  // Check 3D objects
                  if (!hitObject) {
                    for (int i = dp.threeDObjects.length - 1; i >= 0; i--) {
                      final obj = dp.threeDObjects[i];
                      final hitRect = Rect.fromCenter(
                        center: obj.position,
                        width: obj.size * obj.scale.abs(),
                        height: obj.size * obj.scale.abs(),
                      );
                      if (hitRect.contains(position)) {
                        dp.select3DObject(obj);
                        dp.startDragging(position); // <-- ENABLE DRAGGING
                        hitObject = true;
                        break;
                      }
                    }
                  }

                  // If hit an object, show transform controls
                  if (hitObject) {
                    setState(() {});
                    return;
                  }

                  // Clear selection if tapping empty area
                  if (dp.selected3DElement != null || dp.selectedUploadedImage != null) {
                    dp.clearSelection();
                    setState(() {});
                  }

                  // Original drawing logic
                  if (_selectedTool == 'eraser') {
                    drawingProvider.startErasing(position);
                    setState(() {});
                    return;
                  }

                  if (!drawingProvider.isDrawing) {
                    drawingProvider.startDragging(position);
                  }
                  if (!drawingProvider.isDragging) {
                    drawingProvider.startDrawing(position);
                  }
                },
                onPointerMove: (event) {
                  final position = event.localPosition;

                  if (_selectedTool == 'eraser') {
                    drawingProvider.updateErasing(position);
                    setState(() {});
                    return;
                  }

                  if (drawingProvider.isDragging) {
                    drawingProvider.updateDragging(position);
                  } else {
                    drawingProvider.updateDrawing(position);
                    if (drawingProvider.currentTool != 'shapes' &&
                        drawingProvider.currentTool != 'text' &&
                        drawingProvider.currentTool != '3dobjects') {
                      final currentStroke = drawingProvider.currentStroke;
                      if (currentStroke.length > 5 && currentStroke.length % 10 == 0) {
                        aiProvider.analyzePoints(currentStroke);
                      }
                    }
                    setState(() {});
                  }
                },
                onPointerUp: (event) {
                  if (_selectedTool == 'eraser') {
                    drawingProvider.stopErasing();
                    setState(() {});
                    return;
                  }

                  if (drawingProvider.isDragging) {
                    drawingProvider.stopDragging();
                  } else {
                    drawingProvider.stopDrawing();
                    setState(() {});
                    if (aiProvider.autoCorrectionEnabled &&
                        drawingProvider.currentTool != 'shapes' &&
                        drawingProvider.currentTool != 'text' &&
                        drawingProvider.currentTool != '3dobjects' &&
                        aiProvider.detectedShape.isNotEmpty &&
                        aiProvider.detectionConfidence > 0.65) {
                      _showAutoCorrectionDialog(context, drawingProvider, aiProvider);
                    }
                  }
                  setState(() {});
                },
                child: Consumer2<DrawingProvider, AIProvider>(
                  builder: (context, drawingProvider, aiProvider, child) {
                    return RepaintBoundary(
                      key: ValueKey('canvas_${drawingProvider.threeDObjects.length}_$_repaintKey'),
                      child: CustomPaint(
                        painter: _AICanvasPainter(
                          strokes: drawingProvider.strokes,
                          currentStroke: drawingProvider.currentStroke,
                          strokeColors: drawingProvider.strokeColors,
                          strokeWidths: drawingProvider.strokeWidths,
                          elements: drawingProvider.elements,
                          threeDObjects: drawingProvider.threeDObjects,
                          uploadedImages: drawingProvider.uploadedImages,
                          showAIOverlay: _showAIOverlay && aiProvider.showDetectionBoxes,
                          aiProvider: aiProvider,
                          selectedColor: drawingProvider.currentColor,
                          brushSize: _brushSize,
                          shapePreviewPoints: drawingProvider.shapePreviewPoints,
                          selectedShape: drawingProvider.selectedShape,
                          isDrawingShape: drawingProvider.isDrawingShape,
                          texts: drawingProvider.texts,
                          selectedElement: drawingProvider.selectedElement,
                          selected3DElement: drawingProvider.selected3DElement,
                          selectedUploadedImage: drawingProvider.selectedUploadedImage,
                          isErasing: _selectedTool == 'eraser',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildAppBar(context, aiProvider, drawingProvider),
            ),

            if (_showTools)
              Positioned(
                left: 10,
                top: 80,
                child: _buildLeftToolbar(context, drawingProvider),
              ),

            if (_showTools)
              Positioned(
                right: 10,
                top: 80,
                child: _buildAIToolbar(context, aiProvider),
              ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomToolbar(context, drawingProvider, aiProvider),
            ),

            if (_showAIOverlay && aiProvider.detectedShape.isNotEmpty && aiProvider.detectionConfidence > 0.5)
              Positioned(
                top: 80,
                left: 10,
                right: 10,
                child: _buildAIDetectionCard(aiProvider, screenSize),
              ),

            if (aiProvider.currentSuggestion != null && aiProvider.autoCorrectionEnabled)
              Positioned(
                bottom: 100,
                left: 10,
                right: 10,
                child: _buildAssetReplacementCard(context, aiProvider, drawingProvider),
              ),
            // ========== TRANSFORM TOOLBAR (appears when object selected) ==========
            if (drawingProvider.selected3DElement != null || drawingProvider.selectedUploadedImage != null)
              Positioned(
                left: 10,
                bottom: 110,
                child: _buildTransformToolbar(drawingProvider),
              ),

            if (aiProvider.currentSuggestion != null && aiProvider.autoCorrectionEnabled)
              Positioned(
                bottom: 100,
                left: 10,
                right: 10,
                child: _buildAssetReplacementCard(context, aiProvider, drawingProvider),
              ),
            if (drawingProvider.isPlacing3DObject && drawingProvider.selected3DObject != null)
              Positioned(
                top: screenSize.height / 2 - 80,
                left: screenSize.width / 2 - 150,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          drawingProvider.selected3DObject!.icon,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Tap to place ${drawingProvider.selected3DObject!.name}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (!_assetsLoaded)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ========== ENHANCED 3D OBJECT SELECTION DIALOG ==========

  void _show3DObjectSelectionDialog(BuildContext context, DrawingProvider drawingProvider) {
    // Group objects by category
    final Map<String, List<Map<String, dynamic>>> groupedObjects = {};
    for (var obj in _threeDObjectsList) {
      final category = obj['category'] as String;
      if (!groupedObjects.containsKey(category)) {
        groupedObjects[category] = [];
      }
      groupedObjects[category]!.add(obj);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            width: min(500, MediaQuery.of(context).size.width - 32),
            height: 550,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade900, Colors.purple.shade900],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.view_in_ar, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        '3D Objects Library',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab Bar
                Expanded(
                  child: DefaultTabController(
                    length: groupedObjects.keys.length,
                    child: Column(
                      children: [
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          height: 45,
                          child: TabBar(
                            isScrollable: true,
                            tabs: groupedObjects.keys.map((category) {
                              return Tab(
                                child: Row(
                                  children: [
                                    _getCategoryIcon(category),
                                    const SizedBox(width: 4),
                                    Text(category, style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              );
                            }).toList(),
                            labelColor: Colors.blue,
                            unselectedLabelColor: Colors.white54,
                            indicatorColor: Colors.blue,
                          ),
                        ),

                        // Tab Content
                        Expanded(
                          child: TabBarView(
                            children: groupedObjects.keys.map((category) {
                              final objects = groupedObjects[category]!;
                              return GridView.builder(
                                padding: const EdgeInsets.all(12),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 0.85,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemCount: objects.length,
                                itemBuilder: (context, index) {
                                  final obj = objects[index];
                                  return FutureBuilder<ui.Image?>(
                                    future: PNGLoader.loadImage(obj['imagePath']),
                                    builder: (context, snapshot) {
                                      final image = snapshot.data;
                                      return GestureDetector(
                                        onTap: () async {
                                          final threeDObject = ThreeDObject(
                                            id: obj['id'],
                                            name: obj['name'],
                                            assetPath: obj['imagePath'],
                                            icon: obj['icon'],
                                            position: Offset.zero,
                                            size: obj['size'],
                                            scale: 1.0,
                                            rotation: 0.0,
                                            cachedImage: image,
                                          );
                                          drawingProvider.select3DObject(threeDObject);
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${obj['name']} selected! Tap canvas to place'),
                                              backgroundColor: Colors.blue,
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[900],
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.blue.withOpacity(0.5),
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: snapshot.connectionState == ConnectionState.waiting
                                                      ? const CircularProgressIndicator(color: Colors.blue)
                                                      : image != null
                                                      ? ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: CustomPaint(
                                                      painter: _ImagePainter(image),
                                                      size: const Size(60, 60),
                                                    ),
                                                  )
                                                      : Icon(obj['icon'], color: Colors.blue, size: 40),
                                                ),
                                              ),
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.withOpacity(0.2),
                                                  borderRadius: const BorderRadius.only(
                                                    bottomLeft: Radius.circular(12),
                                                    bottomRight: Radius.circular(12),
                                                  ),
                                                ),
                                                child: Text(
                                                  obj['name'],
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Close Button
                Container(
                  padding: const EdgeInsets.all(12),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey[800],
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getCategoryIcon(String category) {
    switch (category) {
      case 'Basic':
        return const Icon(Icons.shape_line, size: 16);
      case 'Buildings':
        return const Icon(Icons.home, size: 16);
      case 'Furniture':
        return const Icon(Icons.weekend, size: 16);
      case 'Nature':
        return const Icon(Icons.park, size: 16);
      case 'Vehicles':
        return const Icon(Icons.directions_car, size: 16);
      case 'Objects':
        return const Icon(Icons.category, size: 16);
      case 'Food':
        return const Icon(Icons.restaurant, size: 16);
      default:
        return const Icon(Icons.category, size: 16);
    }
  }
  // ========== APP BAR ==========
  Widget _buildAppBar(BuildContext context, AIProvider aiProvider, DrawingProvider drawingProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/mode-selection',
                    (route) => false,
              );
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
          const SizedBox(width: 4),
          const Flexible(
            child: Text(
              'AI Sketch Canvas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.auto_awesome,
                  color: aiProvider.autoCorrectionEnabled ? Colors.green : Colors.grey,
                  size: 16,
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: aiProvider.autoCorrectionEnabled,
                  onChanged: (value) => aiProvider.toggleAutoCorrection(),
                  activeColor: Colors.green,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => setState(() => _showTools = !_showTools),
            icon: Icon(
              _showTools ? Icons.visibility_off : Icons.visibility,
              color: Colors.white,
              size: 20,
            ),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                if (_selectedTool == 'eraser') {
                  _selectedTool = 'brush';
                  drawingProvider.selectTool('brush');
                  drawingProvider.updateStrokeWidth(_brushSize);
                  drawingProvider.updateColor(_selectedColor);
                } else {
                  _selectedTool = 'eraser';
                  drawingProvider.selectTool('eraser');
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_selectedTool == 'eraser' ? 'Eraser mode: Drag to erase strokes' : 'Brush mode: Draw freely'),
                  duration: const Duration(milliseconds: 800),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Icon(
              _selectedTool == 'eraser' ? Icons.brush : Icons.cleaning_services,
              color: _selectedTool == 'eraser' ? Colors.orange : Colors.white,
              size: 20,
            ),
            tooltip: _selectedTool == 'eraser' ? 'Switch to Brush' : 'Switch to Eraser',
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(6),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white, size: 20),
            onPressed: _showAssetStatusDialog,
            tooltip: 'Asset Status',
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }

  // ========== LEFT TOOLBAR ==========
  Widget _buildLeftToolbar(BuildContext context, DrawingProvider drawingProvider) {
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ToolButton(
              icon: Icons.brush,
              label: 'Brush',
              isSelected: drawingProvider.currentTool == 'brush',
              onTap: () {
                drawingProvider.selectTool('brush');
                drawingProvider.updateStrokeWidth(5.0);
                setState(() {
                  _selectedTool = 'brush';
                  _selectedColor = drawingProvider.currentColor;
                  _brushSize = 5.0;
                });
              },
            ),
            _ToolButton(
              icon: Icons.edit,
              label: 'Pencil',
              isSelected: drawingProvider.currentTool == 'pencil',
              onTap: () {
                drawingProvider.selectTool('pencil');
                drawingProvider.updateStrokeWidth(2.0);
                setState(() {
                  _selectedTool = 'pencil';
                  _selectedColor = drawingProvider.currentColor;
                  _brushSize = 2.0;
                });
              },
            ),
            _ToolButton(
              icon: Icons.format_shapes,
              label: 'Shapes',
              isSelected: drawingProvider.currentTool == 'shapes',
              onTap: () {
                _showShapeSelectionDialog(context, drawingProvider);
              },
            ),
            _ToolButton(
              icon: Icons.text_fields,
              label: 'Text',
              isSelected: drawingProvider.currentTool == 'text',
              onTap: () {
                _showTextInputDialog(context, drawingProvider);
              },
            ),
            _ToolButton(
              icon: Icons.view_in_ar,
              label: '3D',
              isSelected: drawingProvider.currentTool == '3dobjects',
              onTap: () {
                _show3DObjectSelectionDialog(context, drawingProvider);
              },
            ),
            _ToolButton(
              icon: Icons.upload,
              label: 'Upload',
              isSelected: false,
              onTap: () {
                _uploadImageFromGallery();
              },
            ),
            const Divider(color: Colors.white30, height: 16),
            _ToolButton(
              icon: Icons.undo,
              label: 'Undo',
              isSelected: false,
              onTap: drawingProvider.canUndo ? () {
                drawingProvider.undo();
              } : null,
            ),
            _ToolButton(
              icon: Icons.redo,
              label: 'Redo',
              isSelected: false,
              onTap: drawingProvider.canRedo ? () {
                drawingProvider.redo();
              } : null,
            ),
            _ToolButton(
              icon: Icons.delete,
              label: 'Clear',
              isSelected: false,
              onTap: () {
                _showClearConfirmationDialog(context, drawingProvider);
              },
            ),
          ],
        ),
      ),
    );
  }
  // ========== AI TOOLBAR ==========
  Widget _buildAIToolbar(BuildContext context, AIProvider aiProvider) {
    return Container(
      width: 200,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 160,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'AI Controls',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Correction',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    Text(
                      '${(aiProvider.correctionStrength * 100).toInt()}%',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
                Slider(
                  value: aiProvider.correctionStrength,
                  min: 0.1,
                  max: 1.0,
                  onChanged: aiProvider.updateCorrectionStrength,
                  activeColor: Colors.green,
                  divisions: 9,
                  label: '${(aiProvider.correctionStrength * 100).toInt()}%',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Show Boxes',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Switch(
                  value: _showAIOverlay,
                  onChanged: (value) => setState(() => _showAIOverlay = value),
                  activeColor: Colors.blue,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Background',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: aiProvider.backgrounds.length,
                itemBuilder: (context, index) {
                  final bg = aiProvider.backgrounds[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 4),
                    child: ChoiceChip(
                      label: Text(bg.name, style: const TextStyle(fontSize: 11)),
                      selected: aiProvider.selectedBackground == bg.name,
                      onSelected: (selected) {
                        if (selected) {
                          aiProvider.selectBackground(bg.name);
                        }
                      },
                      selectedColor: Colors.blue.withOpacity(0.3),
                      labelStyle: TextStyle(
                        color: aiProvider.selectedBackground == bg.name ? Colors.white : Colors.grey,
                        fontSize: 11,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            if (aiProvider.detectedShape.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detection:',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            aiProvider.detectedShape,
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: aiProvider.detectionConfidence > 0.7 ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${(aiProvider.detectionConfidence * 100).toInt()}%',
                            style: const TextStyle(color: Colors.white, fontSize: 9),
                          ),
                        ),
                      ],
                    ),
                    if (aiProvider.classifiedObject.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        aiProvider.classifiedObject,
                        style: const TextStyle(color: Colors.blue, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ========== BOTTOM TOOLBAR ==========
  Widget _buildBottomToolbar(BuildContext context, DrawingProvider drawingProvider, AIProvider aiProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _colorPalette.length,
              itemBuilder: (context, index) {
                final color = _colorPalette[index];
                return GestureDetector(
                  onTap: () {
                    drawingProvider.updateColor(color);
                    setState(() => _selectedColor = color);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    child: _ColorButton(
                      color: color,
                      isSelected: drawingProvider.currentColor == color,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    const Text(
                      'Size:',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Slider(
                        value: _brushSize,
                        min: 1,
                        max: 30,
                        onChanged: (value) {
                          setState(() => _brushSize = value);
                          drawingProvider.updateStrokeWidth(value);
                        },
                        activeColor: _selectedColor,
                        divisions: 29,
                        label: _brushSize.round().toString(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _saveDrawing(context, drawingProvider),
                    icon: const Icon(Icons.save, color: Colors.white, size: 20),
                    tooltip: 'Save Drawing',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                  IconButton(
                    onPressed: () {
                      if (drawingProvider.strokes.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No drawing to correct!'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      final lastStroke = drawingProvider.getLastStroke();
                      if (lastStroke != null) {
                        final strokeIndex = drawingProvider.getLastStrokeIndex();
                        final correctedPoints = aiProvider.applyManualCorrection(lastStroke);
                        drawingProvider.applyAutoCorrection(correctedPoints, strokeIndex);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Auto-corrected to ${aiProvider.detectedShape.isNotEmpty ? aiProvider.detectedShape : "smooth shape"}'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.auto_awesome, color: Colors.yellow, size: 20),
                    tooltip: 'Auto-Correct Last Shape',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (_selectedTool == 'eraser') {
                          _selectedTool = 'brush';
                          drawingProvider.selectTool('brush');
                        } else {
                          _selectedTool = 'eraser';
                          drawingProvider.selectTool('eraser');
                        }
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_selectedTool == 'eraser' ? 'Eraser mode active' : 'Brush mode active'),
                          duration: const Duration(milliseconds: 500),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: Icon(
                      _selectedTool == 'eraser' ? Icons.brush : Icons.cleaning_services,
                      color: _selectedTool == 'eraser' ? Colors.orange : Colors.white,
                      size: 20,
                    ),
                    tooltip: _selectedTool == 'eraser' ? 'Switch to Brush' : 'Switch to Eraser',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                  IconButton(
                    onPressed: () {
                      _showClearConfirmationDialog(context, drawingProvider);
                    },
                    icon: const Icon(Icons.delete_forever, color: Colors.white, size: 20),
                    tooltip: 'Clear All',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== COLOR PALETTE ==========
  final List<Color> _colorPalette = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.brown,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.cyan,
    Colors.amber,
    Colors.lime,
    Colors.white,
  ];

  // ========== AI DETECTION CARD ==========
  Widget _buildAIDetectionCard(AIProvider aiProvider, Size screenSize) {
    return Container(
      width: screenSize.width * 0.8,
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              const Text(
                'AI Detection',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: aiProvider.detectionConfidence > 0.7 ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${(aiProvider.detectionConfidence * 100).toInt()}%',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _showAIOverlay = false),
                icon: const Icon(Icons.close, color: Colors.white, size: 14),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(2),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (aiProvider.detectedShape.isNotEmpty) ...[
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Shape: ', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text(
                  aiProvider.detectedShape.toUpperCase(),
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
            if (aiProvider.classifiedObject.isNotEmpty) ...[
              const SizedBox(height: 2),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('Object: ', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(
                    aiProvider.classifiedObject,
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'Tip: ${_getShapeTips(aiProvider.detectedShape)}',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ] else ...[
            const Text(
              'Draw something to see AI analysis',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  // ========== ASSET REPLACEMENT CARD ==========
  Widget _buildAssetReplacementCard(BuildContext context, AIProvider aiProvider, DrawingProvider drawingProvider) {
    final suggestions = aiProvider.getSuggestionsForShape(aiProvider.detectedShape);
    if (suggestions.isEmpty) return const SizedBox.shrink();
    final displaySuggestions = suggestions.take(3).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
              const SizedBox(width: 8),
              Text(
                'Replace with ${aiProvider.detectedShape.toUpperCase()} objects:',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  aiProvider.clearDetections();
                  setState(() {});
                },
                child: const Text('Dismiss', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: displaySuggestions.map((suggestion) {
              return _buildSuggestionChip(suggestion, aiProvider, drawingProvider);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(AssetSuggestion suggestion, AIProvider aiProvider, DrawingProvider drawingProvider) {
    return GestureDetector(
      onTap: () {
        _replaceWith3DObject(context, suggestion, aiProvider, drawingProvider);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(suggestion.icon, color: Colors.blue, size: 16),
            const SizedBox(width: 6),
            Text(
              suggestion.objectName,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _replaceWith3DObject(BuildContext context, AssetSuggestion suggestion, AIProvider aiProvider, DrawingProvider drawingProvider) {
    if (aiProvider.detectedShapes.isNotEmpty) {
      final lastShape = aiProvider.detectedShapes.last;
      final center = lastShape.bounds.center;
      final size = max(lastShape.bounds.width, lastShape.bounds.height);

      PNGLoader.loadImage(suggestion.assetPath).then((image) {
        final threeDObject = ThreeDObject(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: suggestion.objectName,
          assetPath: suggestion.assetPath,
          icon: suggestion.icon,
          position: center,
          size: size.clamp(50.0, 200.0),
          scale: 1.0,
          rotation: 0.0,
          cachedImage: image,
        );

        drawingProvider.addThreeDObject(threeDObject);
        aiProvider.clearDetections();
        setState(() {
          _repaintKey++;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${suggestion.objectName} placed on canvas!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }).catchError((error) {
        print('Error loading image: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load ${suggestion.objectName}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      });
    }
  }

  // ========== BACKGROUND METHODS ==========
  Widget _buildBackground(AIProvider aiProvider) {
    if (aiProvider.selectedBackground == 'none') {
      return Container(color: Colors.white);
    }

    try {
      final background = aiProvider.backgrounds.firstWhere(
            (bg) => bg.name == aiProvider.selectedBackground,
      );

      if (background.path.isNotEmpty) {
        final assetExists = _assetCache[background.path] ?? false;

        if (assetExists) {
          return Image.asset(
            background.path,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorBackground(background.path);
            },
          );
        } else {
          return _buildErrorBackground(background.path);
        }
      }
      return Container(color: Colors.white);
    } catch (e) {
      return Container(color: Colors.white);
    }
  }

  Widget _buildErrorBackground(String path) {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 40, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              'Background image not found',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              path.split('/').last,
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  // ========== DIALOGS ==========
  void _showAutoCorrectionDialog(BuildContext context, DrawingProvider drawingProvider, AIProvider aiProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto-Correction Suggestion', style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.black.withOpacity(0.9),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                children: [
                  const Text('AI detected a ', style: TextStyle(color: Colors.white70)),
                  Text(aiProvider.detectedShape, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  const Text(' shape', style: TextStyle(color: Colors.white70)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: aiProvider.detectionConfidence,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(
                  aiProvider.detectionConfidence > 0.8 ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              Text('Confidence: ${(aiProvider.detectionConfidence * 100).toInt()}%', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 16),
              const Text('Would you like to auto-correct it?', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _applyAutoCorrection(context, drawingProvider, aiProvider);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Yes, Correct it'),
          ),
        ],
      ),
    );
  }

  void _applyAutoCorrection(BuildContext context, DrawingProvider drawingProvider, AIProvider aiProvider) {
    final lastStroke = drawingProvider.getLastStroke();
    if (lastStroke != null && lastStroke.length >= 2) {
      final strokeIndex = drawingProvider.getLastStrokeIndex();
      final correctedPoints = aiProvider.applyManualCorrection(lastStroke);
      if (correctedPoints.length >= 2) {
        drawingProvider.applyAutoCorrection(correctedPoints, strokeIndex);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Auto-corrected to ${aiProvider.detectedShape} (${(aiProvider.detectionConfidence * 100).toInt()}% confidence)'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        aiProvider.clearDetections();
      }
    }
  }


  void _showShapeSelectionDialog(BuildContext context, DrawingProvider drawingProvider) {
    final List<Map<String, dynamic>> shapeCategories = [
      {
        'category': 'Basic Shapes',
        'shapes': [
          {'name': 'Rectangle', 'icon': Icons.crop_square, 'type': 'rectangle'},
          {'name': 'Square', 'icon': Icons.crop_square, 'type': 'square'},
          {'name': 'Circle', 'icon': Icons.circle_outlined, 'type': 'circle'},
          {'name': 'Triangle', 'icon': Icons.change_history, 'type': 'triangle'},
          {'name': 'Line', 'icon': Icons.horizontal_rule, 'type': 'line'},
          {'name': 'Oval', 'icon': Icons.panorama_fish_eye, 'type': 'oval'},
        ]
      },
      {
        'category': 'Polygons',
        'shapes': [
          {'name': 'Pentagon', 'icon': Icons.pentagon, 'type': 'pentagon'},
          {'name': 'Hexagon', 'icon': Icons.hexagon, 'type': 'hexagon'},
          {'name': 'Octagon', 'icon': Icons.polyline, 'type': 'octagon'},
        ]
      },
      {
        'category': 'Special',
        'shapes': [
          {'name': 'Star', 'icon': Icons.star_outline, 'type': 'star'},
          {'name': 'Arrow', 'icon': Icons.arrow_forward, 'type': 'arrow'},
        ]
      },
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Shape', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.black.withOpacity(0.9),
        content: Container(
          width: min(350, MediaQuery.of(context).size.width * 0.8),
          height: 350,
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Container(
                  color: Colors.grey[900],
                  child: const TabBar(
                    tabs: [
                      Tab(text: 'Basic'),
                      Tab(text: 'Polygons'),
                      Tab(text: 'Special'),
                    ],
                    indicatorColor: Colors.blue,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: shapeCategories.map((cat) => _buildShapeGrid(cat['shapes'], drawingProvider, context)).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }

  Widget _buildShapeGrid(List shapes, DrawingProvider drawingProvider, BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      padding: const EdgeInsets.all(8),
      itemCount: shapes.length,
      itemBuilder: (context, index) {
        final shape = shapes[index];
        return GestureDetector(
          onTap: () {
            drawingProvider.selectShape(shape['type']);
            Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(shape['icon'], color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(shape['name'], style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTextInputDialog(BuildContext context, DrawingProvider drawingProvider) {
    final textController = TextEditingController();
    final screenSize = MediaQuery.of(context).size;
    final position = Offset(screenSize.width / 2 - 100, screenSize.height / 2 - 50);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Text', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.black.withOpacity(0.9),
        content: TextField(
          controller: textController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter your text',
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                drawingProvider.addText(textController.text.trim(), position);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmationDialog(BuildContext context, DrawingProvider drawingProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Canvas', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.black.withOpacity(0.9),
        content: const Text('Are you sure you want to clear the entire canvas?', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            onPressed: () {
              drawingProvider.clear();
              setState(() {});
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showAssetStatusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Asset Status', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.black.withOpacity(0.95),
        content: Container(
          width: min(400, MediaQuery.of(context).size.width * 0.8),
          height: 400,
          child: _buildAssetStatusList(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE')),
        ],
      ),
    );
  }
  // ========== TRANSFORM TOOLBAR (for selected objects) ==========
  Widget _buildTransformToolbar(DrawingProvider drawingProvider) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  drawingProvider.selected3DElement != null
                      ? Icons.view_in_ar
                      : Icons.image,
                  color: Colors.blue,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  drawingProvider.selected3DElement != null
                      ? drawingProvider.selected3DElement!.name
                      : 'Image',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    drawingProvider.clearSelection();
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.close, color: Colors.red, size: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Rotation controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SmallIconButton(
                icon: Icons.rotate_left,
                tooltip: 'Rotate Left 45°',
                onTap: () {
                  final rad = -45 * 3.14159 / 180;
                  if (drawingProvider.selected3DElement != null) {
                    drawingProvider.update3DObjectTransform(
                      drawingProvider.selected3DElement!.id,
                      rotation: drawingProvider.selected3DElement!.rotation + rad,
                    );
                  } else if (drawingProvider.selectedUploadedImage != null) {
                    drawingProvider.updateUploadedImageTransform(
                      drawingProvider.selectedUploadedImage!.id,
                      rotation: drawingProvider.selectedUploadedImage!.rotation + rad,
                    );
                  }
                  setState(() {});
                },
              ),
              _SmallIconButton(
                icon: Icons.rotate_right,
                tooltip: 'Rotate Right 45°',
                onTap: () {
                  final rad = 45 * 3.14159 / 180;
                  if (drawingProvider.selected3DElement != null) {
                    drawingProvider.update3DObjectTransform(
                      drawingProvider.selected3DElement!.id,
                      rotation: drawingProvider.selected3DElement!.rotation + rad,
                    );
                  } else if (drawingProvider.selectedUploadedImage != null) {
                    drawingProvider.updateUploadedImageTransform(
                      drawingProvider.selectedUploadedImage!.id,
                      rotation: drawingProvider.selectedUploadedImage!.rotation + rad,
                    );
                  }
                  setState(() {});
                },
              ),
              _SmallIconButton(
                icon: Icons.tune,
                tooltip: 'Precision Rotate',
                onTap: () => _showRotationDialog(drawingProvider),
                color: Colors.amber,
              ),
              const SizedBox(width: 4),
              // Vertical divider
              Container(
                width: 1,
                height: 28,
                color: Colors.white.withOpacity(0.2),
              ),
              const SizedBox(width: 4),
              _SmallIconButton(
                icon: Icons.zoom_in,
                tooltip: 'Scale Up',
                onTap: () {
                  if (drawingProvider.selected3DElement != null) {
                    drawingProvider.update3DObjectTransform(
                      drawingProvider.selected3DElement!.id,
                      scale: (drawingProvider.selected3DElement!.scale * 1.2).clamp(0.3, 3.0),
                    );
                  } else if (drawingProvider.selectedUploadedImage != null) {
                    drawingProvider.updateUploadedImageTransform(
                      drawingProvider.selectedUploadedImage!.id,
                      scale: (drawingProvider.selectedUploadedImage!.scale * 1.2).clamp(0.1, 5.0),
                    );
                  }
                  setState(() {});
                },
              ),
              _SmallIconButton(
                icon: Icons.zoom_out,
                tooltip: 'Scale Down',
                onTap: () {
                  if (drawingProvider.selected3DElement != null) {
                    drawingProvider.update3DObjectTransform(
                      drawingProvider.selected3DElement!.id,
                      scale: (drawingProvider.selected3DElement!.scale * 0.8).clamp(0.3, 3.0),
                    );
                  } else if (drawingProvider.selectedUploadedImage != null) {
                    drawingProvider.updateUploadedImageTransform(
                      drawingProvider.selectedUploadedImage!.id,
                      scale: (drawingProvider.selectedUploadedImage!.scale * 0.8).clamp(0.1, 5.0),
                    );
                  }
                  setState(() {});
                },
              ),
              _SmallIconButton(
                icon: Icons.flip,
                tooltip: 'Flip Horizontal',
                onTap: () {
                  if (drawingProvider.selected3DElement != null) {
                    drawingProvider.update3DObjectTransform(
                      drawingProvider.selected3DElement!.id,
                      scale: -drawingProvider.selected3DElement!.scale,
                    );
                  } else if (drawingProvider.selectedUploadedImage != null) {
                    drawingProvider.updateUploadedImageTransform(
                      drawingProvider.selectedUploadedImage!.id,
                      scale: -drawingProvider.selectedUploadedImage!.scale,
                    );
                  }
                  setState(() {});
                },
                color: Colors.purple,
              ),
              _SmallIconButton(
                icon: Icons.delete,
                tooltip: 'Delete',
                onTap: () {
                  if (drawingProvider.selected3DElement != null) {
                    drawingProvider.delete3DObject(drawingProvider.selected3DElement!.id);
                  } else if (drawingProvider.selectedUploadedImage != null) {
                    drawingProvider.deleteUploadedImage(drawingProvider.selectedUploadedImage!.id);
                  }
                  drawingProvider.clearSelection();
                  setState(() {});
                },
                color: Colors.red,
              ),
            ],
          ),

          // Rotation slider
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.rotate_right, color: Colors.white54, size: 12),
              const SizedBox(width: 4),
              SizedBox(
                width: 140,
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                    activeTrackColor: Colors.blue,
                    inactiveTrackColor: Colors.grey[700],
                    thumbColor: Colors.blue,
                  ),
                  child: Slider(
                    value: _getSelectedRotation(drawingProvider),
                    min: 0,
                    max: 360,
                    divisions: 36,
                    onChanged: (v) {
                      final rad = v * 3.14159 / 180;
                      if (drawingProvider.selected3DElement != null) {
                        drawingProvider.update3DObjectTransform(
                          drawingProvider.selected3DElement!.id,
                          rotation: rad,
                        );
                      } else if (drawingProvider.selectedUploadedImage != null) {
                        drawingProvider.updateUploadedImageTransform(
                          drawingProvider.selectedUploadedImage!.id,
                          rotation: rad,
                        );
                      }
                      setState(() {});
                    },
                  ),
                ),
              ),
              Text(
                '${_getSelectedRotation(drawingProvider).toInt()}°',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _getSelectedRotation(DrawingProvider dp) {
    if (dp.selected3DElement != null) {
      double deg = dp.selected3DElement!.rotation * 180 / 3.14159;
      return (deg % 360 + 360) % 360;
    }
    if (dp.selectedUploadedImage != null) {
      double deg = dp.selectedUploadedImage!.rotation * 180 / 3.14159;
      return (deg % 360 + 360) % 360;
    }
    return 0;
  }

  Widget _buildAssetStatusList() {
    final found = _assetCache.values.where((v) => v).length;
    final missing = _assetCache.values.where((v) => !v).length;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatCard('TOTAL', _assetCache.length.toString(), Colors.blue),
            _buildStatCard('FOUND', found.toString(), Colors.green),
            _buildStatCard('MISSING', missing.toString(), Colors.red),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _assetCache.length,
            itemBuilder: (context, index) {
              final entry = _assetCache.entries.elementAt(index);
              final fileName = entry.key.split('/').last;
              return ListTile(
                leading: Icon(entry.value ? Icons.check_circle : Icons.error, color: entry.value ? Colors.green : Colors.red),
                title: Text(fileName, style: TextStyle(color: entry.value ? Colors.green : Colors.red, fontSize: 12)),
                dense: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 10)),
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getShapeTips(String shape) {
    switch (shape.toLowerCase()) {
      case 'circle': return 'Try adding details to make it a clock or sun';
      case 'triangle': return 'Perfect for mountains or pyramids';
      case 'square': case 'rectangle': return 'Great for buildings or windows';
      case 'line': return 'Use for horizons or arrows';
      default: return 'Keep drawing to see AI suggestions';
    }
  }
  // ========== ROTATION DIALOG ==========
  void _showRotationDialog(DrawingProvider dp) {
    if (dp.selected3DElement == null && dp.selectedUploadedImage == null) return;

    double currentRotation = dp.selected3DElement != null
        ? (dp.selected3DElement!.rotation * 180 / 3.14159) % 360
        : (dp.selectedUploadedImage!.rotation * 180 / 3.14159) % 360;

    if (currentRotation < 0) currentRotation += 360;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.black.withOpacity(0.92),
            title: const Text('Rotate Object', style: TextStyle(color: Colors.white, fontSize: 16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${currentRotation.toInt()}°',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Slider(
                  value: currentRotation,
                  min: 0, max: 360, divisions: 72,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.grey[700],
                  onChanged: (v) => setDialogState(() => currentRotation = v),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [0, 45, 90, 135, 180, 225, 270, 315].map((angle) {
                    return GestureDetector(
                      onTap: () => setDialogState(() => currentRotation = angle.toDouble()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: currentRotation.toInt() == angle
                              ? Colors.blue.withOpacity(0.4)
                              : Colors.blue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: currentRotation.toInt() == angle
                                ? Colors.blue
                                : Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '$angle°',
                          style: TextStyle(
                            color: currentRotation.toInt() == angle ? Colors.white : Colors.blue,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final radians = currentRotation * 3.14159 / 180;
                  if (dp.selected3DElement != null) {
                    dp.update3DObjectTransform(dp.selected3DElement!.id, rotation: radians);
                  } else if (dp.selectedUploadedImage != null) {
                    dp.updateUploadedImageTransform(dp.selectedUploadedImage!.id, rotation: radians);
                  }
                  Navigator.pop(ctx);
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }
  Future<void> _uploadImageFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        final image = frame.image;
        final screenSize = MediaQuery.of(context).size;
        final centerPosition = Offset(screenSize.width / 2, screenSize.height / 2);

        final canvasImage = CanvasImageElement(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          image: image,
          position: centerPosition,
          scale: 0.3,
          rotation: 0.0,
          bounds: Rect.fromCenter(
            center: centerPosition,
            width: image.width.toDouble() * 0.3,
            height: image.height.toDouble() * 0.3,
          ),
        );

        context.read<DrawingProvider>().addUploadedImageFromFile(canvasImage);
        setState(() {});
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _saveDrawing(BuildContext context, DrawingProvider drawingProvider) async {
    final hasContent = drawingProvider.strokes.isNotEmpty ||
        drawingProvider.currentStroke.isNotEmpty ||
        drawingProvider.texts.isNotEmpty ||
        drawingProvider.elements.isNotEmpty ||
        drawingProvider.threeDObjects.isNotEmpty;

    if (!hasContent) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nothing to save!')));
      return;
    }

    try {
      final bytes = await _screenshotController.capture();
      if (bytes != null) {
        await ImageGallerySaverPlus.saveImage(bytes, name: 'drawing_${DateTime.now().millisecondsSinceEpoch}');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to gallery!')));
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}

// ========== CUSTOM PAINTER ==========
class _AICanvasPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final List<Color> strokeColors;
  final List<double> strokeWidths;
  final List<DrawingElement> elements;
  final List<ThreeDObject> threeDObjects;
  final List<CanvasImageElement> uploadedImages;
  final bool showAIOverlay;
  final AIProvider aiProvider;
  final Color selectedColor;
  final double brushSize;
  final List<Offset> shapePreviewPoints;
  final String selectedShape;
  final bool isDrawingShape;
  final List<TextData> texts;
  final DrawingElement? selectedElement;
  final ThreeDObject? selected3DElement;
  final CanvasImageElement? selectedUploadedImage;
  final bool isErasing;

  _AICanvasPainter({
    required this.strokes,
    required this.currentStroke,
    required this.strokeColors,
    required this.strokeWidths,
    required this.elements,
    required this.threeDObjects,
    required this.uploadedImages,
    required this.showAIOverlay,
    required this.aiProvider,
    required this.selectedColor,
    required this.brushSize,
    required this.shapePreviewPoints,
    required this.selectedShape,
    required this.isDrawingShape,
    required this.texts,
    this.selectedElement,
    this.selected3DElement,
    this.selectedUploadedImage,
    required this.isErasing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw strokes
    for (int i = 0; i < strokes.length; i++) {
      final stroke = strokes[i];
      if (stroke.length < 2) continue;
      final paint = Paint()
        ..color = i < strokeColors.length ? strokeColors[i] : Colors.black
        ..strokeWidth = i < strokeWidths.length ? strokeWidths[i] : 5.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (int j = 1; j < stroke.length; j++) path.lineTo(stroke[j].dx, stroke[j].dy);
      canvas.drawPath(path, paint);
    }

    // Draw shapes
    for (final element in elements) {
      if (element.points == null || element.points!.length < 2) continue;
      final paint = Paint()
        ..color = element.color
        ..strokeWidth = element.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      final path = Path()..moveTo(element.points!.first.dx, element.points!.first.dy);
      for (int j = 1; j < element.points!.length; j++) path.lineTo(element.points![j].dx, element.points![j].dy);
      canvas.drawPath(path, paint);
    }

    // Draw uploaded images with rotation support
    for (final img in uploadedImages) {
      canvas.save();

      // Move to image position
      canvas.translate(img.position.dx, img.position.dy);

      // Apply rotation
      canvas.rotate(img.rotation);

      // Calculate rect centered at origin
      final imgWidth = img.bounds.width * img.scale.abs();
      final imgHeight = img.bounds.height * img.scale.abs();
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: imgWidth,
        height: imgHeight,
      );

      // Draw the image
      canvas.drawImageRect(
        img.image,
        Rect.fromLTWH(0, 0, img.image.width.toDouble(), img.image.height.toDouble()),
        rect,
        Paint(),
      );

      // Draw selection highlight if selected
      if (selectedUploadedImage != null && selectedUploadedImage!.isSelected && selectedUploadedImage!.id == img.id) {
        // Blue border
        canvas.drawRect(
          rect.inflate(6),
          Paint()
            ..color = Colors.blue.withOpacity(0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );
        // Rotation indicator line pointing up
        canvas.drawLine(
          Offset(0, rect.top),
          Offset(0, rect.top - 20),
          Paint()
            ..color = Colors.blue
            ..strokeWidth = 2.5,
        );
        // Rotation indicator dot
        canvas.drawCircle(
          Offset(0, rect.top - 22),
          5,
          Paint()..color = Colors.blue,
        );
      }

      canvas.restore();
    }

    // Draw 3D objects with rotation support
    for (final obj in threeDObjects) {
      canvas.save();

      // Move to object position
      canvas.translate(obj.position.dx, obj.position.dy);

      // Apply rotation
      canvas.rotate(obj.rotation);

      // Calculate rect centered at origin
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: obj.size * obj.scale.abs(),
        height: obj.size * obj.scale.abs(),
      );

      if (obj.cachedImage != null) {
        canvas.drawImageRect(
          obj.cachedImage!,
          Rect.fromLTWH(0, 0, obj.cachedImage!.width.toDouble(), obj.cachedImage!.height.toDouble()),
          rect,
          Paint(),
        );
      } else {
        canvas.drawRect(rect, Paint()..color = Colors.grey.withOpacity(0.5));
        canvas.drawRect(rect, Paint()..color = Colors.grey..style = PaintingStyle.stroke..strokeWidth = 2);
      }

      // Draw selection highlight if selected
      if (selected3DElement != null && selected3DElement!.id == obj.id) {
        // Blue border
        canvas.drawRect(
          rect.inflate(6),
          Paint()
            ..color = Colors.blue.withOpacity(0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );
        // Rotation indicator line pointing up
        canvas.drawLine(
          Offset(0, rect.top),
          Offset(0, rect.top - 20),
          Paint()
            ..color = Colors.blue
            ..strokeWidth = 2.5,
        );
        // Rotation indicator dot
        canvas.drawCircle(
          Offset(0, rect.top - 22),
          5,
          Paint()..color = Colors.blue,
        );
      }

      canvas.restore();
    }

    // Draw current stroke
    if (currentStroke.length > 1) {
      final paint = Paint()
        ..color = isErasing ? Colors.grey.withOpacity(0.5) : selectedColor
        ..strokeWidth = brushSize
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      final path = Path()..moveTo(currentStroke.first.dx, currentStroke.first.dy);
      for (int i = 1; i < currentStroke.length; i++) path.lineTo(currentStroke[i].dx, currentStroke[i].dy);
      canvas.drawPath(path, paint);
    }

    // Draw shape preview
    if (isDrawingShape && shapePreviewPoints.length >= 2) {
      final start = shapePreviewPoints[0];
      final end = shapePreviewPoints[1];
      final paint = Paint()
        ..color = selectedColor.withOpacity(0.5)
        ..strokeWidth = brushSize
        ..style = PaintingStyle.stroke;
      final path = Path();
      if (selectedShape == 'rectangle' || selectedShape == 'square') {
        path.moveTo(start.dx, start.dy);
        path.lineTo(end.dx, start.dy);
        path.lineTo(end.dx, end.dy);
        path.lineTo(start.dx, end.dy);
        path.close();
      } else if (selectedShape == 'circle') {
        final center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
        final radius = max((end.dx - start.dx).abs(), (end.dy - start.dy).abs()) / 2;
        path.addOval(Rect.fromCircle(center: center, radius: radius));
      } else if (selectedShape == 'triangle') {
        final centerX = (start.dx + end.dx) / 2;
        path.moveTo(centerX, start.dy);
        path.lineTo(end.dx, end.dy);
        path.lineTo(start.dx, end.dy);
        path.close();
      }
      canvas.drawPath(path, paint);
    }

    // Draw texts
    for (final text in texts) {
      final tp = TextPainter(
        text: TextSpan(text: text.text, style: TextStyle(color: text.color, fontSize: text.fontSize)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, text.position);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ========== HELPER WIDGETS ==========
class _ImagePainter extends CustomPainter {
  final ui.Image image;
  _ImagePainter(this.image);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  const _ToolButton({required this.icon, required this.label, this.isSelected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
              ),
              child: Icon(icon, color: isSelected ? Colors.blue : Colors.white, size: 20),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: isSelected ? Colors.blue : Colors.white70, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final bool isSelected;
  const _ColorButton({required this.color, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 2),
        boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)] : null,
      ),
    );
  }
}
class _QuickAngleButton extends StatelessWidget {
  final String label;
  final double angle;
  final Function(double) onTap;

  const _QuickAngleButton({
    required this.label,
    required this.angle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(angle),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.blue.withOpacity(0.5)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
class _SmallIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;

  const _SmallIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? Colors.blue;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: buttonColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: buttonColor.withOpacity(0.4)),
          ),
          child: Icon(icon, color: buttonColor, size: 16),
        ),
      ),
    );
  }
}