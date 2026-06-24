import 'dart:math';
import 'package:flutter/material.dart';

/// Shape data detected by AI
class ShapeData {
  final String shape;
  final String object;
  final double confidence;
  final Rect bounds;
  final List<Offset> points;
  final DateTime timestamp;
  final String suggestedAssetPath;
  final IconData suggestedIcon;

  ShapeData({
    required this.shape,
    required this.object,
    required this.confidence,
    required this.bounds,
    required this.points,
    required this.timestamp,
    required this.suggestedAssetPath,
    required this.suggestedIcon,
  });
}

/// Asset suggestion for shape replacement
class AssetSuggestion {
  final String shape;
  final String objectName;
  final String assetPath;
  final IconData icon;
  final double minConfidence;
  final double maxAspectRatio;
  final double minAspectRatio;
  final double minSize;
  final double maxSize;

  const AssetSuggestion({
    required this.shape,
    required this.objectName,
    required this.assetPath,
    required this.icon,
    this.minConfidence = 0.6,
    this.maxAspectRatio = 1.5,
    this.minAspectRatio = 0.5,
    this.minSize = 30.0,
    this.maxSize = 300.0,
  });
}

/// Background type enum
enum BackgroundType {
  none,
  indoor,
  outdoor,
}

/// Background data class
class Background {
  final String name;
  final String path;
  final BackgroundType type;
  bool get exists => path.isNotEmpty;

  const Background({
    required this.name,
    required this.path,
    required this.type,
  });
}

/// AI Provider for drawing assistance and shape detection
class AIProvider extends ChangeNotifier {
  // ========== AI SETTINGS ==========
  bool _autoCorrectionEnabled = true;
  bool _showDetectionBoxes = true;
  bool _autoReplaceEnabled = false;
  double _correctionStrength = 0.95;
  String _detectedShape = '';
  String _classifiedObject = '';
  double _detectionConfidence = 0.0;
  String _selectedBackground = 'none';
  AssetSuggestion? _currentSuggestion;

  // ========== DETECTION STATE ==========
  final List<ShapeData> _detectedShapes = [];
  List<Offset> _currentPoints = [];

  // ========== ASSET SUGGESTIONS DATABASE ==========
  static const List<AssetSuggestion> _assetSuggestions = [
    // Circle-based objects
    AssetSuggestion(shape: 'circle', objectName: 'Clock', assetPath: 'assets/3d/clock.png', icon: Icons.access_time, minConfidence: 0.65, minSize: 40, maxSize: 150),
    AssetSuggestion(shape: 'circle', objectName: 'Sun', assetPath: 'assets/3d/sun.png', icon: Icons.wb_sunny, minConfidence: 0.7, minSize: 50, maxSize: 200),
    AssetSuggestion(shape: 'circle', objectName: 'Ball', assetPath: 'assets/3d/sphere.png', icon: Icons.sports_soccer, minConfidence: 0.7, minSize: 60, maxSize: 250),
    AssetSuggestion(shape: 'circle', objectName: 'Flower', assetPath: 'assets/3d/flower.png', icon: Icons.local_florist, minConfidence: 0.65, minSize: 40, maxSize: 100),

    // Triangle-based objects
    AssetSuggestion(shape: 'triangle', objectName: 'Mountain', assetPath: 'assets/3d/mountain.png', icon: Icons.landscape, minConfidence: 0.65),
    AssetSuggestion(shape: 'triangle', objectName: 'Pyramid', assetPath: 'assets/3d/pyramid.png', icon: Icons.change_history, minConfidence: 0.7),
    AssetSuggestion(shape: 'triangle', objectName: 'Tree', assetPath: 'assets/3d/tree.png', icon: Icons.park, minConfidence: 0.65),
    AssetSuggestion(shape: 'triangle', objectName: 'Roof', assetPath: 'assets/3d/roof.png', icon: Icons.roofing, minConfidence: 0.7),
    AssetSuggestion(shape: 'triangle', objectName: 'Tent', assetPath: 'assets/3d/tent.png', icon: Icons.celebration, minConfidence: 0.65),

    // Square-based objects
    AssetSuggestion(shape: 'square', objectName: 'Window', assetPath: 'assets/3d/window.png', icon: Icons.crop_original, minConfidence: 0.65),
    AssetSuggestion(shape: 'square', objectName: 'Picture Frame', assetPath: 'assets/3d/frame.png', icon: Icons.photo, minConfidence: 0.7),
    AssetSuggestion(shape: 'square', objectName: 'Sofa', assetPath: 'assets/3d/sofa.png', icon: Icons.weekend, minConfidence: 0.65),
    AssetSuggestion(shape: 'square', objectName: 'Table', assetPath: 'assets/3d/table.png', icon: Icons.table_restaurant, minConfidence: 0.65),
    AssetSuggestion(shape: 'square', objectName: 'Chair', assetPath: 'assets/3d/chair.png', icon: Icons.chair, minConfidence: 0.65),

    // Rectangle-based objects
    AssetSuggestion(shape: 'rectangle', objectName: 'Door', assetPath: 'assets/3d/door.png', icon: Icons.door_front_door, minConfidence: 0.65, minAspectRatio: 1.8, maxAspectRatio: 3.5),
    AssetSuggestion(shape: 'rectangle', objectName: 'Bed', assetPath: 'assets/3d/bed.png', icon: Icons.bed, minConfidence: 0.6, minSize: 100),
    AssetSuggestion(shape: 'rectangle', objectName: 'Bookshelf', assetPath: 'assets/3d/bookshelf.png', icon: Icons.menu_book, minConfidence: 0.7, minAspectRatio: 2.0),
    AssetSuggestion(shape: 'rectangle', objectName: 'Bench', assetPath: 'assets/3d/bench.png', icon: Icons.weekend, minConfidence: 0.65),
    AssetSuggestion(shape: 'rectangle', objectName: 'TV', assetPath: 'assets/3d/tv.png', icon: Icons.tv, minConfidence: 0.7, minAspectRatio: 1.5, maxAspectRatio: 2.5),
    AssetSuggestion(shape: 'rectangle', objectName: 'Laptop', assetPath: 'assets/3d/laptop.png', icon: Icons.laptop, minConfidence: 0.7, minSize: 40, maxSize: 120),
    AssetSuggestion(shape: 'rectangle', objectName: 'Car', assetPath: 'assets/3d/car.png', icon: Icons.directions_car, minConfidence: 0.65),

    // Oval-based objects
    AssetSuggestion(shape: 'oval', objectName: 'Egg', assetPath: 'assets/3d/egg.png', icon: Icons.lens, minConfidence: 0.7),

    // Star-based objects
    AssetSuggestion(shape: 'star', objectName: 'Star', assetPath: 'assets/3d/star.png', icon: Icons.star, minConfidence: 0.65),

    // Line-based objects
    AssetSuggestion(shape: 'line', objectName: 'Pencil', assetPath: 'assets/3d/pencil.png', icon: Icons.edit, minConfidence: 0.7),
    AssetSuggestion(shape: 'line', objectName: 'Ruler', assetPath: 'assets/3d/ruler.png', icon: Icons.straighten, minConfidence: 0.7),
  ];

