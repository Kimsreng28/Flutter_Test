import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';

class ApiService {
  final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000/api/products';

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      print('Decoded response: $decoded');

      if (decoded is Map && decoded.containsKey('recordset')) {
        final productList = decoded['recordset'] as List;
        return productList
            .map((item) => Product.fromJson({
                  'productId': item['PRODUCTID'],
                  'productName': item['PRODUCTNAME'],
                  'price': item['PRICE'],
                  'stock': item['STOCK'],
                }))
            .toList();
      } else {
        throw Exception("Unexpected API format: $decoded");
      }
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  Future<Product> fetchProduct(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load product');
    }
  }

  Future<Product> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'productName': product.productName,
        'price': product.price,
        'stock': product.stock,
      }),
    );

    if (response.statusCode == 201) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create product');
    }
  }

  Future<Product> updateProduct(Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${product.productId}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'productName': product.productName,
        'price': product.price,
        'stock': product.stock,
      }),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update product');
    }
  }

  Future<void> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete product');
    }
  }
}
