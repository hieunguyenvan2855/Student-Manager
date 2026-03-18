import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('student_manager_v3.db'); // Đổi sang v3 để nạp lại dữ liệu cực nhiều
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('CREATE TABLE departments (id TEXT PRIMARY KEY, name TEXT, icon TEXT)');
    await db.execute('CREATE TABLE majors (id TEXT PRIMARY KEY, name TEXT, departmentId TEXT)');
    await db.execute('CREATE TABLE classes (id TEXT PRIMARY KEY, name TEXT, majorId TEXT)');
    await db.execute('CREATE TABLE students (id TEXT PRIMARY KEY, mssv TEXT, name TEXT, classId TEXT, hometown TEXT, avatarUrl TEXT, phoneNumber TEXT, status TEXT)');
    await db.execute('CREATE TABLE grades (id INTEGER PRIMARY KEY AUTOINCREMENT, studentId TEXT, subjectId TEXT, score REAL)');

    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    // 1. Departments (7 Khoa)
    final depts = [
      {'id': 'd1', 'name': 'CNTT', 'icon': 'laptop'},
      {'id': 'd2', 'name': 'Kinh tế', 'icon': 'chart-line'},
      {'id': 'd3', 'name': 'Ngôn ngữ', 'icon': 'language'},
      {'id': 'd4', 'name': 'Ô tô', 'icon': 'car'},
      {'id': 'd5', 'name': 'Du lịch', 'icon': 'hotel'},
      {'id': 'd6', 'name': 'Điện tử', 'icon': 'bolt'},
      {'id': 'd7', 'name': 'Đồ họa', 'icon': 'palette'},
    ];
    for (var d in depts) await db.insert('departments', d);

    // 2. Majors
    final majors = [
      {'id': 'm1', 'name': 'Kỹ thuật phần mềm', 'departmentId': 'd1'},
      {'id': 'm2', 'name': 'An toàn thông tin', 'departmentId': 'd1'},
      {'id': 'm3', 'name': 'Marketing', 'departmentId': 'd2'},
      {'id': 'm4', 'name': 'Tài chính', 'departmentId': 'd2'},
      {'id': 'm5', 'name': 'Quản trị khách sạn', 'departmentId': 'd5'},
      {'id': 'm6', 'name': 'Ngôn ngữ Anh', 'departmentId': 'd3'},
      {'id': 'm7', 'name': 'Cơ khí ô tô', 'departmentId': 'd4'},
      {'id': 'm8', 'name': 'Tự động hóa', 'departmentId': 'd6'},
      {'id': 'm9', 'name': 'Thiết kế đồ họa', 'departmentId': 'd7'},
    ];
    for (var m in majors) await db.insert('majors', m);

    // 3. Classes
    final classes = [
      {'id': 'c1', 'name': 'PM K21A', 'majorId': 'm1'},
      {'id': 'c2', 'name': 'ATTT K21B', 'majorId': 'm2'},
      {'id': 'c3', 'name': 'MK K22B', 'majorId': 'm3'},
      {'id': 'c4', 'name': 'TC K22A', 'majorId': 'm4'},
      {'id': 'c5', 'name': 'KS K20C', 'majorId': 'm5'},
      {'id': 'c6', 'name': 'NNA K21D', 'majorId': 'm6'},
    ];
    for (var c in classes) await db.insert('classes', c);

    // 4. Students (Thêm nhiều sinh viên ở nhiều khoa)
    final students = [
      {'id': '1', 'mssv': 'SV001', 'name': 'Nguyễn Văn Hiếu', 'classId': 'c1', 'hometown': 'Hà Nội', 'avatarUrl': 'https://i.pravatar.cc/150?u=1', 'phoneNumber': '091', 'status': 'studying'},
      {'id': '2', 'mssv': 'SV002', 'name': 'Lê Thị Mai', 'classId': 'c1', 'hometown': 'Đà Nẵng', 'avatarUrl': 'https://i.pravatar.cc/150?u=2', 'phoneNumber': '092', 'status': 'studying'},
      {'id': '3', 'mssv': 'SV003', 'name': 'Trần Minh Quân', 'classId': 'c2', 'hometown': 'HCM', 'avatarUrl': 'https://i.pravatar.cc/150?u=3', 'phoneNumber': '093', 'status': 'studying'},
      {'id': '4', 'mssv': 'SV004', 'name': 'Phạm Hoàng Long', 'classId': 'c2', 'hometown': 'Hải Phòng', 'avatarUrl': 'https://i.pravatar.cc/150?u=4', 'phoneNumber': '094', 'status': 'studying'},
      {'id': '5', 'mssv': 'SV005', 'name': 'Vũ Thanh Thảo', 'classId': 'c3', 'hometown': 'Cần Thơ', 'avatarUrl': 'https://i.pravatar.cc/150?u=5', 'phoneNumber': '095', 'status': 'studying'},
      {'id': '6', 'mssv': 'SV006', 'name': 'Đỗ Minh Khôi', 'classId': 'c3', 'hometown': 'Huế', 'avatarUrl': 'https://i.pravatar.cc/150?u=6', 'phoneNumber': '096', 'status': 'studying'},
      {'id': '7', 'mssv': 'SV007', 'name': 'Bùi Tuyết Nhi', 'classId': 'c4', 'hometown': 'Vũng Tàu', 'avatarUrl': 'https://i.pravatar.cc/150?u=7', 'phoneNumber': '097', 'status': 'studying'},
      {'id': '8', 'mssv': 'SV008', 'name': 'Hoàng Anh Tuấn', 'classId': 'c4', 'hometown': 'Nam Định', 'avatarUrl': 'https://i.pravatar.cc/150?u=8', 'phoneNumber': '098', 'status': 'graduated'},
      {'id': '9', 'mssv': 'SV009', 'name': 'Trịnh Công Sơn', 'classId': 'c5', 'hometown': 'Thanh Hóa', 'avatarUrl': 'https://i.pravatar.cc/150?u=9', 'phoneNumber': '099', 'status': 'studying'},
      {'id': '10', 'mssv': 'SV010', 'name': 'Ngô Bảo Châu', 'classId': 'c6', 'hometown': 'Hà Nội', 'avatarUrl': 'https://i.pravatar.cc/150?u=10', 'phoneNumber': '010', 'status': 'studying'},
      {'id': '11', 'mssv': 'SV011', 'name': 'Lý Thái Tổ', 'classId': 'c6', 'hometown': 'Bắc Ninh', 'avatarUrl': 'https://i.pravatar.cc/150?u=11', 'phoneNumber': '011', 'status': 'studying'},
      {'id': '12', 'mssv': 'SV012', 'name': 'Võ Thị Sáu', 'classId': 'c1', 'hometown': 'Bà Rịa', 'avatarUrl': 'https://i.pravatar.cc/150?u=12', 'phoneNumber': '012', 'status': 'suspended'},
    ];
    for (var s in students) await db.insert('students', s);

    // 5. Grades (Điểm cho từng SV)
    final grades = [
      {'studentId': '1', 'subjectId': 'Flutter', 'score': 9.5}, {'studentId': '1', 'subjectId': 'SQL', 'score': 8.5},
      {'studentId': '2', 'subjectId': 'Flutter', 'score': 7.0}, {'studentId': '2', 'subjectId': 'SQL', 'score': 7.5},
      {'studentId': '3', 'subjectId': 'Security', 'score': 9.0}, {'studentId': '3', 'subjectId': 'Network', 'score': 8.5},
      {'studentId': '4', 'subjectId': 'Security', 'score': 6.0}, {'studentId': '5', 'subjectId': 'Marketing', 'score': 8.5},
      {'studentId': '6', 'subjectId': 'Marketing', 'score': 4.5}, {'studentId': '7', 'subjectId': 'Finance', 'score': 9.2},
      {'studentId': '8', 'subjectId': 'Finance', 'score': 3.5}, {'studentId': '9', 'subjectId': 'Hotel', 'score': 8.8},
      {'studentId': '10', 'subjectId': 'English', 'score': 9.5}, {'studentId': '11', 'subjectId': 'English', 'score': 5.5},
      {'studentId': '12', 'subjectId': 'Flutter', 'score': 2.0},
    ];
    for (var g in grades) await db.insert('grades', g);
  }
}
