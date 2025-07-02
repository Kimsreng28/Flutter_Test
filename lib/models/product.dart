class Product {
  final int? productId;
  final String productName;
  final double price;
  final int stock;

  Product({
    this.productId,
    required this.productName,
    required this.price,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: int.parse(
          json['productId']?.toString() ?? json['PRODUCTID'].toString()),
      productName: json['productName'] ?? json['PRODUCTNAME'],
      price: double.parse((json['price'] ?? json['PRICE']).toString()),
      stock: int.parse((json['stock'] ?? json['STOCK']).toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (productId != null) 'productId': productId,
      'productName': productName,
      'price': price,
      'stock': stock,
    };
  }
}
