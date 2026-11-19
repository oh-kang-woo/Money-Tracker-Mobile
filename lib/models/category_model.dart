import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryModel {
  final String? id;
  final String userId;
  final String name;
  final String type; // 'expense' atau 'income'
  final String iconKey;

  CategoryModel({
    this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.iconKey = 'label',
  });

  static const Map<String, IconData> iconOptions = {
    'coffee': Icons.local_cafe,
    'game': Icons.sports_esports,
    'book': Icons.menu_book,
    'health': Icons.medical_services,
    'pet': Icons.pets,
    'travel': Icons.flight_takeoff,
    'gift': Icons.redeem,
    'work': Icons.work_outline,
    'home': Icons.home_work_outlined,
    'sport': Icons.fitness_center,
    'tech': Icons.devices,
    'label': Icons.label_important_outline,
  };

  static IconData getIconByKey(String key) {
    return iconOptions[key] ?? Icons.label_important_outline;
  }

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      type: data['type'] ?? 'expense',
      iconKey: data['iconKey'] ?? 'label',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'type': type,
      'iconKey': iconKey,
    };
  }
}