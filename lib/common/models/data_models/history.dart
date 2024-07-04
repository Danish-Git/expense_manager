import 'expense.dart';

class HistoryModel {
  /*
  {
    "date": "date",
    "total": "total",
    "items": [
       {
        "id": 5,
        "amount": "2",
        "description": "description",
        "transaction_date": "transaction_date",
        "category_id": "category_id",
        "created_at": "created_at",
        "updated_at": "updated_at"
      }
    ]
  }
  */

  String? date;
  String? total;
  List<ExpenseModel?>? items;

  HistoryModel({
    this.date,
    this.total,
    this.items,
  });

  HistoryModel.fromJson(Map<String, dynamic> json) {
    date = json['date']?.toString();
    total = json['total']?.toString();
    if (json['items'] != null && (json['items'] is List)) {
      items = [];
      json['items'].forEach((element) {
        items?.add(ExpenseModel.fromJson(element));
      });
    }
  }

  List<HistoryModel> fromExpenseList(List<ExpenseModel> list) {

    List<HistoryModel> historyList = [];
    DateTime? tempDate;
    num total = 0;
    items = [];

    for(int index = 0; index < list.length; index ++) {

      if(index == 0) {
        tempDate = DateTime.parse(list[index].transactionDate!);
      }

      total += num.parse(list[index].amount ?? "");
      items?.add(list[index]);

      if (tempDate != DateTime.parse(list[index].transactionDate!) && index > 0) {

        historyList.add(HistoryModel(
          date: tempDate.toString(),
          total: total.toString(),
          items: items
        ));

        tempDate = DateTime.parse(list[index].transactionDate!);
        total = 0;
        items = [];
      }
    }
    return historyList;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['total'] = total;
    if (items != null) {
      data['items'] = [];
      for (var element in items!) {
        data['items'].add(element!.toJson());
      }
    }
    return data;
  }
}