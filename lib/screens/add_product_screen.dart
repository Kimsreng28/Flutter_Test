import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Add Product',
            style: TextStyle(fontFamily: 'ComicBold')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _productNameController,
                style: const TextStyle(
                    fontFamily: 'Comic', fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  labelStyle: TextStyle(
                      fontFamily: 'Comic', fontWeight: FontWeight.w600),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                style: const TextStyle(
                    fontFamily: 'Comic', fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(
                        fontFamily: 'Comic', fontWeight: FontWeight.w600)),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Please enter a valid positive price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _stockController,
                style: const TextStyle(
                    fontFamily: 'Comic', fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                    labelText: 'Stock',
                    labelStyle: TextStyle(
                        fontFamily: 'Comic', fontWeight: FontWeight.w600)),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter stock quantity';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid positive stock quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              productProvider.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        shadowColor: Colors.blue.withOpacity(0.5),
                        elevation: 5,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final newProduct = Product(
                            productId: 0, // Will be assigned by the server
                            productName: _productNameController.text,
                            price: double.parse(_priceController.text),
                            stock: int.parse(_stockController.text),
                          );

                          try {
                            await productProvider.addProduct(newProduct);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Product added successfully',
                                  style: TextStyle(
                                      fontFamily: 'Comic',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.greenAccent),
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          }
                        }
                      },
                      child: const Text('Add Product',
                          style: TextStyle(
                              fontFamily: 'ComicBold',
                              fontSize: 16,
                              color: Colors.white)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
