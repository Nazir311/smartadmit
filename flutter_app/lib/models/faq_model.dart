class FAQModel {
  final String id;
  final String question;
  final String answer;
  final String category;
  final int views;

  const FAQModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.views,
  });

  factory FAQModel.fromJson(Map<String, dynamic> j) => FAQModel(
    id: j['_id'] as String? ?? '',
    question: j['question'] as String? ?? '',
    answer: j['answer'] as String? ?? '',
    category: j['category'] as String? ?? 'general',
    views: (j['views'] as num?)?.toInt() ?? 0,
  );
}
