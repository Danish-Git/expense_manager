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
    if (list.isEmpty) return historyList;

    DateTime? tempDate = DateTime.parse(list[0].transactionDate!);
    num total = 0;
    List<ExpenseModel> items = [];

    for (int index = 0; index < list.length; index++) {
      ExpenseModel expense = list[index];
      num tempAmount = num.tryParse(expense.amount ?? "") ?? 0;
      DateTime currentDate = DateTime.parse(expense.transactionDate!);

      if (tempDate == currentDate) {
        total += tempAmount;
        items.add(expense);
      }

      if (tempDate != currentDate || index == list.length - 1) {
        if (tempDate != currentDate) {
          historyList.add(HistoryModel(
            date: tempDate.toString(),
            total: total.toString(),
            items: List.from(items),
          ));
          tempDate = currentDate;
          total = tempAmount;
          items = [expense];

          if(index == list.length - 1){
            historyList.add(HistoryModel(
              date: tempDate.toString(),
              total: total.toString(),
              items: List.from(items),
            ));
          }
        } else {
          historyList.add(HistoryModel(
            date: tempDate.toString(),
            total: total.toString(),
            items: List.from(items),
          ));
        }
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