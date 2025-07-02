import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/providers/product_provider.dart';
import 'package:frontend/screens/add_product_screen.dart';
import 'package:frontend/screens/edit_product_screen.dart';
import 'package:frontend/screens/product_list_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProductProvider()..fetchProducts(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Product CRUD App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return _createRoute(const ProductListScreen());
            case '/add':
              return _createRoute(const AddProductScreen());
            case '/edit':
              final product = settings.arguments as Product;
              return _createRoute(EditProductScreen(product: product));
            default:
              return null;
          }
        },
      ),
    );
  }
}
