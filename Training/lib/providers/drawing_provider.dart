import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:training/features/canvas/screens/Canvas_image.dart'; // Import CanvasImageElement from here

class DrawingProvider extends ChangeNotifier {
  List<List<Offset>> _strokes = [];
  List<Color> _strokeColors = [];
  List<double> _strokeWidths = [];
  List<DrawingElement> _elements = []; // For draggable shapes
  List<ThreeDObject> _threeDObjects = []; // For 3D objects
  List<CanvasImageElement> _uploadedImages = []; // For uploaded images

  List<Offset> _currentStroke = [];
  Color _currentColor = Colors.black;
  double _currentStrokeWidth = 5.0;
  String _currentTool = 'brush';

  // Callback for 3D object placement notifications
  Function(String)? onObjectPlaced;

  // History for undo/redo
  List<DrawingState> _history = [];
  int _historyIndex = -1;

  bool _isDrawing = false;
  bool _isErasing = false;

  // Shape mode
  String _selectedShape = '';
  List<Offset> _shapePreviewPoints = [];
  bool _isDrawingShape = false;

  // 3D Object mode
  ThreeDObject? _selected3DObject;
  bool _isPlacing3DObject = false;

  // Text
  List<TextData> _texts = [];

  // Auto-correction management
  bool _hasPendingCorrection = false;

  // Drag and drop
  DrawingElement? _selectedElement;
  ThreeDObject? _selected3DElement;
  CanvasImageElement? _selectedUploadedImage; // For selected uploaded image
  Offset? _dragStartPosition;
  bool _isDragging = false;

  // Image picker
  final ImagePicker _imagePicker = ImagePicker();

  DrawingProvider() {
    _addToHistory();
  }

  // Getters
  List<List<Offset>> get strokes => _strokes;
  List<Color> get strokeColors => _strokeColors;
  List<double> get strokeWidths => _strokeWidths;
  List<Offset> get currentStroke => _currentStroke;
  Color get currentColor => _currentColor;
  double get currentStrokeWidth => _currentStrokeWidth;
  String get currentTool => _currentTool;
  bool get isDrawing => _isDrawing;
  bool get isErasing => _isErasing;
  bool get canUndo => _historyIndex > 0;
  bool get canRedo => _historyIndex < _history.length - 1;
  String get selectedShape => _selectedShape;
  List<Offset> get shapePreviewPoints => _shapePreviewPoints;
  bool get isDrawingShape => _isDrawingShape;
  List<TextData> get texts => _texts;
  bool get hasPendingCorrection => _hasPendingCorrection;
  List<DrawingElement> get elements => _elements;
  List<ThreeDObject> get threeDObjects => _threeDObjects;
  List<CanvasImageElement> get uploadedImages => _uploadedImages;
  DrawingElement? get selectedElement => _selectedElement;
  ThreeDObject? get selected3DElement => _selected3DElement;
  CanvasImageElement? get selectedUploadedImage => _selectedUploadedImage;
  bool get isDragging => _isDragging;
  bool get isPlacing3DObject => _isPlacing3DObject;
  ThreeDObject? get selected3DObject => _selected3DObject;

  // Drawing methods
  void startDrawing(Offset point) {
    _isDrawing = true;
    if (_currentTool == 'shapes' && _selectedShape.isNotEmpty) {
      _isDrawingShape = true;
      _shapePreviewPoints = [point];
    } else if (_currentTool == '3dobjects' && _selected3DObject != null) {
      // Place 3D object at this position
      _place3DObject(point);
    } else if (_currentTool != 'text') {
      _currentStroke = [point];
    }
    notifyListeners();
  }

  void updateDrawing(Offset point) {
    if (!_isDrawing) return;
    if (_currentTool == 'shapes' && _isDrawingShape) {
      if (_shapePreviewPoints.length == 1) {
        _shapePreviewPoints.add(point);
      } else {
        _shapePreviewPoints[1] = point;
      }
    } else if (_currentTool != 'text' && _currentTool != '3dobjects') {
      _currentStroke.add(point);
    }
    notifyListeners();
  }

  void stopDrawing() {
    if (!_isDrawing) return;
    _isDrawing = false;

    if (_currentTool == 'shapes' && _isDrawingShape) {
      _completeShapeDrawing();
      _isDrawingShape = false;
    } else if (_currentTool != 'text' && _currentTool != '3dobjects' && _currentStroke.length > 1) {
      _saveCurrentStroke();
    }

    _currentStroke.clear();
    notifyListeners();
  }

