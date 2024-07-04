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

    if(list.isNotEmpty) tempDate = DateTime.parse(list[0].transactionDate!);

    for(int index = 0; index < list.length; index ++) {
      num tempAmount = num.tryParse(list[index].amount ?? "") ?? 0;
      if(index == (list.length - 1) && (tempDate == DateTime.parse(list[index].transactionDate!))) {
        total += tempAmount;
        items?.add(list[index]);

        historyList.add(HistoryModel(
            date: tempDate.toString(),
            total: total.toString(),
            items: items
        ));

        total = 0;
        items = [];
      } else if (tempDate == DateTime.parse(list[index].transactionDate!)) {
        total += tempAmount;
        items?.add(list[index]);
      } else {

        historyList.add(HistoryModel(
          date: tempDate.toString(),
          total: total.toString(),
          items: items
        ));

        tempDate = DateTime.parse(list[index].transactionDate!);
        total = 0;
        items = [];
        total = tempAmount;
        items?.add(list[index]);
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