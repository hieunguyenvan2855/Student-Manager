import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/academic_models.dart';
import '../database/database_helper.dart';

class StudentProvider with ChangeNotifier {
  List<Department> _departments = [];
  List<Major> _majors = [];
  List<ClassInfo> _classes = [];
  List<Student> _students = [];
  bool _isLoading = true;

  String _searchQuery = '';
  String? _selectedDepartmentId;

  bool get isLoading => _isLoading;

  StudentProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;

      final deptMaps = await db.query('departments');
      _departments = deptMaps.map((m) => Department.fromMap(m)).toList();

      final majorMaps = await db.query('majors');
      _majors = majorMaps.map((m) => Major.fromMap(m)).toList();

      final classMaps = await db.query('classes');
      _classes = classMaps.map((m) => ClassInfo.fromMap(m)).toList();

      final studentMaps = await db.query('students');
      List<Student> loadedStudents = [];
      for (var sMap in studentMaps) {
        final gradeMaps = await db.query('grades', where: 'studentId = ?', whereArgs: [sMap['id']]);
        final grades = gradeMaps.map((g) => Grade.fromMap(g)).toList();
        loadedStudents.add(Student.fromMap(sMap, grades));
      }
      _students = loadedStudents;
    } catch (e) {
      debugPrint("Error loading data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Department> get departments => _departments;
  String? get selectedDepartmentId => _selectedDepartmentId;

  void selectDepartment(String? id) {
    _selectedDepartmentId = id;
    notifyListeners();
  }

  List<Student> get students {
    Iterable<Student> filtered = _students;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((s) =>
          s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.mssv.contains(_searchQuery));
    }
    if (_selectedDepartmentId != null) {
      filtered = filtered.where((s) {
        try {
          final classInfo = _classes.firstWhere((c) => c.id == s.classId);
          final major = _majors.firstWhere((m) => m.id == classInfo.majorId);
          return major.departmentId == _selectedDepartmentId;
        } catch (e) { return false; }
      });
    }
    return filtered.toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  String getMajorName(String classId) {
    try {
      final classInfo = _classes.firstWhere((c) => c.id == classId);
      return _majors.firstWhere((m) => m.id == classInfo.majorId).name;
    } catch (e) { return 'Unknown'; }
  }

  int get totalStudents => _students.length;
  int get excellentStudents => _students.where((s) => s.gpa4 >= 3.6).length;
  int get warningStudents => _students.where((s) => s.gpa4 < 2.0).length;

  Future<void> refreshStudents() async {
    await loadData();
  }
}
