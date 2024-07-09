
import 'category.dart';

class ExpenseModel {

  int? id;
  String? amount;
  String? description;
  String? transactionDate;
  String? categoryId;
  CategoryModel? category;
  String? createdAt;
  String? updatedAt;

  ExpenseModel({
    this.id,
    this.amount,
    this.description,
    this.transactionDate,
    this.categoryId,
    this.createdAt,
    this.updatedAt,
  });

  ExpenseModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id']?.toString() ?? '');
    amount = json['amount']?.toString();
    description = json['description']?.toString();
    transactionDate = json['transaction_date']?.toString();
    categoryId = json['category_id']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['amount'] = amount;
    data['description'] = description;
    data['transaction_date'] = transactionDate;
    data['category_id'] = categoryId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}