import 'package:flutter/material.dart';

class CategoryModel {

  int? id;
  String? name;
  IconData? icon;
  bool isSelected = false;

  CategoryModel({
    this.id,
    this.name,
    this.icon,
  });

  CategoryModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id']?.toString() ?? '');
    name = json['name']?.toString();
    icon = getIconData(json['icon']?.toString());
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['icon'] = getIcon(icon);
    return data;
  }

  IconData? getIconData(String? icon) {
    switch(icon) {
      case "transport":
        return Icons.directions_bus_outlined;
      case "grocery":
        return Icons.local_grocery_store_outlined;
      case "pleasure":
        return Icons.movie_creation_outlined;
      case "eating_out":
        return Icons.fastfood_outlined;
      case "shopping":
        return Icons.shopping_bag_outlined;
      case "drinks":
        return Icons.emoji_food_beverage_outlined;
      case "health":
        return Icons.health_and_safety_outlined;
      case "leisure":
        return Icons.hotel_class_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  String? getIcon(IconData? icon) {
    switch(icon) {
      case Icons.directions_bus_outlined:
        return "transport";
      case Icons.local_grocery_store_outlined:
        return "grocery";
      case Icons.movie_creation_outlined:
        return "pleasure";
      case Icons.fastfood_outlined:
        return "eating_out";
      case Icons.shopping_bag_outlined:
        return "shopping";
      case Icons.emoji_food_beverage_outlined:
        return "drinks";
      case Icons.health_and_safety_outlined:
        return "health";
      case Icons.hotel_class_outlined:
        return "leisure";
      default:
        return "other";
    }
  }

  List<Map<String, dynamic>> mockData = [
    {
      "id": 1,
      "name": "Transport",
      "icon": "transport"
    },
    {
      "id": 2,
      "name": "Grocery",
      "icon": "grocery"
    },
    {
      "id": 3,
      "name": "Pleasure",
      "icon": "pleasure"
    },
    {
      "id": 4,
      "name": "Eating Out",
      "icon": "eating_out"
    },
    {
      "id": 5,
      "name": "Shopping",
      "icon": "shopping"
    },
    {
      "id": 6,
      "name": "Drinks",
      "icon": "drinks"
    },
    {
      "id": 7,
      "name": "Health",
      "icon": "health"
    },
    {
      "id": 8,
      "name": "Leisure",
      "icon": "leisure"
    },
    {
      "id": 9,
      "name": "Other",
      "icon": "other"
    },
  ];
}