  // ========== BACKGROUND DATA ==========
  static const List<Background> _backgrounds = [
    Background(name: 'None', path: '', type: BackgroundType.none),
    Background(name: 'Living Room', path: 'assets/background/living_room.jpg', type: BackgroundType.indoor),
    Background(name: 'Tv Lounge', path: 'assets/background/tv_lounge.jpg', type: BackgroundType.indoor),
    Background(name: 'Kitchen', path: 'assets/background/kitchen.jpg', type: BackgroundType.indoor),
    Background(name: 'Garden', path: 'assets/background/garden.jpg', type: BackgroundType.outdoor),
  ];

  // ========== GETTERS ==========
  bool get autoCorrectionEnabled => _autoCorrectionEnabled;
  bool get showDetectionBoxes => _showDetectionBoxes;
  bool get autoReplaceEnabled => _autoReplaceEnabled;
  double get correctionStrength => _correctionStrength;
  String get detectedShape => _detectedShape;
  String get classifiedObject => _classifiedObject;
  double get detectionConfidence => _detectionConfidence;
  String get selectedBackground => _selectedBackground;
  AssetSuggestion? get currentSuggestion => _currentSuggestion;
  List<ShapeData> get detectedShapes => _detectedShapes;
  List<Background> get backgrounds => _backgrounds;
  List<AssetSuggestion> get assetSuggestions => _assetSuggestions;

  // ========== AI CONTROL METHODS ==========
  void toggleAutoCorrection() {
    _autoCorrectionEnabled = !_autoCorrectionEnabled;
    notifyListeners();
  }

  void toggleAutoReplace() {
    _autoReplaceEnabled = !_autoReplaceEnabled;
    notifyListeners();
  }

  void updateCorrectionStrength(double strength) {
    _correctionStrength = strength.clamp(0.1, 1.0);
    notifyListeners();
  }

  void toggleDetectionBoxes() {
    _showDetectionBoxes = !_showDetectionBoxes;
    notifyListeners();
  }
// Add this method to AIProvider class (around line 680-700)

  Offset _calculateCenter(List<Offset> points) {
    double sumX = 0.0, sumY = 0.0;
    for (var p in points) {
      sumX += p.dx;
      sumY += p.dy;
    }
    return Offset(sumX / points.length, sumY / points.length);
  }
  // ========== MAIN SHAPE DETECTION ==========
  String analyzePoints(List<Offset> points) {
    if (points.length < 6) return '';

    _currentPoints = List.from(points);
    final smoothedPoints = _advancedSmoothPoints(points);
    final detection = _enhancedShapeDetection(smoothedPoints);

    _detectedShape = detection['shape'];
    _detectionConfidence = detection['confidence'];

    if (_detectionConfidence > 0.55) {
      _classifiedObject = _smartObjectClassification(_detectedShape, smoothedPoints);
      _currentSuggestion = _getBestAssetSuggestion(_detectedShape, smoothedPoints, _detectionConfidence);
    } else {
      _classifiedObject = '';
      _currentSuggestion = null;
    }

    if (_detectedShape.isNotEmpty && _detectionConfidence > 0.55) {
      _detectedShapes.add(ShapeData(
        shape: _detectedShape,
        object: _classifiedObject,
        confidence: _detectionConfidence,
        bounds: _calculateBoundingBox(points),
        points: List.from(points),
        timestamp: DateTime.now(),
        suggestedAssetPath: _currentSuggestion?.assetPath ?? '',
        suggestedIcon: _currentSuggestion?.icon ?? Icons.category,
      ));

      while (_detectedShapes.length > 10) {
        _detectedShapes.removeAt(0);
      }
    }

    notifyListeners();
    return _detectedShape;
  }

