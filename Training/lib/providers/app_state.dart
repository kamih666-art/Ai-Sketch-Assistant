import 'package:flutter/material.dart';

class AppStateProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  String _currentMode = 'canvas';
  List<Map<String, dynamic>> _recentProjects = [];

  bool get isDarkMode => _isDarkMode;
  String get currentMode => _currentMode;
  List<Map<String, dynamic>> get recentProjects => _recentProjects;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setCurrentMode(String mode) {
    _currentMode = mode;
    notifyListeners();
  }

  void addRecentProject(Map<String, dynamic> project) {
    _recentProjects.insert(0, project);
    if (_recentProjects.length > 10) {
      _recentProjects.removeLast();
    }
    notifyListeners();
  }

  void clearRecentProjects() {
    _recentProjects.clear();
    notifyListeners();
  }
}