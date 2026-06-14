/// [App Location] Data layer model -> Transaction feature module.
/// [Core Function] Pure data representation for CRUD pipelines. Free from UI library dependencies.
class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final bool isExpense;

  // ✓ CLEAN DATA: Save hex strings or code points instead of raw UI objects
  final String? categoryIconCode;
  final String? categoryColorHex;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.isExpense,
    this.categoryIconCode,
    this.categoryColorHex,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String,
      isExpense: json['isExpense'] as bool,
      categoryIconCode: json['categoryIconCode'] as String?,
      categoryColorHex: json['categoryColorHex'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'isExpense': isExpense,
      'categoryIconCode': categoryIconCode,
      'categoryColorHex': categoryColorHex,
    };
  }
}