  // ========== ENHANCED SHAPE DETECTION ==========
  // ========== ENHANCED SHAPE DETECTION (IMPROVED FOR RECTANGLES) ==========
  Map<String, dynamic> _enhancedShapeDetection(List<Offset> points) {
    if (points.length < 6) {
      return {'shape': 'unknown', 'confidence': 0.0};
    }

    final bounds = _calculateBoundingBox(points);
    final width = bounds.width;
    final height = bounds.height;

    if (width < 8 || height < 8) {
      return {'shape': 'unknown', 'confidence': 0.0};
    }

    final aspectRatio = width / height;
    final area = _calculateArea(points);
    final perimeter = _calculatePerimeter(points);
    final circularity = perimeter > 0 ? (4 * pi * area) / (perimeter * perimeter) : 0.0;
    final convexity = _calculateConvexity(points);
    final solidity = _calculateSolidity(points, area);

    // NEW: Bounding box fill ratio - how well the drawing fills its bounding box
    final boundingBoxArea = width * height;
    final fillRatio = boundingBoxArea > 0 ? area / boundingBoxArea : 0.0;

    // NEW: Corner proximity - checks if points are close to 4 corners of bounding box
    final cornerProximity = _calculateCornerProximity(points, bounds);

    // NEW: Edge coverage - checks how many edges of bounding box have points near them
    final edgeCoverage = _calculateEdgeCoverage(points, bounds);

    // Create scores map
    final Map<String, double> shapeScores = {};

    // 1. LINE DETECTION
    final isLine = _isEnhancedLine(points);
    if (isLine['isLine'] as bool) {
      final lineConfidence = isLine['confidence'] as double;
      if (lineConfidence > 0.7) {
        return {'shape': 'line', 'confidence': lineConfidence};
      }
      shapeScores['line'] = lineConfidence;
    }

    // 2. CIRCLE DETECTION
    if (circularity > 0.55 && aspectRatio > 0.7 && aspectRatio < 1.3) {
      final radialSymmetry = _calculateRadialSymmetry(points);
      final circleScore = (circularity * 0.5 + radialSymmetry * 0.5);
      shapeScores['circle'] = circleScore.clamp(0.4, 0.98);
    }

    // 3. OVAL DETECTION
    if (circularity > 0.45 && (aspectRatio > 1.3 || aspectRatio < 0.7)) {
      final ovalScore = circularity * 0.7;
      shapeScores['oval'] = ovalScore.clamp(0.4, 0.92);
    }

    // 4. SQUARE DETECTION (using bounding box analysis - more reliable for hand-drawn)
    if (aspectRatio > 0.75 && aspectRatio < 1.35 && fillRatio > 0.5) {
      double squareScore = 0.5;
      squareScore += fillRatio * 0.2; // Good fill = likely square
      squareScore += cornerProximity * 0.15; // Points near 4 corners
      squareScore += (1.0 - (aspectRatio - 1.0).abs()) * 0.1; // Close to 1:1 aspect
      squareScore += convexity * 0.05;
      shapeScores['square'] = squareScore.clamp(0.45, 0.95);
    }

    // 5. RECTANGLE DETECTION (using bounding box analysis)
    if (aspectRatio >= 1.2 && aspectRatio <= 4.0 && fillRatio > 0.45) {
      double rectangleScore = 0.5;
      rectangleScore += fillRatio * 0.15;
      rectangleScore += cornerProximity * 0.12;
      rectangleScore += edgeCoverage * 0.1;
      rectangleScore += convexity * 0.08;

      // Bonus for typical rectangle aspect ratios
      if (aspectRatio >= 1.4 && aspectRatio <= 3.0) rectangleScore += 0.05;

      shapeScores['rectangle'] = rectangleScore.clamp(0.45, 0.92);
    }

    // 6. TRIANGLE DETECTION (using corner proximity with 3 corners)
    final triangleCornerScore = _calculateTriangleCornerProximity(points, bounds);
    if (triangleCornerScore > 0.4 && fillRatio < 0.7) {
      double triangleScore = 0.45 + triangleCornerScore * 0.35;
      if (convexity > 0.8) triangleScore += 0.05;
      shapeScores['triangle'] = triangleScore.clamp(0.45, 0.92);
    }

    // 7. POLYGON DETECTION (fallback using corners)
    final corners = _findEnhancedCorners(points);
    final cornerCount = corners.length;
    if (cornerCount >= 3 && cornerCount <= 8) {
      final polygonScores = _detectEnhancedPolygon(points, corners, cornerCount, aspectRatio);
      for (final entry in polygonScores.entries) {
        // Only add if not already detected, or if confidence is higher
        if (!shapeScores.containsKey(entry.key) || shapeScores[entry.key]! < entry.value) {
          shapeScores[entry.key] = entry.value;
        }
      }
    }

    // 8. STAR DETECTION
    final starScore = _detectStar(points);
    if (starScore > 0.5) {
      shapeScores['star'] = starScore;
    }

    // Find best match
    String bestShape = 'unknown';
    double bestScore = 0.35;

    for (final entry in shapeScores.entries) {
      double weightedScore = entry.value;

      // Shape-specific bonuses
      switch (entry.key) {
        case 'circle':
          if (aspectRatio > 0.85 && aspectRatio < 1.18) weightedScore += 0.04;
          if (circularity > 0.65) weightedScore += 0.03;
          break;
        case 'square':
          if (aspectRatio > 0.85 && aspectRatio < 1.18) weightedScore += 0.05;
          if (cornerProximity > 0.6) weightedScore += 0.04;
          break;
        case 'rectangle':
          if (aspectRatio > 1.3 && aspectRatio < 3.0) weightedScore += 0.04;
          if (edgeCoverage > 0.5) weightedScore += 0.03;
          break;
        case 'triangle':
          if (fillRatio < 0.65) weightedScore += 0.04;
          break;
      }

      if (weightedScore > bestScore) {
        bestScore = weightedScore;
        bestShape = entry.key;
      }
    }

    double finalConfidence = bestScore;
    if (convexity > 0.85) finalConfidence += 0.02;
    if (solidity > 0.7) finalConfidence += 0.02;
    finalConfidence = finalConfidence.clamp(0.30, 0.98);

    return {'shape': bestShape, 'confidence': finalConfidence};
  }

