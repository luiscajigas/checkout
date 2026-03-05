import 'package:flutter/material.dart';
import 'package:shop_app/db/database_helper.dart';
import 'package:shop_app/screens/products_screen.dart';
import 'package:shop_app/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const ProductsScreen(),
    );
  }
}
