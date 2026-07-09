class DepartmentModel {
  final String id;
  final String code;
  final String name;
  final String faculty;
  final double minGPA;
  final int seats;
  final int tuitionPerSemester;
  final String duration;
  final String description;
  final List<String> careers;
  final List<String> requiredSubjects;
  final bool admissionTestRequired;

  const DepartmentModel({
    required this.id,
    required this.code,
    required this.name,
    required this.faculty,
    required this.minGPA,
    required this.seats,
    required this.tuitionPerSemester,
    required this.duration,
    required this.description,
    required this.careers,
    required this.requiredSubjects,
    required this.admissionTestRequired,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> j) => DepartmentModel(
    id: j['_id'] as String? ?? '',
    code: j['code'] as String? ?? '',
    name: j['name'] as String? ?? '',
    faculty: j['faculty'] as String? ?? '',
    minGPA: (j['minGPA'] as num?)?.toDouble() ?? 0.0,
    seats: (j['seats'] as num?)?.toInt() ?? 0,
    tuitionPerSemester: (j['tuitionPerSemester'] as num?)?.toInt() ?? 0,
    duration: j['duration'] as String? ?? '4 years',
    description: j['description'] as String? ?? '',
    careers: List<String>.from(j['careers'] as List? ?? []),
    requiredSubjects: List<String>.from(j['requiredSubjects'] as List? ?? []),
    admissionTestRequired: j['admissionTestRequired'] as bool? ?? true,
  );
}
