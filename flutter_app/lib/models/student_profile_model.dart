class StudentProfileModel {
  final String sessionId;
  final String? name;
  final double? sscGpa;
  final double? hscGpa;
  final String? group;
  final List<String> favoriteSubjects;
  final List<String> skills;
  final List<String> interests;
  final List<String> careerGoals;
  final String? financialConstraint;
  final bool? scholarshipInterest;
  final bool profileComplete;
  final String completionStage;

  const StudentProfileModel({
    required this.sessionId,
    this.name,
    this.sscGpa,
    this.hscGpa,
    this.group,
    required this.favoriteSubjects,
    required this.skills,
    required this.interests,
    required this.careerGoals,
    this.financialConstraint,
    this.scholarshipInterest,
    required this.profileComplete,
    required this.completionStage,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> j) => StudentProfileModel(
    sessionId: j['sessionId'] as String? ?? '',
    name: j['name'] as String?,
    sscGpa: (j['sscGpa'] as num?)?.toDouble(),
    hscGpa: (j['hscGpa'] as num?)?.toDouble(),
    group: j['group'] as String?,
    favoriteSubjects: List<String>.from(j['favoriteSubjects'] as List? ?? []),
    skills: List<String>.from(j['skills'] as List? ?? []),
    interests: List<String>.from(j['interests'] as List? ?? []),
    careerGoals: List<String>.from(j['careerGoals'] as List? ?? []),
    financialConstraint: j['financialConstraint'] as String?,
    scholarshipInterest: j['scholarshipInterest'] as bool?,
    profileComplete: j['profileComplete'] as bool? ?? false,
    completionStage: j['completionStage'] as String? ?? 'greeting',
  );

  double get effectiveGpa {
    if (sscGpa == null || hscGpa == null) return 0;
    return sscGpa! < hscGpa! ? sscGpa! : hscGpa!;
  }
}