  // ========== NEW: CORNER PROXIMITY (checks if points are near 4 corners) ==========
  double _calculateCornerProximity(List<Offset> points, Rect bounds) {
    final corners = [
      bounds.topLeft,
      bounds.topRight,
      bounds.bottomRight,
      bounds.bottomLeft,
    ];

    final diagonal = (bounds.topLeft - bounds.bottomRight).distance;
    final threshold = diagonal * 0.25; // Within 25% of diagonal from corner

    int cornersCovered = 0;
    for (final corner in corners) {
      for (final point in points) {
        if ((point - corner).distance < threshold) {
          cornersCovered++;
          break;
        }
      }
    }

    return cornersCovered / 4.0;
  }

  // ========== NEW: EDGE COVERAGE (checks how many edges have points along them) ==========
  double _calculateEdgeCoverage(List<Offset> points, Rect bounds) {
    final edges = [
      [bounds.topLeft, bounds.topRight],    // Top
      [bounds.topRight, bounds.bottomRight], // Right
      [bounds.bottomRight, bounds.bottomLeft], // Bottom
      [bounds.bottomLeft, bounds.topLeft],   // Left
    ];

    int edgesCovered = 0;
    for (final edge in edges) {
      for (final point in points) {
        final dist = _distanceFromLine(point, edge[0], edge[1]);
        final edgeLength = (edge[1] - edge[0]).distance;
        if (dist < edgeLength * 0.2) { // Within 20% of edge length
          edgesCovered++;
          break;
        }
      }
    }

    return edgesCovered / 4.0;
  }

  // ========== NEW: TRIANGLE CORNER PROXIMITY (checks for 3 corners) ==========
  double _calculateTriangleCornerProximity(List<Offset> points, Rect bounds) {
    final corners = [
      bounds.topLeft,
      bounds.topRight,
      bounds.bottomRight,
      bounds.bottomLeft,
    ];

    final diagonal = (bounds.topLeft - bounds.bottomRight).distance;
    final threshold = diagonal * 0.25;

    // Find the 3 corners with most points nearby
    final cornerScores = <double>[];
    for (final corner in corners) {
      int nearCount = 0;
      for (final point in points) {
        if ((point - corner).distance < threshold) {
          nearCount++;
        }
      }
      cornerScores.add(nearCount > 0 ? 1.0 : 0.0);
    }

    cornerScores.sort((a, b) => b.compareTo(a));
    // Return average of top 3 corners
    return (cornerScores[0] + cornerScores[1] + cornerScores[2]) / 3.0;
  }

  // ========== ADVANCED LINE DETECTION ==========
  Map<String, dynamic> _isEnhancedLine(List<Offset> points) {
    if (points.length < 5) return {'isLine': false, 'confidence': 0.0};

    final start = points.first;
    final end = points.last;
    final length = (end - start).distance;

    if (length < 30) return {'isLine': false, 'confidence': 0.0};

    // Calculate distances from line
    final deviations = <double>[];
    for (final point in points) {
      deviations.add(_distanceFromLine(point, start, end));
    }

    final maxDeviation = deviations.reduce(max);
    final avgDeviation = _mean(deviations);

    // Calculate line straightness
    final straightness = 1.0 - (avgDeviation / length).clamp(0.0, 0.3);

    // Calculate consistency
    final consistency = 1.0 - ((maxDeviation - avgDeviation) / length).clamp(0.0, 0.2);

    final confidence = 0.5 + straightness * 0.3 + consistency * 0.15;

    return {
      'isLine': confidence > 0.65,
      'confidence': confidence.clamp(0.5, 0.95)
    };
  }

  // ========== RADIAL SYMMETRY FOR CIRCLES ==========
  double _calculateRadialSymmetry(List<Offset> points) {
    final center = _calculateCenter(points);
    final distances = <double>[];

    for (final point in points) {
      distances.add((point - center).distance);
    }

    final meanDist = _mean(distances);
    final stdDev = _stdDev(distances, meanDist);

    return 1.0 - (stdDev / meanDist).clamp(0.0, 0.5);
  }

  // ========== ANGLE VARIANCE ==========
  double _calculateAngleVariance(List<Offset> points) {
    if (points.length < 3) return 180.0;

    final angles = <double>[];
    for (int i = 1; i < points.length - 1; i++) {
      final a = points[i - 1];
      final b = points[i];
      final c = points[i + 1];
      angles.add(_calculateAngle(a, b, c));
    }

    if (angles.isEmpty) return 180.0;
    final meanAngle = _mean(angles);
    return _stdDev(angles, meanAngle);
  }

