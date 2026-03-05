import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final Color color;
  final String imageAsset;
  bool selected;
  int quantity;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.color,
    required this.imageAsset,
    this.selected = false,
    this.quantity = 1,
  });
}
