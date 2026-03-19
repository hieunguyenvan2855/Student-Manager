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

  // GPA 4.0 theo công thức có tính tín chỉ
  double get gpa4 {
    if (grades.isEmpty) return 0.0;
    double totalWeighted = grades.fold(
      0.0,
      (sum, item) => sum + item.weightedScore,
    );
    int totalCredits = grades.fold(0, (sum, item) => sum + item.credits);
    if (totalCredits == 0) return 0.0;
    double result = totalWeighted / totalCredits;
    return double.parse(result.toStringAsFixed(2));
  }

  // GPA 10 dựa trên average score
  double get gpa10Weighted {
    if (grades.isEmpty) return 0.0;
    double totalScore = grades.fold(
      0.0,
      (sum, item) => sum + (item.score * item.credits),
    );
    int totalCredits = grades.fold(0, (sum, item) => sum + item.credits);
    if (totalCredits == 0) return 0.0;
    double result = totalScore / totalCredits;
    return double.parse(result.toStringAsFixed(2));
  }

  String get classification {
    double g4 = gpa4;
    if (g4 >= 3.6) return 'Xuất sắc';
    if (g4 >= 3.2) return 'Giỏi';
    if (g4 >= 2.5) return 'Khá';
    if (g4 >= 2.0) return 'Trung bình';
    return 'Yếu/Kém';
  }

  // Lấy điểm theo kì học
  Map<String, List<Grade>> get gradesBysemester {
    Map<String, List<Grade>> result = {};
    for (var grade in grades) {
      if (!result.containsKey(grade.semester)) {
        result[grade.semester] = [];
      }
      result[grade.semester]!.add(grade);
    }
    return result;
  }

  // GPA theo từng kì
  Map<String, double> get gpaBySemester {
    Map<String, double> result = {};
    gradesBysemester.forEach((semester, gradesList) {
      if (gradesList.isEmpty) {
        result[semester] = 0.0;
      } else {
        double totalWeighted = gradesList.fold(
          0.0,
          (sum, item) => sum + item.weightedScore,
        );
        int totalCredits = gradesList.fold(
          0,
          (sum, item) => sum + item.credits,
        );
        double gpa = totalCredits == 0 ? 0.0 : totalWeighted / totalCredits;
        result[semester] = double.parse(gpa.toStringAsFixed(2));
      }
    });
    return result;
  }
}