  // ========== ENHANCED CORNER DETECTION ==========
  List<Offset> _findEnhancedCorners(List<Offset> points) {
    if (points.length < 10) return [];

    final simplified = _simplifyPoints(points, 3.0);
    final corners = <Offset>[];

    for (int i = 1; i < simplified.length - 1; i++) {
      final prev = simplified[i - 1];
      final curr = simplified[i];
      final next = simplified[i + 1];

      final angle = _calculateAngle(prev, curr, next);

      // Detect sharp corners (angles less than 150 degrees)
      if (angle < 150) {
        corners.add(curr);
      }
    }

    // Check closing angle
    if (simplified.length > 2) {
      final closingAngle = _calculateAngle(
        simplified[simplified.length - 2],
        simplified.last,
        simplified.first,
      );
      if (closingAngle < 150) {
        corners.add(simplified.last);
      }
    }

    return _mergeNearbyPoints(corners, 15.0);
  }

  // ========== ENHANCED POLYGON DETECTION ==========
  Map<String, double> _detectEnhancedPolygon(
      List<Offset> points,
      List<Offset> corners,
      int cornerCount,
      double aspectRatio,
      ) {
    final scores = <String, double>{};

    if (cornerCount < 3 || cornerCount > 8) return scores;

    final angles = <double>[];
    final sides = <double>[];

    for (int i = 0; i < corners.length; i++) {
      final prev = corners[(i - 1 + corners.length) % corners.length];
      final curr = corners[i];
      final next = corners[(i + 1) % corners.length];

      angles.add(_calculateAngle(prev, curr, next));
      sides.add((next - curr).distance);
    }

    final avgAngle = _mean(angles);
    final angleStdDev = _stdDev(angles, avgAngle);

    final maxSide = sides.reduce(max);
    final minSide = sides.reduce(min);
    final sideRatio = maxSide / minSide;

    // TRIANGLE DETECTION
    if (cornerCount == 3 || (cornerCount == 4 && angleStdDev > 40 && sideRatio < 1.8)) {
      double triangleScore = 0.6;

      // Check angle sum (should be ~180)
      final angleSum = angles.reduce((a, b) => a + b);
      if ((angleSum - 180).abs() < 30) triangleScore += 0.15;

      // Check side ratio
      if (sideRatio < 1.5) triangleScore += 0.1;

      scores['triangle'] = triangleScore.clamp(0.55, 0.92);
    }

    // SQUARE DETECTION
    if (cornerCount == 4 && aspectRatio > 0.8 && aspectRatio < 1.2 && angleStdDev < 20 && sideRatio < 1.3) {
      double squareScore = 0.7;

      // Check right angles
      final rightAngles = angles.where((a) => (a - 90).abs() < 20).length;
      squareScore += (rightAngles / 4) * 0.15;

      // Check side equality
      squareScore += (1.0 - (sideRatio - 1.0)) * 0.1;

      scores['square'] = squareScore.clamp(0.65, 0.95);
    }

    // RECTANGLE DETECTION
    if (cornerCount == 4 && aspectRatio >= 1.2 && aspectRatio <= 3.5 && angleStdDev < 30) {
      double rectangleScore = 0.65;

      // Check right angles
      final rightAngles = angles.where((a) => (a - 90).abs() < 25).length;
      rectangleScore += (rightAngles / 4) * 0.12;

      // Check aspect ratio
      if (aspectRatio >= 1.5 && aspectRatio <= 2.5) rectangleScore += 0.05;

      scores['rectangle'] = rectangleScore.clamp(0.6, 0.92);
    }

    // PENTAGON DETECTION
    if (cornerCount == 5 && sideRatio < 1.6 && angleStdDev < 25) {
      double pentagonScore = 0.6;
      final expectedAngle = 108.0; // Interior angle of pentagon
      if ((avgAngle - expectedAngle).abs() < 20) pentagonScore += 0.15;
      scores['pentagon'] = pentagonScore.clamp(0.55, 0.88);
    }

    // HEXAGON DETECTION
    if (cornerCount == 6 && sideRatio < 1.5 && angleStdDev < 20) {
      double hexagonScore = 0.6;
      final expectedAngle = 120.0; // Interior angle of hexagon
      if ((avgAngle - expectedAngle).abs() < 15) hexagonScore += 0.15;
      scores['hexagon'] = hexagonScore.clamp(0.55, 0.88);
    }

    // OCTAGON DETECTION
    if (cornerCount == 8 && sideRatio < 1.4 && angleStdDev < 18) {
      double octagonScore = 0.6;
      final expectedAngle = 135.0; // Interior angle of octagon
      if ((avgAngle - expectedAngle).abs() < 15) octagonScore += 0.15;
      scores['octagon'] = octagonScore.clamp(0.55, 0.88);
    }

    return scores;
  }

  // ========== STAR DETECTION ==========
  double _detectStar(List<Offset> points) {
    final corners = _findEnhancedCorners(points);
    if (corners.length < 8 || corners.length > 14) return 0.0;

    final center = _calculateBoundingBox(points).center;
    final distances = <double>[];
    for (final corner in corners) {
      distances.add((corner - center).distance);
    }

    if (distances.isEmpty) return 0.0;

    // Check alternating distances (star pattern)
    final alternatingRatios = <double>[];
    for (int i = 0; i < distances.length - 1; i++) {
      alternatingRatios.add(max(distances[i], distances[i+1]) / min(distances[i], distances[i+1]));
    }

    final avgRatio = _mean(alternatingRatios);
    final ratioStdDev = _stdDev(alternatingRatios, avgRatio);

    if (avgRatio > 1.3 && ratioStdDev < 0.4) {
      double starScore = 0.6 + ((avgRatio - 1.3) * 0.3);
      return starScore.clamp(0.6, 0.92);
    }

    return 0.4;
  }

  // ========== HELPER METHODS ==========

