import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // List to hold products
  List<Product> _products = [];
  bool _isLoading = false;
  String _error = '';

  // Query to search products
  String _searchQuery = '';

  // List filtered products
  List<Product> get filteredProducts => _searchQuery.isEmpty
      ? _products
      : _products
          .where((product) => product.productName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();

  // Getter and setter for search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Default sort by name
  String _sortBy = 'name';
  bool _sortAscending = true;

  // Sort products by name
  void sortProducts(String field) {
    if (_sortBy == field) {
      _sortAscending = !_sortAscending;
    } else {
      _sortBy = field;
      _sortAscending = true;
    }

    _products.sort((a, b) {
      int result;
      switch (field) {
        case 'price':
          result = a.price.compareTo(b.price);
          break;
        case 'stock':
          result = a.stock.compareTo(b.stock);
          break;
        default: // name
          result = a.productName.compareTo(b.productName);
      }
      return _sortAscending ? result : -result;
    });

    notifyListeners();
  }

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Fetch products from the API
  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
      _products = await _apiService.fetchProducts();
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new product
  Future<void> addProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newProduct = await _apiService.createProduct(product);
      _products.add(newProduct);
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing product
  Future<void> updateProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedProduct = await _apiService.updateProduct(product);
      final index =
          _products.indexWhere((p) => p.productId == product.productId);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a product
  Future<void> deleteProduct(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.deleteProduct(id);
      _products.removeWhere((product) => product.productId == id);
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Function to Export to PDF
  Future<void> exportToPdf(BuildContext context) async {
    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();

    // Draw title centered at top
    page.graphics.drawString(
      'Product List PDF',
      PdfStandardFont(
        PdfFontFamily.helvetica,
        18,
        style: PdfFontStyle.bold,
      ),
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(0, 0, page.getClientSize().width, 40),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
    );

    // Add grid
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 4);

    // Header style
    grid.headers.add(1);
    final PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'ID';
    header.cells[1].value = 'Name';
    header.cells[2].value = 'Price';
    header.cells[3].value = 'Stock';

    header.style = PdfGridCellStyle(
      backgroundBrush: PdfBrushes.lightGray,
      textBrush: PdfBrushes.black,
      font: PdfStandardFont(PdfFontFamily.helvetica, 12,
          style: PdfFontStyle.bold),
    );

    // Add rows
    for (var product in _products) {
      final row = grid.rows.add();
      row.cells[0].value = product.productId.toString();
      row.cells[1].value = product.productName;
      row.cells[2].value = '\$${product.price.toStringAsFixed(2)}';
      row.cells[3].value = product.stock.toString();
    }

    // Draw the grid
    grid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, 50, page.getClientSize().width, 0),
    );

    // Save PDF
    final List<int> bytes = await document.save();
    document.dispose();

    // Store in file
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file =
        File('$path/products_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(bytes);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF exported to: ${file.path}'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () => OpenFile.open(file.path),
          ),
        ),
      );
    }
  }
}
