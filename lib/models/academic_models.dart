class Department {
  final String id;
  final String name;
  final String icon;

  Department({required this.id, required this.name, required this.icon});

  factory Department.fromMap(Map<String, dynamic> map) {
    return Department(id: map['id'], name: map['name'], icon: map['icon']);
  }
}

class Major {
  final String id;
  final String name;
  final String departmentId;

  Major({required this.id, required this.name, required this.departmentId});

  factory Major.fromMap(Map<String, dynamic> map) {
    return Major(
      id: map['id'],
      name: map['name'],
      departmentId: map['departmentId'],
    );
  }
}

class ClassInfo {
  final String id;
  final String name;
  final String majorId;

  ClassInfo({required this.id, required this.name, required this.majorId});

  factory ClassInfo.fromMap(Map<String, dynamic> map) {
    return ClassInfo(id: map['id'], name: map['name'], majorId: map['majorId']);
  }
}

class Subject {
  final String id;
  final String name;
  final int credits;

  Subject({required this.id, required this.name, required this.credits});
}

class Grade {
  final String subjectId;
  final String subjectName;
  final double score;
  final int credits;
  final String semester;

  Grade({
    required this.subjectId,
    required this.subjectName,
    required this.score,
    required this.credits,
    required this.semester,
  });

  factory Grade.fromMap(Map<String, dynamic> map) {
    return Grade(
      subjectId: map['subjectId'],
      subjectName: map['subjectName'] ?? '',
      score: map['score'],
      credits: map['credits'] ?? 3,
      semester: map['semester'] ?? '1',
    );
  }

  // Chuyển điểm 10 sang 4
  double get scoreIn4 {
    if (score >= 8.5) return 4.0;
    if (score >= 8.0) return 3.5;
    if (score >= 7.0) return 3.0;
    if (score >= 6.5) return 2.5;
    if (score >= 5.5) return 2.0;
    if (score >= 5.0) return 1.5;
    if (score >= 4.0) return 1.0;
    return 0.0;
  }

  // Tính điểm theo tín chỉ
  double get weightedScore => scoreIn4 * credits;
}