  void _saveCurrentStroke() {
    if (_currentStroke.length > 1) {
      _addToHistory();
      _strokes.add(List.from(_currentStroke));
      _strokeColors.add(_currentColor);
      _strokeWidths.add(_currentStrokeWidth);
    }
  }

  void _completeShapeDrawing() {
    if (_shapePreviewPoints.length < 2 || _selectedShape.isEmpty) return;

    final start = _shapePreviewPoints[0];
    final end = _shapePreviewPoints[1];
    List<Offset> shapePoints = [];

    switch (_selectedShape) {
      case 'rectangle':
        shapePoints = _generateRectangle(start, end);
        break;
      case 'square':
        shapePoints = _generateSquare(start, end);
        break;
      case 'circle':
        shapePoints = _generateCircle(start, end);
        break;
      case 'oval':
        shapePoints = _generateOval(start, end);
        break;
      case 'triangle':
        shapePoints = _generateTriangle(start, end);
        break;
      case 'equilateral_triangle':
        shapePoints = _generateEquilateralTriangle(start, end);
        break;
      case 'line':
        shapePoints = _generateLine(start, end);
        break;
      case 'pentagon':
        shapePoints = _generateRegularPolygon(5, start, end);
        break;
      case 'hexagon':
        shapePoints = _generateRegularPolygon(6, start, end);
        break;
      case 'heptagon':
        shapePoints = _generateRegularPolygon(7, start, end);
        break;
      case 'octagon':
        shapePoints = _generateRegularPolygon(8, start, end);
        break;
      case 'nonagon':
        shapePoints = _generateRegularPolygon(9, start, end);
        break;
      case 'decagon':
        shapePoints = _generateRegularPolygon(10, start, end);
        break;
      case 'star':
        shapePoints = _generateStar(5, start, end);
        break;
      case 'cross':
        shapePoints = _generateCross(start, end);
        break;
      case 'arrow':
        shapePoints = _generateArrow(start, end);
        break;
      case 'rhombus':
        shapePoints = _generateRhombus(start, end);
        break;
      case 'parallelogram':
        shapePoints = _generateParallelogram(start, end);
        break;
      case 'trapezoid':
        shapePoints = _generateTrapezoid(start, end);
        break;
    }

    if (shapePoints.isNotEmpty) {
      _addToHistory();

      final element = DrawingElement(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'shape',
        shapeType: _selectedShape,
        points: shapePoints,
        color: _currentColor,
        strokeWidth: _currentStrokeWidth,
        bounds: _calculateBounds(shapePoints),
      );

      _elements.add(element);
      _shapePreviewPoints.clear();
      _selectedShape = '';
      notifyListeners();
    }
  }

  List<Offset> _generateRectangle(Offset start, Offset end) {
    return [
      start,
      Offset(end.dx, start.dy),
      end,
      Offset(start.dx, end.dy),
      start,
    ];
  }

  List<Offset> _generateSquare(Offset start, Offset end) {
    final size = max((end.dx - start.dx).abs(), (end.dy - start.dy).abs());
    final signX = end.dx > start.dx ? 1.0 : -1.0;
    final signY = end.dy > start.dy ? 1.0 : -1.0;

    final squareEnd = Offset(
      start.dx + size * signX,
      start.dy + size * signY,
    );

    return [
      start,
      Offset(squareEnd.dx, start.dy),
      squareEnd,
      Offset(start.dx, squareEnd.dy),
      start,
    ];
  }

