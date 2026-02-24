import 'package:flutter/material.dart';

class CategoryIcons {
  static IconData getIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_bag;
      case 'healthcare':
        return Icons.local_hospital;
      case 'travel':
        return Icons.flight;
      case 'other':
        return Icons.more_horiz;
      default:
        return Icons.attach_money;
    }
  }

  static Color getColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'shopping':
        return Colors.pink;
      case 'healthcare':
        return Colors.red;
      case 'travel':
        return Colors.blue;
      case 'other':
        return Colors.grey;
      default:
        return Colors.purple;
    }
  }

  static List<String> get categories => [
        'Food',
        'Shopping',
        'Healthcare',
        'Travel',
        'Other',
      ];
}
