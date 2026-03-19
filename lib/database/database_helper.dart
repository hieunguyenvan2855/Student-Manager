import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('student_manager_v6.db'); // Nâng cấp lên v6 để nạp 50 SV
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
    await db.execute('CREATE TABLE students (id TEXT PRIMARY KEY, mssv TEXT, name TEXT, classId TEXT, hometown TEXT, avatarUrl TEXT, phoneNumber TEXT, email TEXT, birthday TEXT, status TEXT)');
    await db.execute('CREATE TABLE grades (id INTEGER PRIMARY KEY AUTOINCREMENT, studentId TEXT, subjectId TEXT, score REAL, credits INTEGER)');

    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    // 1. Departments
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
      {'id': 'c4', 'name': 'TCNH K22B', 'majorId': 'm4'},
      {'id': 'c5', 'name': 'NNA K20C', 'majorId': 'm5'},
      {'id': 'c6', 'name': 'NNJ K20D', 'majorId': 'm6'},
      {'id': 'c7', 'name': 'OTO K21E', 'majorId': 'm7'},
      {'id': 'c8', 'name': 'QTKS K22F', 'majorId': 'm8'},
      {'id': 'c9', 'name': 'DCN K21G', 'majorId': 'm9'},
      {'id': 'c10', 'name': 'TKDH K22H', 'majorId': 'm10'},
    ];
    for (var c in classes) await db.insert('classes', c);

    // 4. Students (Generate 50 students)
    final firstNames = ['Nguyễn', 'Trần', 'Lê', 'Phạm', 'Hoàng', 'Huỳnh', 'Phan', 'Vũ', 'Đặng', 'Bùi'];
    final midNames = ['Văn', 'Thị', 'Minh', 'Thanh', 'Hữu', 'Đức', 'Anh', 'Ngọc', 'Quang', 'Hồng'];
    final lastNames = ['An', 'Bình', 'Chi', 'Dũng', 'Em', 'Giang', 'Hương', 'Khánh', 'Linh', 'Nam', 'Oanh', 'Phúc', 'Quân', 'Sơn', 'Thảo', 'Tuấn', 'Vinh', 'Xuân', 'Yến', 'Khoa'];
    final hometowns = ['Hà Nội', 'Đà Nẵng', 'Hồ Chí Minh', 'Hải Phòng', 'Cần Thơ', 'Huế', 'Nam Định', 'Nghệ An', 'Thanh Hóa', 'Quảng Nam'];

    for (int i = 1; i <= 50; i++) {
      final f = firstNames[i % firstNames.length];
      final m = midNames[i % midNames.length];
      final l = lastNames[i % lastNames.length];
      final name = '$f $m $l';
      final mssv = 'SV${i.toString().padLeft(3, '0')}';
      final classId = 'c${(i % 10) + 1}';
      final hometown = hometowns[i % hometowns.length];
      
      await db.insert('students', {
        'id': i.toString(),
        'mssv': mssv,
        'name': name,
        'classId': classId,
        'hometown': hometown,
        'avatarUrl': 'https://i.pravatar.cc/150?u=$i',
        'phoneNumber': '0912${i.toString().padLeft(6, '0')}',
        'email': '${mssv.toLowerCase()}@student.edu.vn',
        'birthday': '${(i % 28) + 1}/0${(i % 12) + 1}/2003',
        'status': i % 15 == 0 ? 'graduated' : (i % 20 == 0 ? 'suspended' : 'studying'),
      });

      // 5. Grades (Mỗi SV 4 môn)
      final subjects = [
        {'id': 'Flutter', 'credits': 3},
        {'id': 'Cơ sở dữ liệu', 'credits': 2},
        {'id': 'Cấu trúc dữ liệu', 'credits': 4},
        {'id': 'Tiếng Anh', 'credits': 3},
        {'id': 'Marketing', 'credits': 2},
        {'id': 'Toán rời rạc', 'credits': 4}
      ];
      
      for (int j = 0; j < 4; j++) {
        final sub = subjects[(i + j) % subjects.length];
        await db.insert('grades', {
          'studentId': i.toString(),
          'subjectId': sub['id'],
          'score': (6.0 + (i + j) % 4.1).clamp(0, 10),
          'credits': sub['credits'],
        });
      }
    }
  }
}
