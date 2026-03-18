import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Để nhận diện chạy trên Web hay Mobile
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

    if (kIsWeb) {
      // CHẾ ĐỘ CHROME: Nạp dữ liệu mẫu trực tiếp vào bộ nhớ
      _loadMockDataForWeb();
    } else {
      // CHẾ ĐỘ ĐIỆN THOẠI: Dùng SQLite
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
        debugPrint("SQLite Error, falling back to Mock Data: $e");
        _loadMockDataForWeb();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  void _loadMockDataForWeb() {
    // Tái hiện bộ dữ liệu "khủng" cho các bạn chạy Web
    _departments = [
      Department(id: 'd1', name: 'CNTT', icon: 'laptop'),
      Department(id: 'd2', name: 'Kinh tế', icon: 'chart-line'),
      Department(id: 'd3', name: 'Ngôn ngữ', icon: 'language'),
      Department(id: 'd4', name: 'Ô tô', icon: 'car'),
      Department(id: 'd5', name: 'Du lịch', icon: 'hotel'),
      Department(id: 'd6', name: 'Điện tử', icon: 'bolt'),
      Department(id: 'd7', name: 'Đồ họa', icon: 'palette'),
    ];

    _majors = [
      Major(id: 'm1', name: 'Kỹ thuật phần mềm', departmentId: 'd1'),
      Major(id: 'm2', name: 'Marketing', departmentId: 'd2'),
      Major(id: 'm3', name: 'Ngôn ngữ Anh', departmentId: 'd3'),
      Major(id: 'm4', name: 'Quản trị khách sạn', departmentId: 'd5'),
    ];

    _classes = [
      ClassInfo(id: 'c1', name: 'PM K21A', majorId: 'm1'),
      ClassInfo(id: 'c2', name: 'MK K22B', majorId: 'm2'),
      ClassInfo(id: 'c3', name: 'NNA K20C', majorId: 'm3'),
    ];

    _students = [
      Student(id: '1', mssv: 'SV001', name: 'Nguyễn Văn Hiếu', classId: 'c1', hometown: 'Hà Nội', avatarUrl: 'https://i.pravatar.cc/150?u=1', phoneNumber: '091', status: StudentStatus.studying, grades: [Grade(subjectId: 'Flutter', score: 9.5)]),
      Student(id: '2', mssv: 'SV002', name: 'Lê Thị Mai', classId: 'c1', hometown: 'Đà Nẵng', avatarUrl: 'https://i.pravatar.cc/150?u=2', phoneNumber: '092', status: StudentStatus.studying, grades: [Grade(subjectId: 'Flutter', score: 8.0)]),
      Student(id: '3', mssv: 'SV003', name: 'Trần Minh Quân', classId: 'c2', hometown: 'HCM', avatarUrl: 'https://i.pravatar.cc/150?u=3', phoneNumber: '093', status: StudentStatus.studying, grades: [Grade(subjectId: 'Marketing', score: 9.0)]),
      Student(id: '4', mssv: 'SV004', name: 'Phạm Hoàng Long', classId: 'c2', hometown: 'Hải Phòng', avatarUrl: 'https://i.pravatar.cc/150?u=4', phoneNumber: '094', status: StudentStatus.studying, grades: [Grade(subjectId: 'Marketing', score: 7.5)]),
      Student(id: '5', mssv: 'SV005', name: 'Vũ Thanh Thảo', classId: 'c3', hometown: 'Cần Thơ', avatarUrl: 'https://i.pravatar.cc/150?u=5', phoneNumber: '095', status: StudentStatus.studying, grades: [Grade(subjectId: 'English', score: 8.5)]),
      // Thêm tiếp cho đủ 20 SV...
    ];
  }

  // Các hàm Filter giữ nguyên
  List<Department> get departments => _departments;
  String? get selectedDepartmentId => _selectedDepartmentId;

  void selectDepartment(String? id) {
    _selectedDepartmentId = id;
    notifyListeners();
  }

  List<Student> get students {
    Iterable<Student> filtered = _students;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()) || s.mssv.contains(_searchQuery));
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

  String getDepartmentName(String classId) {
    try {
      final classInfo = _classes.firstWhere((c) => c.id == classId);
      final major = _majors.firstWhere((m) => m.id == classInfo.majorId);
      return _departments.firstWhere((d) => d.id == major.departmentId).name;
    } catch (e) { return 'Unknown'; }
  }

  String getClassName(String classId) {
    try { return _classes.firstWhere((c) => c.id == classId).name; } catch (e) { return 'Unknown'; }
  }

  int get totalStudents => _students.length;
  int get excellentStudents => _students.where((s) => s.gpa4 >= 3.6).length;
  int get warningStudents => _students.where((s) => s.gpa4 < 2.0).length;

  Future<void> refreshStudents() async {
    await loadData();
  }
}