  List<Offset> _generateCircle(Offset start, Offset end) {
    final center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    final radius = max(
        (end.dx - start.dx).abs() / 2,
        (end.dy - start.dy).abs() / 2
    );

    final points = <Offset>[];
    final numPoints = 36;

    for (int i = 0; i <= numPoints; i++) {
      final angle = 2 * pi * i / numPoints;
      points.add(Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      ));
    }
    return points;
  }
  List<Offset> _generateOval(Offset start, Offset end) {
    final List<Offset> points = [];

    final center = Offset(
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2,
    );

    final radiusX = (end.dx - start.dx).abs() / 2;
    final radiusY = (end.dy - start.dy).abs() / 3; // 👈 oval banane ke liye height kam

    const int segments = 60;

    for (int i = 0; i <= segments; i++) {
      final theta = (2 * pi * i) / segments;

      final x = center.dx + radiusX * cos(theta);
      final y = center.dy + radiusY * sin(theta);

      points.add(Offset(x, y));
    }

    return points;
  }

  List<Offset> _generateTriangle(Offset start, Offset end) {
    final centerX = (start.dx + end.dx) / 2;

    return [
      Offset(centerX, start.dy),
      Offset(end.dx, end.dy),
      Offset(start.dx, end.dy),
      Offset(centerX, start.dy),
    ];
  }

  List<Offset> _generateEquilateralTriangle(Offset start, Offset end) {
    final width = (end.dx - start.dx).abs();
    final height = width * sqrt(3) / 2;

    final centerX = (start.dx + end.dx) / 2;
    final topY = start.dy;
    final bottomY = start.dy + height;

    return [
      Offset(centerX, topY),
      Offset(centerX + width/2, bottomY),
      Offset(centerX - width/2, bottomY),
      Offset(centerX, topY),
    ];
  }

  List<Offset> _generateLine(Offset start, Offset end) {
    return [start, end];
  }

  List<Offset> _generateRegularPolygon(int sides, Offset start, Offset end) {
    final center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    final radius = max((end.dx - start.dx).abs(), (end.dy - start.dy).abs()) / 2;

    final points = <Offset>[];
    for (int i = 0; i <= sides; i++) {
      final angle = 2 * pi * i / sides - pi / 2;
      points.add(Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      ));
    }
    return points;
  }

  List<Offset> _generateStar(int points, Offset start, Offset end) {
    final center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    final outerRadius = max((end.dx - start.dx).abs(), (end.dy - start.dy).abs()) / 2;
    final innerRadius = outerRadius * 0.4;

    final starPoints = <Offset>[];
    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = pi * i / points - pi / 2;
      starPoints.add(Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      ));
    }
    starPoints.add(starPoints.first);
    return starPoints;
  }

  List<Offset> _generateArrow(Offset start, Offset end) {
    final direction = end - start;
    final angle = atan2(direction.dy, direction.dx);
    final length = direction.distance;
    final arrowSize = length * 0.2;

    final shaft = [start, Offset(end.dx - arrowSize * cos(angle), end.dy - arrowSize * sin(angle))];
    final arrowHead = [
      end,
      Offset(end.dx - arrowSize * cos(angle - pi/6), end.dy - arrowSize * sin(angle - pi/6)),
      Offset(end.dx - arrowSize * cos(angle + pi/6), end.dy - arrowSize * sin(angle + pi/6)),
      end,
    ];

    return [...shaft, ...arrowHead];
  }

  List<Offset> _generateRhombus(Offset start, Offset end) {
    final centerX = (start.dx + end.dx) / 2;
    final centerY = (start.dy + end.dy) / 2;
    final width = (end.dx - start.dx).abs();
    final height = (end.dy - start.dy).abs();

    return [
      Offset(centerX, start.dy),
      Offset(end.dx, centerY),
      Offset(centerX, end.dy),
      Offset(start.dx, centerY),
      Offset(centerX, start.dy),
    ];
  }

  List<Offset> _generateParallelogram(Offset start, Offset end) {
    final skew = (end.dx - start.dx) * 0.2;
    final left = min(start.dx, end.dx);
    final right = max(start.dx, end.dx);
    final top = min(start.dy, end.dy);
    final bottom = max(start.dy, end.dy);

    return [
      Offset(left + skew, top),
      Offset(right + skew, top),
      Offset(right - skew, bottom),
      Offset(left - skew, bottom),
      Offset(left + skew, top),
    ];
  }

  List<Offset> _generateTrapezoid(Offset start, Offset end) {
    final width = (end.dx - start.dx).abs();
    final height = (end.dy - start.dy).abs();
    final topWidth = width * 0.6;
    final topOffset = width * 0.2;

    final left = min(start.dx, end.dx);
    final top = min(start.dy, end.dy);

    return [
      Offset(left + topOffset, top),
      Offset(left + topOffset + topWidth, top),
      Offset(left + width, top + height),
      Offset(left, top + height),
      Offset(left + topOffset, top),
    ];
  }
  List<Offset> _generateCross(Offset start, Offset end) {
    final center = Offset(
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2,
    );

    final size = min(
      (end.dx - start.dx).abs(),
      (end.dy - start.dy).abs(),
    ) / 2;

    return [
      Offset(center.dx - size, center.dy),
      Offset(center.dx + size, center.dy),
      Offset(center.dx, center.dy - size),
      Offset(center.dx, center.dy + size),
      Offset(center.dx - size, center.dy),
    ];
  }

  // 3D Objects methods
  void select3DObject(ThreeDObject object) {
    _selected3DObject = object;
    _currentTool = '3dobjects';
    _isPlacing3DObject = true;
    notifyListeners();
  }

  void addThreeDObject(ThreeDObject object) {
    _addToHistory();
    _threeDObjects.add(object);
    onObjectPlaced?.call(object.name);
    notifyListeners();
  }

  void place3DObject(Offset position, ui.Image? cachedImage) {
    if (_selected3DObject == null) return;

    _addToHistory();

    final newObject = ThreeDObject(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _selected3DObject!.name,
      assetPath: _selected3DObject!.assetPath,
      icon: _selected3DObject!.icon,
      position: position,
      size: _selected3DObject!.size,
      scale: 1.0,
      rotation: 0.0,
      cachedImage: cachedImage ?? _selected3DObject!.cachedImage,
    );

    _threeDObjects.add(newObject);
    onObjectPlaced?.call(_selected3DObject!.name);
    notifyListeners();
  }

  void _place3DObject(Offset position) {
    if (_selected3DObject == null) return;

    _addToHistory();

    final newObject = ThreeDObject(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _selected3DObject!.name,
      assetPath: _selected3DObject!.assetPath,
      icon: _selected3DObject!.icon,
      position: position,
      size: _selected3DObject!.size,
      scale: 1.0,
      rotation: 0.0,
      cachedImage: _selected3DObject!.cachedImage,
    );

    _threeDObjects.add(newObject);
    onObjectPlaced?.call(_selected3DObject!.name);
    notifyListeners();
  }

  void resize3DObject(String id, double newSize) {
    final index = _threeDObjects.indexWhere((obj) => obj.id == id);
    if (index != -1) {
      _addToHistory();
      _threeDObjects[index] = _threeDObjects[index].copyWith(
        size: newSize.clamp(30.0, 300.0),
      );
      notifyListeners();
    }
  }

  void update3DObjectScale(String id, double newScale) {
    final index = _threeDObjects.indexWhere((obj) => obj.id == id);
    if (index != -1) {
      _addToHistory();
      _threeDObjects[index] = _threeDObjects[index].copyWith(
        scale: newScale.clamp(0.5, 3.0),
      );
      notifyListeners();
    }
  }
  /// Update 3D object position, rotation, and scale
  void update3DObjectTransform(String id, {Offset? position, double? rotation, double? scale}) {
    final index = _threeDObjects.indexWhere((obj) => obj.id == id);
    if (index != -1) {
      _threeDObjects[index] = _threeDObjects[index].copyWith(
        position: position ?? _threeDObjects[index].position,
        rotation: rotation ?? _threeDObjects[index].rotation,
        scale: scale ?? _threeDObjects[index].scale,
      );
      notifyListeners();
    }
  }
  /// Update uploaded image transform (position, rotation, scale)
  void updateUploadedImageTransform(String id, {Offset? position, double? rotation, double? scale}) {
    final index = _uploadedImages.indexWhere((img) => img.id == id);
    if (index != -1) {
      final img = _uploadedImages[index];

      final newPosition = position ?? img.position;
      final newRotation = rotation ?? img.rotation;
      final newScale = scale ?? img.scale;

      _uploadedImages[index] = CanvasImageElement(
        id: img.id,
        image: img.image,
        position: newPosition,
        scale: newScale,
        rotation: newRotation,
        bounds: Rect.fromCenter(
          center: newPosition,
          width: img.image.width.toDouble() * newScale.abs(),
          height: img.image.height.toDouble() * newScale.abs(),
        ),
      );

      _uploadedImages[index].isSelected = img.isSelected;
      if (img.isSelected) {
        _selectedUploadedImage = _uploadedImages[index];
      }

      notifyListeners();
    }
  }

  // ========== IMAGE UPLOAD METHODS ==========

  // Add uploaded image directly to canvas
  void addUploadedImageFromFile(CanvasImageElement image) {
    _addToHistory();
    _uploadedImages.add(image);
    notifyListeners();
  }

  /// Select uploaded image for manipulation
  void selectUploadedImage(String? id) {
    // Deselect previous
    if (_selectedUploadedImage != null) {
      _selectedUploadedImage!.isSelected = false;
    }

    if (id != null) {
      final index = _uploadedImages.indexWhere((img) => img.id == id);
      if (index != -1) {
        _uploadedImages[index].isSelected = true;
        _selectedUploadedImage = _uploadedImages[index];
      }
    } else {
      _selectedUploadedImage = null;
    }
    notifyListeners();
  }
  // Delete uploaded image
  void deleteUploadedImage(String id) {
    _addToHistory();
    _uploadedImages.removeWhere((img) => img.id == id);
    if (_selectedUploadedImage?.id == id) {
      _selectedUploadedImage = null;
    }
    notifyListeners();
  }

  // Update uploaded image position
  void updateUploadedImagePosition(String id, Offset newPosition) {
    final index = _uploadedImages.indexWhere((img) => img.id == id);
    if (index != -1) {
      _uploadedImages[index].position = newPosition;
      _uploadedImages[index].updateBounds();
      notifyListeners();
    }
  }

  // Clear all uploaded images
  void clearAllUploadedImages() {
    _addToHistory();
    _uploadedImages.clear();
    _selectedUploadedImage = null;
    notifyListeners();
  }

  Rect _calculateBounds(List<Offset> points) {
    if (points.isEmpty) return Rect.zero;

    double minX = points.first.dx;
    double maxX = points.first.dx;
    double minY = points.first.dy;
    double maxY = points.first.dy;

    for (final point in points) {
      minX = min(minX, point.dx);
      maxX = max(maxX, point.dx);
      minY = min(minY, point.dy);
      maxY = max(maxY, point.dy);
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
  /// Delete a 3D object by its ID
  void delete3DObject(String id) {
    _addToHistory();
    _threeDObjects.removeWhere((obj) => obj.id == id);
    if (_selected3DElement?.id == id) {
      _selected3DElement = null;
    }
    notifyListeners();
  }
  // Drag and drop methods (updated to include images)
  void startDragging(Offset position) {
    // First check uploaded images
    for (int i = _uploadedImages.length - 1; i >= 0; i--) {
      final img = _uploadedImages[i];
      if (img.containsPoint(position)) {
        selectUploadedImage(img.id);
        _dragStartPosition = position;
        _isDragging = true;
        notifyListeners();
        return;
      }
    }

    // Then check 3D objects
    for (int i = _threeDObjects.length - 1; i >= 0; i--) {
      final obj = _threeDObjects[i];
      final hitRect = Rect.fromCenter(
        center: obj.position,
        width: obj.size * obj.scale,
        height: obj.size * obj.scale,
      );
      if (hitRect.contains(position)) {
        _selected3DElement = obj;
        _dragStartPosition = position;
        _isDragging = true;
        notifyListeners();
        return;
      }
    }

    // Then check elements (shapes)
    for (int i = _elements.length - 1; i >= 0; i--) {
      final element = _elements[i];
      if (element.bounds.inflate(10).contains(position)) {
        _selectedElement = element;
        _dragStartPosition = position;
        _isDragging = true;
        notifyListeners();
        return;
      }
    }

    // Then check texts
    for (int i = _texts.length - 1; i >= 0; i--) {
      final text = _texts[i];
      if ((position - text.position).distance < 50) {
        _selectedElement = DrawingElement(
          id: 'text_${DateTime.now().millisecondsSinceEpoch}',
          type: 'text',
          text: text.text,
          position: text.position,
          color: text.color,
          fontSize: text.fontSize,
          bounds: Rect.fromLTWH(
              text.position.dx - 40,
              text.position.dy - 15,
              80,
              30
          ),
        );
        _dragStartPosition = position;
        _isDragging = true;
        notifyListeners();
        return;
      }
    }
  }

  void updateDragging(Offset position) {
    if (!_isDragging || _dragStartPosition == null) return;

    final delta = position - _dragStartPosition!;

    if (_selectedUploadedImage != null) {
      // Move uploaded image
      updateUploadedImagePosition(_selectedUploadedImage!.id, _selectedUploadedImage!.position + delta);
    } else if (_selected3DElement != null) {
      // Move 3D object
      final index = _threeDObjects.indexWhere((obj) => obj.id == _selected3DElement!.id);
      if (index != -1) {
        _threeDObjects[index] = _threeDObjects[index].copyWith(
          position: _threeDObjects[index].position + delta,
        );
        _selected3DElement = _threeDObjects[index];
      }
    } else if (_selectedElement != null) {
      if (_selectedElement!.type == 'text') {
        // Move text
        final textIndex = _texts.indexWhere((t) =>
        t.text == _selectedElement!.text &&
            (t.position - (_selectedElement!.position ?? Offset.zero)).distance < 50);

        if (textIndex != -1) {
          _texts[textIndex] = TextData(
            text: _texts[textIndex].text,
            position: _texts[textIndex].position + delta,
            color: _texts[textIndex].color,
            fontSize: _texts[textIndex].fontSize,
          );
        }
      } else {
        // Move shape
        final elementIndex = _elements.indexWhere((e) => e.id == _selectedElement!.id);
        if (elementIndex != -1 && _selectedElement!.points != null) {
          final movedPoints = _selectedElement!.points!.map((p) => p + delta).toList();
          _elements[elementIndex] = DrawingElement(
            id: _selectedElement!.id,
            type: _selectedElement!.type,
            shapeType: _selectedElement!.shapeType,
            points: movedPoints,
            color: _selectedElement!.color,
            strokeWidth: _selectedElement!.strokeWidth,
            bounds: _calculateBounds(movedPoints),
          );
          _selectedElement = _elements[elementIndex];
        }
      }
    }

    _dragStartPosition = position;
    notifyListeners();
  }
  /// Clear all selections
  void clearSelection() {
    if (_selectedUploadedImage != null) {
      _selectedUploadedImage!.isSelected = false;
    }
    _selectedElement = null;
    _selected3DElement = null;
    _selectedUploadedImage = null;
    _selected3DObject = null;
    _isPlacing3DObject = false;
    notifyListeners();
  }

  void stopDragging() {
    if (_isDragging && (_selectedElement != null || _selected3DElement != null || _selectedUploadedImage != null)) {
      _addToHistory();
    }
    _selectedElement = null;
    _selected3DElement = null;
    _selectedUploadedImage = null;
    _dragStartPosition = null;
    _isDragging = false;
    notifyListeners();
  }

  // Tool methods
  void selectTool(String tool) {
    _currentTool = tool;
    if (tool == 'eraser') {
      _isErasing = true;
    } else {
      _isErasing = false;
    }
    if (tool != 'shapes') {
      _selectedShape = '';
      _isDrawingShape = false;
    }
    if (tool != '3dobjects') {
      _selected3DObject = null;
      _isPlacing3DObject = false;
    }
    // Clear any pending strokes when switching tools
    _currentStroke.clear();
    notifyListeners();
  }

  void selectShape(String shape) {
    _selectedShape = shape;
    _currentTool = 'shapes';
    notifyListeners();
  }

  void updateColor(Color color) {
    _currentColor = color;
    notifyListeners();
  }

  void updateStrokeWidth(double width) {
    _currentStrokeWidth = width;
    notifyListeners();
  }

  void toggleEraser() {
    _isErasing = !_isErasing;
    if (_isErasing) {
      _currentTool = 'eraser';
      _currentColor = Colors.white;
    } else {
      _currentTool = 'brush';
      _currentColor = Colors.black;
    }
    notifyListeners();
  }

  void addText(String text, Offset position) {
    _addToHistory();
    _texts.add(TextData(
      text: text,
      position: position,
      color: _currentColor,
      fontSize: _currentStrokeWidth * 4,
    ));
    notifyListeners();
  }

  void clear() {
    _addToHistory();
    _strokes.clear();
    _strokeColors.clear();
    _strokeWidths.clear();
    _elements.clear();
    _threeDObjects.clear();
    _texts.clear();
    _uploadedImages.clear();
    _currentStroke.clear();
    _shapePreviewPoints.clear();
    _selectedShape = '';
    _isDrawingShape = false;
    _hasPendingCorrection = false;
    _selectedElement = null;
    _selected3DElement = null;
    _selectedUploadedImage = null;
    _selected3DObject = null;
    _isPlacing3DObject = false;
    notifyListeners();
  }
// Add this method to your DrawingProvider class
  void eraseAtPoint(Offset point, double radius) {
    _addToHistory();

    // Erase from strokes
    for (int i = _strokes.length - 1; i >= 0; i--) {
      final stroke = _strokes[i];
      bool hit = false;

      for (final p in stroke) {
        if ((p - point).distance <= radius) {
          hit = true;
          break;
        }
      }

      if (hit) {
        _strokes.removeAt(i);
        _strokeColors.removeAt(i);
        _strokeWidths.removeAt(i);
      }
    }

    // Erase from shapes
    for (int i = _elements.length - 1; i >= 0; i--) {
      final element = _elements[i];
      if (element.bounds.inflate(radius).contains(point)) {
        _elements.removeAt(i);
      }
    }

    // Erase from texts
    for (int i = _texts.length - 1; i >= 0; i--) {
      final text = _texts[i];
      if ((text.position - point).distance <= radius + 30) {
        _texts.removeAt(i);
      }
    }

    notifyListeners();
  }

  void eraseCurrentStroke() {
    if (_currentStroke.isNotEmpty) {
      _currentStroke.clear();
      notifyListeners();
    }
  }
  void _addToHistory() {
    final state = DrawingState(
      strokes: _strokes.map((stroke) => List<Offset>.from(stroke)).toList(),
      colors: List<Color>.from(_strokeColors),
      widths: List<double>.from(_strokeWidths),
      texts: _texts.map((text) => text.copyWith()).toList(),
      elements: _elements.map((e) => e.copyWith()).toList(),
      threeDObjects: _threeDObjects.map((obj) => obj.copyWith()).toList(),
    );

    if (_historyIndex < _history.length - 1) {
      _history = _history.sublist(0, _historyIndex + 1);
    }

    _history.add(state);
    _historyIndex++;

    if (_history.length > 30) {
      _history.removeAt(0);
      _historyIndex--;
    }
  }

  void undo() {
    if (canUndo) {
      _historyIndex--;
      _restoreState(_history[_historyIndex]);
      notifyListeners();
    }
  }

  void redo() {
    if (canRedo) {
      _historyIndex++;
      _restoreState(_history[_historyIndex]);
      notifyListeners();
    }
  }
  // Add these methods to your DrawingProvider class

  void startErasing(Offset point) {
    _isErasing = true;
    _currentTool = 'eraser';
    _eraseAtPoint(point, _currentStrokeWidth * 2);
    notifyListeners();
  }

  void updateErasing(Offset point) {
    if (!_isErasing) return;
    _eraseAtPoint(point, _currentStrokeWidth * 2);
    notifyListeners();
  }

  void stopErasing() {
    _isErasing = false;
    notifyListeners();
  }

  void _eraseAtPoint(Offset point, double radius) {
    // Erase from strokes
    List<int> indicesToRemove = [];
    for (int i = 0; i < _strokes.length; i++) {
      final stroke = _strokes[i];
      for (final p in stroke) {
        if ((p - point).distance <= radius) {
          indicesToRemove.add(i);
          break;
        }
      }
    }

    // Remove from end to start
    for (int i = indicesToRemove.length - 1; i >= 0; i--) {
      final index = indicesToRemove[i];
      _strokes.removeAt(index);
      _strokeColors.removeAt(index);
      _strokeWidths.removeAt(index);
    }

    // Erase shapes
    for (int i = _elements.length - 1; i >= 0; i--) {
      final element = _elements[i];
      if (element.bounds.inflate(radius).contains(point)) {
        _elements.removeAt(i);
      }
    }

    // Erase texts
    for (int i = _texts.length - 1; i >= 0; i--) {
      final text = _texts[i];
      if ((text.position - point).distance <= radius + 30) {
        _texts.removeAt(i);
      }
    }
  }

  void _restoreState(DrawingState state) {
    _strokes = state.strokes.map((stroke) => List<Offset>.from(stroke)).toList();
    _strokeColors = List<Color>.from(state.colors);
    _strokeWidths = List<double>.from(state.widths);
    _texts = state.texts.map((text) => text.copyWith()).toList();
    _elements = state.elements.map((e) => e.copyWith()).toList();
    _threeDObjects = state.threeDObjects.map((obj) => obj.copyWith()).toList();

    _currentStroke.clear();
    _shapePreviewPoints.clear();
    _isDrawingShape = false;
    _hasPendingCorrection = false;
    _selectedElement = null;
    _selected3DElement = null;
    _selectedUploadedImage = null;
  }

  void applyAutoCorrection(List<Offset> correctedPoints, int strokeIndex) {
    if (strokeIndex < 0 || strokeIndex >= _strokes.length) return;

    _addToHistory();
    _strokes[strokeIndex] = List<Offset>.from(correctedPoints);
    _hasPendingCorrection = false;
    notifyListeners();
  }

  List<Offset>? getLastStroke() {
    if (_strokes.isEmpty) return null;
    return _strokes.last;
  }

  int getLastStrokeIndex() {
    return _strokes.length - 1;
  }

  void addCorrectedStroke(List<Offset> points) {
    if (points.length < 2) return;
    _addToHistory();
    _strokes.add(List.from(points));
    _strokeColors.add(_currentColor);
    _strokeWidths.add(_currentStrokeWidth);
    notifyListeners();
  }

  void removeLastStroke() {
    if (_strokes.isNotEmpty) {
      _addToHistory();
      _strokes.removeLast();
      _strokeColors.removeLast();
      _strokeWidths.removeLast();
      notifyListeners();
    }
  }

  void applyBatchCorrections(List<List<Offset>> correctedStrokes) {
    _addToHistory();
    _strokes = List.from(correctedStrokes);
    notifyListeners();
  }
  void resetToBrush() {
    _isErasing = false;
    _currentTool = 'brush';
    notifyListeners();
  }
  @override
  void dispose() {
    onObjectPlaced = null;
    super.dispose();
  }
}

class DrawingState {
  final List<List<Offset>> strokes;
  final List<Color> colors;
  final List<double> widths;
  final List<TextData> texts;
  final List<DrawingElement> elements;
  final List<ThreeDObject> threeDObjects;

  DrawingState({
    required this.strokes,
    required this.colors,
    required this.widths,
    required this.texts,
    required this.elements,
    required this.threeDObjects,
  });
}

class TextData {
  final String text;
  final Offset position;
  final Color color;
  final double fontSize;

  TextData({
    required this.text,
    required this.position,
    required this.color,
    required this.fontSize,
  });

  TextData copyWith({
    String? text,
    Offset? position,
    Color? color,
    double? fontSize,
  }) {
    return TextData(
      text: text ?? this.text,
      position: position ?? this.position,
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}

class DrawingElement {
  final String id;
  final String type;
  final String? shapeType;
  final List<Offset>? points;
  final String? text;
  final Offset? position;
  final Color color;
  final double strokeWidth;
  final double? fontSize;
  final Rect bounds;

  DrawingElement({
    required this.id,
    required this.type,
    this.shapeType,
    this.points,
    this.text,
    this.position,
    required this.color,
    this.strokeWidth = 5.0,
    this.fontSize,
    required this.bounds,
  });

  DrawingElement copyWith({
    String? id,
    String? type,
    String? shapeType,
    List<Offset>? points,
    String? text,
    Offset? position,
    Color? color,
    double? strokeWidth,
    double? fontSize,
    Rect? bounds,
  }) {
    return DrawingElement(
      id: id ?? this.id,
      type: type ?? this.type,
      shapeType: shapeType ?? this.shapeType,
      points: points ?? this.points,
      text: text ?? this.text,
      position: position ?? this.position,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      fontSize: fontSize ?? this.fontSize,
      bounds: bounds ?? this.bounds,
    );
  }
}

class ThreeDObject {
  final String id;
  final String name;
  final String assetPath;
  final IconData icon;
  Offset position;
  double size;
  double scale;
  double rotation; // Add rotation property
  ui.Image? cachedImage;

  ThreeDObject({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.icon,
    required this.position,
    this.size = 100.0,
    this.scale = 1.0,
    this.rotation = 0.0, // Initialize rotation
    this.cachedImage,
  });

  ThreeDObject copyWith({
    String? id,
    String? name,
    String? assetPath,
    IconData? icon,
    Offset? position,
    double? size,
    double? scale,
    double? rotation,
    ui.Image? cachedImage,
  }) {
    return ThreeDObject(
      id: id ?? this.id,
      name: name ?? this.name,
      assetPath: assetPath ?? this.assetPath,
      icon: icon ?? this.icon,
      position: position ?? this.position,
      size: size ?? this.size,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      cachedImage: cachedImage ?? this.cachedImage,
    );
  }
}