  AssetSuggestion? _getBestAssetSuggestion(String shape, List<Offset> points, double confidence) {
    final bounds = _calculateBoundingBox(points);
    final width = bounds.width;
    final height = bounds.height;
    final aspectRatio = width / height;
    final size = max(width, height);

    final matchingSuggestions = <AssetSuggestion>[];

    for (final suggestion in _assetSuggestions) {
      if (suggestion.shape == shape) {
        if (confidence < suggestion.minConfidence) continue;
        if (aspectRatio < suggestion.minAspectRatio) continue;
        if (aspectRatio > suggestion.maxAspectRatio) continue;
        if (size < suggestion.minSize) continue;
        if (size > suggestion.maxSize) continue;
        matchingSuggestions.add(suggestion);
      }
    }

    if (matchingSuggestions.isEmpty) return null;
    matchingSuggestions.sort((a, b) => b.minConfidence.compareTo(a.minConfidence));
    return matchingSuggestions.first;
  }

  List<AssetSuggestion> getSuggestionsForShape(String shape) {
    return _assetSuggestions.where((s) => s.shape == shape).toList();
  }

  AssetSuggestion? getSuggestionByIndex(int index) {
    if (index >= 0 && index < _assetSuggestions.length) {
      return _assetSuggestions[index];
    }
    return null;
  }

  // ========== SHAPE CORRECTION METHODS ==========
  List<Offset> applyManualCorrection(List<Offset> points) {
    if (points.length < 3) return points;

    final detection = _enhancedShapeDetection(points);
    final shape = detection['shape'];
    final confidence = detection['confidence'];

    if (confidence < 0.55) {
      return _advancedSmoothPoints(points);
    }

    switch (shape) {
      case 'circle':
        return _generatePerfectCircle(points);
      case 'oval':
        return _generatePerfectOval(points);
      case 'triangle':
        return _generatePerfectTriangle(points);
      case 'square':
        return _generatePerfectSquare(points);
      case 'rectangle':
        return _generatePerfectRectangle(points);
      case 'pentagon':
        return _generatePerfectPolygon(points, 5);
      case 'hexagon':
        return _generatePerfectPolygon(points, 6);
      case 'octagon':
        return _generatePerfectPolygon(points, 8);
      case 'star':
        return _generatePerfectStar(points);
      case 'line':
        return _generatePerfectLine(points);
      default:
        return _advancedSmoothPoints(points);
    }
  }

  List<Offset> applyAutoCorrection(List<Offset> points) {
    if (!_autoCorrectionEnabled || points.length < 3) return points;
    final corrected = applyManualCorrection(points);
    return _blendCorrection(corrected, points);
  }

