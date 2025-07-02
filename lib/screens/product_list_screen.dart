import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/widgets/product_item_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/product_item.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late RefreshController _refreshController;
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _refreshController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      Provider.of<ProductProvider>(context, listen: false)
          .setSearchQuery(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
        title: const Text(
          'Products',
          style: TextStyle(fontSize: 24, fontFamily: 'ComicBold'),
        ),
        actions: [
          // Add Product Button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/add');
            },
          ),

          // Export to PDF Button
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              Provider.of<ProductProvider>(context, listen: false)
                  .exportToPdf(context);
            },
          ),

          // Sort Button
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'name',
                child: Text('Sort by Name'),
              ),
              const PopupMenuItem(
                value: 'price',
                child: Text('Sort by Price'),
              ),
              const PopupMenuItem(
                value: 'stock',
                child: Text('Sort by Stock'),
              ),
            ],
            onSelected: (value) {
              Provider.of<ProductProvider>(context, listen: false)
                  .sortProducts(value);
            },
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (productProvider.isLoading && productProvider.products.isEmpty) {
            return ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) => const ProductItemShimmer(),
            );
          } else if (productProvider.error.isNotEmpty) {
            return Center(child: Text(productProvider.error));
          } else {
            return Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      labelStyle: const TextStyle(
                          fontFamily: 'Comic', fontWeight: FontWeight.w600),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      // Box shadow for the search bar
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Colors.blueAccent,
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  // Product List
                  child: SmartRefresher(
                    controller: _refreshController,
                    onRefresh: () async {
                      await productProvider.fetchProducts();
                      _refreshController.refreshCompleted();
                    },
                    child: productProvider.filteredProducts.isEmpty
                        ? const Center(
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 50),
                              SizedBox(height: 16),
                              Text(
                                'No products found',
                                style: TextStyle(
                                  fontFamily: 'Comic',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ))
                        : ListView.builder(
                            itemCount: productProvider.filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product =
                                  productProvider.filteredProducts[index];
                              return ProductItem(
                                product: product,
                                onEdit: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/edit',
                                    arguments: product,
                                  );
                                },
                                onDelete: () async {
                                  await _showDeleteDialog(context, product);
                                },
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, Product product) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Product',
            style: TextStyle(
              fontFamily: 'ComicBold',
            ),
          ),
          content: Text(
            'Are you sure you want to delete ${product.productName}?',
            style: const TextStyle(
              fontFamily: 'Comic',
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Comic',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await Provider.of<ProductProvider>(context, listen: false)
                      .deleteProduct(product.productId!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Product deleted successfully',
                        style: TextStyle(
                          fontFamily: 'Comic',
                          fontWeight: FontWeight.w600,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                      'Error: ${e.toString()}',
                    )),
                  );
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontFamily: 'Comic',
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
