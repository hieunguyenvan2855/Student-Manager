import 'academic_models.dart';

enum StudentStatus { studying, graduated, suspended }

class Student {
  final String id;
  final String mssv;
  final String name;
  final String classId;
  final String hometown;
  final String avatarUrl;
  final String phoneNumber;
  final List<Grade> grades;
  final StudentStatus status;

  Student({
    required this.id,
    required this.mssv,
    required this.name,
    required this.classId,
    required this.hometown,
    required this.avatarUrl,
    required this.phoneNumber,
    required this.grades,
    required this.status,
  });

  factory Student.fromMap(Map<String, dynamic> map, List<Grade> grades) {
    return Student(
      id: map['id'],
      mssv: map['mssv'],
      name: map['name'],
      classId: map['classId'],
      hometown: map['hometown'],
      avatarUrl: map['avatarUrl'],
      phoneNumber: map['phoneNumber'],
      status: StudentStatus.values.firstWhere(
        (e) => e.toString() == 'StudentStatus.${map['status']}',
        orElse: () => StudentStatus.studying,
      ),
      grades: grades,
    );
  }

  double get gpa10 {
    if (grades.isEmpty) return 0.0;
    double total = grades.fold(0, (sum, item) => sum + item.score);
    return double.parse((total / grades.length).toStringAsFixed(2));
  }

  double get gpa4 {
    double g10 = gpa10;
    if (g10 >= 8.5) return 4.0;
    if (g10 >= 8.0) return 3.5;
    if (g10 >= 7.0) return 3.0;
    if (g10 >= 6.5) return 2.5;
    if (g10 >= 5.5) return 2.0;
    if (g10 >= 5.0) return 1.5;
    if (g10 >= 4.0) return 1.0;
    return 0.0;
  }

  String get classification {
    double g4 = gpa4;
    if (g4 >= 3.6) return 'Xuất sắc';
    if (g4 >= 3.2) return 'Giỏi';
    if (g4 >= 2.5) return 'Khá';
    if (g4 >= 2.0) return 'Trung bình';
    return 'Yếu/Kém';
  }
}
