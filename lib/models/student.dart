import 'academic_models.dart';

enum StudentStatus { pending, studying, graduated, suspended, deleted }

class Student {
  final String id;
  final String mssv;
  final String name;
  final String classId;
  final String hometown;
  final String avatarUrl;
  final String phoneNumber;
  final String email;
  final String birthday;
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
    required this.email,
    required this.birthday,
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
      email: map['email'] ?? '',
      birthday: map['birthday'] ?? '01/01/2000',
      status: (() {
        final s = map['status']?.toString() ?? '';
        switch (s) {
          case 'pending':
            return StudentStatus.pending;
          case 'studying':
            return StudentStatus.studying;
          case 'graduated':
            return StudentStatus.graduated;
          case 'suspended':
            return StudentStatus.suspended;
          case 'deleted':
            return StudentStatus.deleted;
          default:
            return StudentStatus.studying;
        }
      }()),
      grades: grades,
    );
  }

  Map<String, dynamic> toMap() {
    // Map fields that match the database schema
    return {
      'id': id,
      'mssv': mssv,
      'name': name,
      'classId': classId,
      'hometown': hometown,
      'avatarUrl': avatarUrl,
      'phoneNumber': phoneNumber,
      'status': status.toString().split('.').last,
    };
  }

  double get gpa10 {
    if (grades.isEmpty) return 0.0;
    double totalWeightedScore = grades.fold(
      0,
      (sum, item) => sum + (item.score * item.credits),
    );
    int totalCredits = grades.fold(0, (sum, item) => sum + item.credits);
    if (totalCredits == 0) return 0.0;
    return double.parse((totalWeightedScore / totalCredits).toStringAsFixed(2));
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
    return 'Yêu/Kém';
  }

  Student copyWith({
    String? name,
    String? mssv,
    String? phoneNumber,
    String? email,
    String? hometown,
    String? birthday,
    List<Grade>? grades,
  }) {
    return Student(
      id: id,
      mssv: mssv ?? this.mssv,
      name: name ?? this.name,
      classId: classId,
      hometown: hometown ?? this.hometown,
      avatarUrl: avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      birthday: birthday ?? this.birthday,
      grades: grades ?? this.grades,
      status: status,
    );
  }
}
