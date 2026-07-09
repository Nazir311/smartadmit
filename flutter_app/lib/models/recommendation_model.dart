class RoadmapModel {
  final List<String> year1;
  final List<String> year2;
  final List<String> year3;
  final List<String> year4;

  const RoadmapModel({required this.year1, required this.year2, required this.year3, required this.year4});

  factory RoadmapModel.fromJson(Map<String, dynamic> j) => RoadmapModel(
    year1: List<String>.from(j['year1'] as List? ?? []),
    year2: List<String>.from(j['year2'] as List? ?? []),
    year3: List<String>.from(j['year3'] as List? ?? []),
    year4: List<String>.from(j['year4'] as List? ?? []),
  );
}

class DepartmentScoreModel {
  final String code;
  final String name;
  final int confidenceScore;
  final int academicAlignment;
  final int interestAlignment;
  final int careerAlignment;
  final int practicalFit;
  final List<String> reasoning;
  final RoadmapModel careerRoadmap;
  final List<String> jobRoles;
  final List<String> industryPaths;
  final int tuitionPerSemester;
  final String scholarshipChance;

  const DepartmentScoreModel({
    required this.code,
    required this.name,
    required this.confidenceScore,
    required this.academicAlignment,
    required this.interestAlignment,
    required this.careerAlignment,
    required this.practicalFit,
    required this.reasoning,
    required this.careerRoadmap,
    required this.jobRoles,
    required this.industryPaths,
    required this.tuitionPerSemester,
    required this.scholarshipChance,
  });

  factory DepartmentScoreModel.fromJson(Map<String, dynamic> j) => DepartmentScoreModel(
    code: j['code'] as String? ?? '',
    name: j['name'] as String? ?? '',
    confidenceScore: (j['confidenceScore'] as num?)?.toInt() ?? 0,
    academicAlignment: (j['academicAlignment'] as num?)?.toInt() ?? 0,
    interestAlignment: (j['interestAlignment'] as num?)?.toInt() ?? 0,
    careerAlignment: (j['careerAlignment'] as num?)?.toInt() ?? 0,
    practicalFit: (j['practicalFit'] as num?)?.toInt() ?? 0,
    reasoning: List<String>.from(j['reasoning'] as List? ?? []),
    careerRoadmap: RoadmapModel.fromJson(j['careerRoadmap'] as Map<String, dynamic>? ?? {}),
    jobRoles: List<String>.from(j['jobRoles'] as List? ?? []),
    industryPaths: List<String>.from(j['industryPaths'] as List? ?? []),
    tuitionPerSemester: (j['tuitionPerSemester'] as num?)?.toInt() ?? 0,
    scholarshipChance: j['scholarshipChance'] as String? ?? '',
  );
}

class RecommendationModel {
  final String sessionId;
  final List<DepartmentScoreModel> topDepartments;
  final String parentSummaryEn;
  final String parentSummaryBn;
  final DateTime generatedAt;

  const RecommendationModel({
    required this.sessionId,
    required this.topDepartments,
    required this.parentSummaryEn,
    required this.parentSummaryBn,
    required this.generatedAt,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> j) => RecommendationModel(
    sessionId: j['sessionId'] as String? ?? '',
    topDepartments: (j['topDepartments'] as List? ?? [])
        .map((d) => DepartmentScoreModel.fromJson(d as Map<String, dynamic>))
        .toList(),
    parentSummaryEn: j['parentSummaryEn'] as String? ?? '',
    parentSummaryBn: j['parentSummaryBn'] as String? ?? '',
    generatedAt: DateTime.tryParse(j['generatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}
