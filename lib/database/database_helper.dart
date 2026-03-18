import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('student_manager_v4.db'); // Đổi sang v4 để nạp bộ dữ liệu khổng lồ
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

    // 2. Majors (Mỗi khoa 1-2 ngành tiêu biểu)
    final majors = [
      {'id': 'm1', 'name': 'Kỹ thuật phần mềm', 'departmentId': 'd1'},
      {'id': 'm2', 'name': 'An toàn thông tin', 'departmentId': 'd1'},
      {'id': 'm3', 'name': 'Quản trị kinh doanh', 'departmentId': 'd2'},
      {'id': 'm4', 'name': 'Tài chính ngân hàng', 'departmentId': 'd2'},
      {'id': 'm5', 'name': 'Ngôn ngữ Anh', 'departmentId': 'd3'},
      {'id': 'm6', 'name': 'Ngôn ngữ Nhật', 'departmentId': 'd3'},
      {'id': 'm7', 'name': 'Công nghệ ô tô', 'departmentId': 'd4'},
      {'id': 'm8', 'name': 'Quản trị khách sạn', 'departmentId': 'd5'},
      {'id': 'm9', 'name': 'Điện công nghiệp', 'departmentId': 'd6'},
      {'id': 'm10', 'name': 'Thiết kế đồ họa', 'departmentId': 'd7'},
    ];
    for (var m in majors) await db.insert('majors', m);

    // 3. Classes
    final classes = [
      {'id': 'c1', 'name': 'PM K21A', 'majorId': 'm1'},
      {'id': 'c2', 'name': 'ATTT K21B', 'majorId': 'm2'},
      {'id': 'c3', 'name': 'QTKD K22A', 'majorId': 'm3'},
      {'id': 'c4', 'name': 'NNA K20C', 'majorId': 'm5'},
      {'id': 'c5', 'name': 'OTO K21D', 'majorId': 'm7'},
      {'id': 'c6', 'name': 'TKDH K22E', 'majorId': 'm10'},
    ];
    for (var c in classes) await db.insert('classes', c);

    // 4. Students (25 Sinh viên mẫu trải dài các khoa)
    final students = [
      {'id': '1', 'mssv': 'SV001', 'name': 'Nguyễn Văn Hiếu', 'classId': 'c1', 'hometown': 'Hà Nội', 'avatarUrl': 'https://i.pravatar.cc/150?u=1', 'phoneNumber': '0912000001', 'status': 'studying'},
      {'id': '2', 'mssv': 'SV002', 'name': 'Lê Thị Mai', 'classId': 'c1', 'hometown': 'Đà Nẵng', 'avatarUrl': 'https://i.pravatar.cc/150?u=2', 'phoneNumber': '0912000002', 'status': 'studying'},
      {'id': '3', 'mssv': 'SV003', 'name': 'Trần Minh Quân', 'classId': 'c1', 'hometown': 'HCM', 'avatarUrl': 'https://i.pravatar.cc/150?u=3', 'phoneNumber': '0912000003', 'status': 'studying'},
      {'id': '4', 'mssv': 'SV004', 'name': 'Phạm Hoàng Long', 'classId': 'c2', 'hometown': 'Hải Phòng', 'avatarUrl': 'https://i.pravatar.cc/150?u=4', 'phoneNumber': '0912000004', 'status': 'studying'},
      {'id': '5', 'mssv': 'SV005', 'name': 'Vũ Thanh Thảo', 'classId': 'c2', 'hometown': 'Cần Thơ', 'avatarUrl': 'https://i.pravatar.cc/150?u=5', 'phoneNumber': '0912000005', 'status': 'studying'},
      {'id': '6', 'mssv': 'SV006', 'name': 'Đặng Minh Khôi', 'classId': 'c3', 'hometown': 'Huế', 'avatarUrl': 'https://i.pravatar.cc/150?u=6', 'phoneNumber': '0912000006', 'status': 'studying'},
      {'id': '7', 'mssv': 'SV007', 'name': 'Bùi Tuyết Nhi', 'classId': 'c3', 'hometown': 'Vũng Tàu', 'avatarUrl': 'https://i.pravatar.cc/150?u=7', 'phoneNumber': '0912000007', 'status': 'studying'},
      {'id': '8', 'mssv': 'SV008', 'name': 'Hoàng Anh Tuấn', 'classId': 'c3', 'hometown': 'Nam Định', 'avatarUrl': 'https://i.pravatar.cc/150?u=8', 'phoneNumber': '0912000008', 'status': 'graduated'},
      {'id': '9', 'mssv': 'SV009', 'name': 'Trịnh Công Sơn', 'classId': 'c4', 'hometown': 'Thanh Hóa', 'avatarUrl': 'https://i.pravatar.cc/150?u=9', 'phoneNumber': '0912000009', 'status': 'studying'},
      {'id': '10', 'mssv': 'SV010', 'name': 'Ngô Bảo Châu', 'classId': 'c4', 'hometown': 'Hà Nội', 'avatarUrl': 'https://i.pravatar.cc/150?u=10', 'phoneNumber': '0912000010', 'status': 'studying'},
      {'id': '11', 'mssv': 'SV011', 'name': 'Lý Thái Tổ', 'classId': 'c4', 'hometown': 'Bắc Ninh', 'avatarUrl': 'https://i.pravatar.cc/150?u=11', 'phoneNumber': '0912000011', 'status': 'studying'},
      {'id': '12', 'mssv': 'SV012', 'name': 'Võ Thị Sáu', 'classId': 'c5', 'hometown': 'Bà Rịa', 'avatarUrl': 'https://i.pravatar.cc/150?u=12', 'phoneNumber': '0912000012', 'status': 'studying'},
      {'id': '13', 'mssv': 'SV013', 'name': 'Nguyễn Huệ', 'classId': 'c5', 'hometown': 'Bình Định', 'avatarUrl': 'https://i.pravatar.cc/150?u=13', 'phoneNumber': '0912000013', 'status': 'studying'},
      {'id': '14', 'mssv': 'SV014', 'name': 'Trần Hưng Đạo', 'classId': 'c5', 'hometown': 'Nam Định', 'avatarUrl': 'https://i.pravatar.cc/150?u=14', 'phoneNumber': '0912000014', 'status': 'studying'},
      {'id': '15', 'mssv': 'SV015', 'name': 'Lê Lợi', 'classId': 'c6', 'hometown': 'Thanh Hóa', 'avatarUrl': 'https://i.pravatar.cc/150?u=15', 'phoneNumber': '0912000015', 'status': 'studying'},
      {'id': '16', 'mssv': 'SV016', 'name': 'Nguyễn Trãi', 'classId': 'c6', 'hometown': 'Hải Dương', 'avatarUrl': 'https://i.pravatar.cc/150?u=16', 'phoneNumber': '0912000016', 'status': 'studying'},
      {'id': '17', 'mssv': 'SV017', 'name': 'Phan Bội Châu', 'classId': 'c6', 'hometown': 'Nghệ An', 'avatarUrl': 'https://i.pravatar.cc/150?u=17', 'phoneNumber': '0912000017', 'status': 'studying'},
      {'id': '18', 'mssv': 'SV018', 'name': 'Chu Văn An', 'classId': 'c1', 'hometown': 'Hà Nội', 'avatarUrl': 'https://i.pravatar.cc/150?u=18', 'phoneNumber': '0912000018', 'status': 'studying'},
      {'id': '19', 'mssv': 'SV019', 'name': 'Hồ Xuân Hương', 'classId': 'c2', 'hometown': 'Nghệ An', 'avatarUrl': 'https://i.pravatar.cc/150?u=19', 'phoneNumber': '0912000019', 'status': 'studying'},
      {'id': '20', 'mssv': 'SV020', 'name': 'Bà Huyện Thanh Quan', 'classId': 'c3', 'hometown': 'Hà Nội', 'avatarUrl': 'https://i.pravatar.cc/150?u=20', 'phoneNumber': '0912000020', 'status': 'studying'},
    ];
    for (var s in students) await db.insert('students', s);

    // 5. Grades (Mỗi SV 2-3 môn điểm ngẫu nhiên để test thống kê)
    final subjects = ['Flutter', 'SQL', 'Toán', 'Lý', 'Marketing', 'English'];
    for (var sId = 1; sId <= 20; sId++) {
      await db.insert('grades', {'studentId': sId.toString(), 'subjectId': subjects[0], 'score': 7.0 + (sId % 4)});
      await db.insert('grades', {'studentId': sId.toString(), 'subjectId': subjects[1], 'score': 6.0 + (sId % 5)});
    }
  }
}
