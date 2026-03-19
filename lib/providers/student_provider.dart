import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
      _loadMockData();
    } else {
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
          final gradeMaps = await db.query(
            'grades',
            where: 'studentId = ?',
            whereArgs: [sMap['id']],
          );
          final grades = gradeMaps.map((g) => Grade.fromMap(g)).toList();
          loadedStudents.add(Student.fromMap(sMap, grades));
        }
        _students = loadedStudents;

        if (_students.isEmpty) _loadMockData();
      } catch (e) {
        _loadMockData();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  void _loadMockData() {
    _departments = [
      Department(id: 'd1', name: 'CNTT', icon: 'laptop'),
      Department(id: 'd2', name: 'Kinh tế', icon: 'chart-line'),
      Department(id: 'd3', name: 'Ngôn ngữ', icon: 'language'),
    ];

    _majors = [
      Major(id: 'm1', name: 'Kỹ thuật phần mềm', departmentId: 'd1'),
      Major(id: 'm2', name: 'Marketing', departmentId: 'd2'),
      Major(id: 'm3', name: 'Ngôn ngữ Anh', departmentId: 'd3'),
    ];

    _classes = [
      ClassInfo(id: 'c1', name: 'PM K21A', majorId: 'm1'),
      ClassInfo(id: 'c2', name: 'MK K22B', majorId: 'm2'),
      ClassInfo(id: 'c3', name: 'NNA K20C', majorId: 'm3'),
    ];

    _students = [
      Student(
        id: '1',
        mssv: 'SV001',
        name: 'Nguyễn Văn Hiếu',
        classId: 'c1',
        hometown: 'Hà Nội',
        birthday: '15/05/2003',
        email: 'hieu.nv@gmail.com',
        avatarUrl: 'https://i.pravatar.cc/150?u=1',
        phoneNumber: '0912345678',
        status: StudentStatus.studying,
        grades: [
          Grade(subjectId: 'Flutter', score: 9.5, credits: 3),
          Grade(subjectId: 'Java', score: 8.0, credits: 4),
          Grade(subjectId: 'SQL', score: 8.5, credits: 2),
          Grade(subjectId: 'Web', score: 7.0, credits: 3),
        ],
      ),
      Student(
        id: '2',
        mssv: 'SV002',
        name: 'Lê Thị Mai',
        classId: 'c1',
        hometown: 'Đà Nẵng',
        birthday: '20/10/2003',
        email: 'mai.lt@gmail.com',
        avatarUrl: 'https://i.pravatar.cc/150?u=2',
        phoneNumber: '0923456789',
        status: StudentStatus.studying,
        grades: [
          Grade(subjectId: 'Flutter', score: 8.0, credits: 3),
          Grade(subjectId: 'Java', score: 9.0, credits: 4),
          Grade(subjectId: 'SQL', score: 7.5, credits: 2),
        ],
      ),
    ];
  }

  void updateStudent(Student updatedStudent) {
    final index = _students.indexWhere((s) => s.id == updatedStudent.id);
    if (index != -1) {
      _students[index] = updatedStudent;
      // persist
      _saveStudentToDb(updatedStudent);
      notifyListeners();
    }
  }

  Future<void> addStudent(Student student) async {
    _students.add(student);
    await _saveStudentToDb(student);
    notifyListeners();
  }

  Future<void> deleteStudent(String id) async {
    final index = _students.indexWhere((s) => s.id == id);
    if (index != -1) {
      final s = _students[index];
      final deleted = Student(
        id: s.id,
        mssv: s.mssv,
        name: s.name,
        classId: s.classId,
        hometown: s.hometown,
        avatarUrl: s.avatarUrl,
        phoneNumber: s.phoneNumber,
        email: s.email,
        birthday: s.birthday,
        grades: s.grades,
        status: StudentStatus.deleted,
      );
      _students[index] = deleted;
      await _saveStudentToDb(deleted);
      notifyListeners();
    }
  }

  List<Department> get departments => _departments;
  List<ClassInfo> get classes => _classes;
  String? get selectedDepartmentId => _selectedDepartmentId;

  void selectDepartment(String? id) {
    _selectedDepartmentId = id;
    notifyListeners();
  }

  Future<void> _saveStudentToDb(Student student) async {
    if (kIsWeb) return;
    try {
      final db = await DatabaseHelper.instance.database;
      // try update first
      final existing = await db.query(
        'students',
        where: 'id = ?',
        whereArgs: [student.id],
      );
      if (existing.isNotEmpty) {
        await db.update(
          'students',
          student.toMap(),
          where: 'id = ?',
          whereArgs: [student.id],
        );
      } else {
        await db.insert('students', student.toMap());
      }
    } catch (e) {
      // ignore persistence errors and keep in-memory
    }
  }

  List<Student> get students {
    Iterable<Student> filtered = _students;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where(
        (s) =>
            s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            s.mssv.contains(_searchQuery),
      );
    }
    if (_selectedDepartmentId != null) {
      filtered = filtered.where((s) {
        try {
          final classInfo = _classes.firstWhere((c) => c.id == s.classId);
          final major = _majors.firstWhere((m) => m.id == classInfo.majorId);
          return major.departmentId == _selectedDepartmentId;
        } catch (e) {
          return false;
        }
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
    } catch (e) {
      return 'Unknown';
    }
  }

  String getDepartmentName(String classId) {
    try {
      final classInfo = _classes.firstWhere((c) => c.id == classId);
      final major = _majors.firstWhere((m) => m.id == classInfo.majorId);
      return _departments.firstWhere((d) => d.id == major.departmentId).name;
    } catch (e) {
      return 'Unknown';
    }
  }

  String getClassName(String classId) {
    try {
      return _classes.firstWhere((c) => c.id == classId).name;
    } catch (e) {
      return 'Unknown';
    }
  }

  int get totalStudents => _students.length;
  int get excellentStudents => _students.where((s) => s.gpa4 >= 3.6).length;
  int get warningStudents => _students.where((s) => s.gpa4 < 2.0).length;

  Future<void> refreshStudents() async {
    await loadData();
  }
}