  // ========== PERFECT SHAPE GENERATORS ==========
  List<Offset> _generatePerfectCircle(List<Offset> points) {
    final bounds = _calculateBoundingBox(points);
    final center = bounds.center;
    final radius = max(bounds.width, bounds.height) / 2;
    const numPoints = 72;

    final circle = <Offset>[];
    for (int i = 0; i <= numPoints; i++) {
      final angle = 2 * pi * i / numPoints;
      circle.add(Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      ));
    }
    return circle;
  }

  List<Offset> _generatePerfectOval(List<Offset> points) {
    final bounds = _calculateBoundingBox(points);
    final center = bounds.center;
    final radiusX = bounds.width / 2;
    final radiusY = bounds.height / 2;
    const numPoints = 72;

    final oval = <Offset>[];
    for (int i = 0; i <= numPoints; i++) {
      final angle = 2 * pi * i / numPoints;
      oval.add(Offset(
        center.dx + radiusX * cos(angle),
        center.dy + radiusY * sin(angle),
      ));
    }
    return oval;
  }

  List<Offset> _generatePerfectTriangle(List<Offset> points) {
    final bounds = _calculateBoundingBox(points);
    final orientation = _getTriangleOrientation(points);

    List<Offset> triangle;
    if (orientation == 'upward') {
      triangle = [
        Offset(bounds.center.dx, bounds.top),
        Offset(bounds.right, bounds.bottom),
        Offset(bounds.left, bounds.bottom),
      ];
    } else {
      triangle = [
        Offset(bounds.center.dx, bounds.bottom),
        Offset(bounds.right, bounds.top),
        Offset(bounds.left, bounds.top),
      ];
    }
    triangle.add(triangle.first);
    return _resamplePoints(triangle, max(points.length, 30));
  }

  List<Offset> _generatePerfectSquare(List<Offset> points) {
    final bounds = _calculateBoundingBox(points);
    final size = max(bounds.width, bounds.height);
    final center = bounds.center;

    final left = center.dx - size / 2;
    final top = center.dy - size / 2;
    final right = center.dx + size / 2;
    final bottom = center.dy + size / 2;

    final square = [
      Offset(left, top),
      Offset(right, top),
      Offset(right, bottom),
      Offset(left, bottom),
      Offset(left, top),
    ];
    return _resamplePoints(square, max(points.length, 40));
  }

  List<Offset> _generatePerfectRectangle(List<Offset> points) {
    final bounds = _calculateBoundingBox(points);
    final rectangle = [
      Offset(bounds.left, bounds.top),
      Offset(bounds.right, bounds.top),
      Offset(bounds.right, bounds.bottom),
      Offset(bounds.left, bounds.bottom),
      Offset(bounds.left, bounds.top),
    ];
    return _resamplePoints(rectangle, max(points.length, 40));
  }

  List<Offset> _generatePerfectPolygon(List<Offset> points, int sides) {
    final bounds = _calculateBoundingBox(points);
    final center = bounds.center;
    final radius = max(bounds.width, bounds.height) / 2;

    final polygon = <Offset>[];
    for (int i = 0; i <= sides; i++) {
      final angle = 2 * pi * i / sides - pi / 2;
      polygon.add(Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      ));
    }
    return _resamplePoints(polygon, max(points.length, 50));
  }

  List<Offset> _generatePerfectStar(List<Offset> points) {
    final bounds = _calculateBoundingBox(points);
    final center = bounds.center;
    final outerRadius = max(bounds.width, bounds.height) / 2;
    final innerRadius = outerRadius * 0.42;

    final star = <Offset>[];
    for (int i = 0; i < 10; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = pi * i / 5 - pi / 2;
      star.add(Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      ));
    }
    star.add(star.first);
    return _resamplePoints(star, max(points.length, 50));
  }

  List<Offset> _generatePerfectLine(List<Offset> points) {
    if (points.length < 2) return points;
    final start = points.first;
    final end = points.last;

    final line = <Offset>[];
    for (int i = 0; i < points.length; i++) {
      final t = i / (points.length - 1);
      line.add(Offset(
        start.dx + (end.dx - start.dx) * t,
        start.dy + (end.dy - start.dy) * t,
      ));
    }
    return line;
  }

  // ========== CORRECTION BLENDING ==========
  List<Offset> _blendCorrection(List<Offset> corrected, List<Offset> original) {
    if (_correctionStrength >= 0.98) return corrected;
    if (_correctionStrength <= 0.1) return original;

    final result = <Offset>[];
    for (int i = 0; i < original.length; i++) {
      final t = i / (original.length - 1);
      int correctedIndex = (t * (corrected.length - 1)).round();
      correctedIndex = correctedIndex.clamp(0, corrected.length - 1);

      result.add(Offset(
        original[i].dx * (1 - _correctionStrength) + corrected[correctedIndex].dx * _correctionStrength,
        original[i].dy * (1 - _correctionStrength) + corrected[correctedIndex].dy * _correctionStrength,
      ));
    }
    return result;
  }

  // ========== SMOOTHING METHODS ==========
  List<Offset> _advancedSmoothPoints(List<Offset> points) {
    if (points.length < 5) return List.from(points);

    final smoothed = <Offset>[points.first];
    for (int i = 2; i < points.length - 2; i++) {
      final avgX = (points[i-2].dx + points[i-1].dx + points[i].dx + points[i+1].dx + points[i+2].dx) / 5;
      final avgY = (points[i-2].dy + points[i-1].dy + points[i].dy + points[i+1].dy + points[i+2].dy) / 5;
      smoothed.add(Offset(avgX, avgY));
    }
    smoothed.add(points.last);
    return smoothed;
  }

  // ========== QUALITY METRICS ==========
  double _calculateConvexity(List<Offset> points) {
    if (points.length < 3) return 0.0;
    final hull = _computeConvexHull(points);
    final hullArea = _calculateArea(hull);
    final originalArea = _calculateArea(points);
    return hullArea > 0 ? originalArea / hullArea : 0.0;
  }

  double _calculateSolidity(List<Offset> points, double area) {
    final bounds = _calculateBoundingBox(points);
    final boundsArea = bounds.width * bounds.height;
    return boundsArea > 0 ? area / boundsArea : 0.0;
  }

  String _smartObjectClassification(String shape, List<Offset> points) {
    final bounds = _calculateBoundingBox(points);
    final width = bounds.width;
    final height = bounds.height;
    final aspectRatio = width / height;
    final area = width * height;

    switch (shape) {
      case 'circle':
        if (area < 1500) return 'Small Dot';
        if (width < 40) return 'Button';
        if (width < 80) return 'Coin';
        if (width < 130) return 'Circle';
        if (width < 200) return 'Ball';
        if (width < 300) return 'Large Circle';
        return 'Sun';

      case 'oval':
        if (height > width * 1.8) return 'Egg';
        return 'Oval';

      case 'triangle':
        final orientation = _getTriangleOrientation(points);
        if (orientation == 'upward') {
          if (height > width * 1.3) return 'Mountain';
          if (area < 2000) return 'Small Triangle';
          return 'Triangle';
        } else {
          return 'Downward Triangle';
        }

      case 'square':
        if (area < 1600) return 'Small Square';
        if (area < 6400) return 'Square';
        return 'Large Square';

      case 'rectangle':
        if (height > width * 2.5) return 'Door';
        if (width > height * 2.5) return 'Book';
        if (area < 3000) return 'Small Rectangle';
        return 'Rectangle';

      case 'pentagon':
        return 'House Shape';

      case 'hexagon':
        return 'Honeycomb';

      case 'octagon':
        return 'Stop Sign';

      case 'star':
        return 'Star';

      case 'line':
        final angle = _calculateLineAngle(points).abs();
        if (angle < 10) return 'Horizontal Line';
        if (angle > 80) return 'Vertical Line';
        return 'Diagonal Line';

      default:
        return 'Unknown Shape';
    }
  }

  // ========== GEOMETRY HELPERS ==========
  Rect _calculateBoundingBox(List<Offset> points) {
    if (points.isEmpty) return Rect.zero;

    double minX = points.first.dx;
    double maxX = points.first.dx;
    double minY = points.first.dy;
    double maxY = points.first.dy;

    for (final point in points) {
      if (point.dx < minX) minX = point.dx;
      if (point.dx > maxX) maxX = point.dx;
      if (point.dy < minY) minY = point.dy;
      if (point.dy > maxY) maxY = point.dy;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  double _calculateArea(List<Offset> points) {
    if (points.length < 3) return 0.0;

    double area = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      area += points[i].dx * points[i + 1].dy - points[i + 1].dx * points[i].dy;
    }
    return area.abs() / 2.0;
  }

  double _calculatePerimeter(List<Offset> points) {
    double perimeter = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      perimeter += (points[i + 1] - points[i]).distance;
    }
    return perimeter;
  }

  double _calculateAngle(Offset a, Offset b, Offset c) {
    final ba = a - b;
    final bc = c - b;
    final dot = ba.dx * bc.dx + ba.dy * bc.dy;
    final cross = ba.dx * bc.dy - ba.dy * bc.dx;
    return atan2(cross.abs(), dot) * 180 / pi;
  }

  double _distanceFromLine(Offset point, Offset lineStart, Offset lineEnd) {
    final lineLength = (lineEnd - lineStart).distance;
    if (lineLength < 0.1) return (point - lineStart).distance;

    final t = ((point.dx - lineStart.dx) * (lineEnd.dx - lineStart.dx) +
        (point.dy - lineStart.dy) * (lineEnd.dy - lineStart.dy)) /
        (lineLength * lineLength);

    final tClamped = t.clamp(0.0, 1.0);
    final projection = Offset(
      lineStart.dx + tClamped * (lineEnd.dx - lineStart.dx),
      lineStart.dy + tClamped * (lineEnd.dy - lineStart.dy),
    );

    return (point - projection).distance;
  }

  List<Offset> _computeConvexHull(List<Offset> points) {
    if (points.length < 3) return List.from(points);

    List<Offset> sorted = List.from(points);
    sorted.sort((a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));

    List<Offset> hull = [];

    for (var p in sorted) {
      while (hull.length >= 2 && _cross(hull[hull.length-2], hull.last, p) <= 0) {
        hull.removeLast();
      }
      hull.add(p);
    }

    return hull;
  }

  double _cross(Offset o, Offset a, Offset b) {
    return (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  }

  List<Offset> _simplifyPoints(List<Offset> points, double epsilon) {
    if (points.length < 3) return List.from(points);

    double maxDistance = 0;
    int index = 0;

    for (int i = 1; i < points.length - 1; i++) {
      double distance = _distanceFromLine(points[i], points.first, points.last);
      if (distance > maxDistance) {
        maxDistance = distance;
        index = i;
      }
    }

    if (maxDistance > epsilon) {
      final firstPart = _simplifyPoints(points.sublist(0, index + 1), epsilon);
      final secondPart = _simplifyPoints(points.sublist(index), epsilon);
      return [...firstPart.sublist(0, firstPart.length - 1), ...secondPart];
    } else {
      return [points.first, points.last];
    }
  }

  List<Offset> _mergeNearbyPoints(List<Offset> points, double threshold) {
    if (points.isEmpty) return points;

    final merged = <Offset>[];
    for (var point in points) {
      bool found = false;
      for (var existing in merged) {
        if ((point - existing).distance < threshold) {
          found = true;
          break;
        }
      }
      if (!found) {
        merged.add(point);
      }
    }
    return merged;
  }

  List<Offset> _resamplePoints(List<Offset> source, int targetCount) {
    if (source.length == targetCount) return source;
    if (targetCount < 2) return source;

    final resampled = <Offset>[];
    for (int i = 0; i < targetCount; i++) {
      final t = i / (targetCount - 1) * (source.length - 1);
      final index = t.floor();
      final fraction = t - index;

      if (index >= source.length - 1) {
        resampled.add(source.last);
      } else {
        resampled.add(Offset(
          source[index].dx * (1 - fraction) + source[index + 1].dx * fraction,
          source[index].dy * (1 - fraction) + source[index + 1].dy * fraction,
        ));
      }
    }
    return resampled;
  }

  String _getTriangleOrientation(List<Offset> points) {
    final bounds = _calculateBoundingBox(points);
    final center = bounds.center;

    int pointsAbove = 0;
    int pointsBelow = 0;

    for (final point in points) {
      if (point.dy < center.dy) {
        pointsAbove++;
      } else {
        pointsBelow++;
      }
    }

    return pointsAbove > pointsBelow ? 'upward' : 'downward';
  }

  double _calculateLineAngle(List<Offset> points) {
    if (points.length < 2) return 0.0;
    final start = points.first;
    final end = points.last;
    return atan2(end.dy - start.dy, end.dx - start.dx) * 180 / pi;
  }

  double _mean(List<double> values) {
    if (values.isEmpty) return 0.0;
    double sum = 0.0;
    for (var v in values) {
      sum += v;
    }
    return sum / values.length;
  }

  double _stdDev(List<double> values, double mean) {
    if (values.length < 2) return 0.0;
    double sumSquaredDiff = 0.0;
    for (var v in values) {
      sumSquaredDiff += (v - mean) * (v - mean);
    }
    return sqrt(sumSquaredDiff / values.length);
  }

  // ========== BACKGROUND MANAGEMENT ==========
  void selectBackground(String backgroundName) {
    _selectedBackground = backgroundName;
    notifyListeners();
  }

  String getBackgroundPath(String backgroundName) {
    try {
      final background = _backgrounds.firstWhere(
            (bg) => bg.name == backgroundName,
      );
      return background.path;
    } catch (e) {
      return '';
    }
  }

  // ========== CLEAR DETECTIONS ==========
  void clearDetections() {
    _detectedShapes.clear();
    _detectedShape = '';
    _classifiedObject = '';
    _detectionConfidence = 0.0;
    _currentSuggestion = null;
    notifyListeners();
  }
}