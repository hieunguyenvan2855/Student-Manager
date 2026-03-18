class Department {
  final String id;
  final String name;
  final String icon;

  Department({required this.id, required this.name, required this.icon});

  factory Department.fromMap(Map<String, dynamic> map) {
    return Department(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
    );
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
    return ClassInfo(
      id: map['id'],
      name: map['name'],
      majorId: map['majorId'],
    );
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
  final double score;

  Grade({required this.subjectId, required this.score});

  factory Grade.fromMap(Map<String, dynamic> map) {
    return Grade(
      subjectId: map['subjectId'],
      score: map['score'],
    );
  }
}
