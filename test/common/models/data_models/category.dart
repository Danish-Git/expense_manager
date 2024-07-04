import 'package:expense_manager/common/models/data_models/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CategoryModel categoryModel = CategoryModel();

  group("CategoryModel@getIconData, Should provide correct icon data", () {
    test('Should provide correct icon for known icon names', () {
      expect(categoryModel.getIconData("transport"), equals(Icons.directions_bus_outlined));
      expect(categoryModel.getIconData("grocery"), equals(Icons.local_grocery_store_outlined));
      expect(categoryModel.getIconData("pleasure"), equals(Icons.movie_creation_outlined));
      expect(categoryModel.getIconData("eating_out"), equals(Icons.fastfood_outlined));
      expect(categoryModel.getIconData("shopping"), equals(Icons.shopping_bag_outlined));
      expect(categoryModel.getIconData("drinks"), equals(Icons.emoji_food_beverage_outlined));
      expect(categoryModel.getIconData("health"), equals(Icons.health_and_safety_outlined));
      expect(categoryModel.getIconData("leisure"), equals(Icons.hotel_class_outlined));
    });

    test('Should provide default icon for unknown icon name', () {
      expect(categoryModel.getIconData("unknown"), equals(Icons.category_outlined));
      expect(categoryModel.getIconData(null), equals(Icons.category_outlined));
    });
  });

  group("CategoryModel@getIcon, Should provide correct icon name", () {
    test('Should provide correct icon name for known icons', () {
      expect(categoryModel.getIcon(Icons.directions_bus_outlined), equals("transport"));
      expect(categoryModel.getIcon(Icons.local_grocery_store_outlined), equals("grocery"));
      expect(categoryModel.getIcon(Icons.movie_creation_outlined), equals("pleasure"));
      expect(categoryModel.getIcon(Icons.fastfood_outlined), equals("eating_out"));
      expect(categoryModel.getIcon(Icons.shopping_bag_outlined), equals("shopping"));
      expect(categoryModel.getIcon(Icons.emoji_food_beverage_outlined), equals("drinks"));
      expect(categoryModel.getIcon(Icons.health_and_safety_outlined), equals("health"));
      expect(categoryModel.getIcon(Icons.hotel_class_outlined), equals("leisure"));
    });

    test('Should provide default icon name for unknown icons', () {
      expect(categoryModel.getIcon(null), equals("other"));
      expect(categoryModel.getIcon(Icons.category_outlined), equals("other"));
      expect(categoryModel.getIcon(Icons.access_alarm_outlined), equals("other"));
    });
  });


}