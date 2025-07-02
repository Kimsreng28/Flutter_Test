import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductItemShimmer extends StatelessWidget {
  const ProductItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.01,
      ),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  height: 20, width: size.width * 0.5, color: Colors.white),
              const SizedBox(height: 8),
              Container(
                  height: 16, width: size.width * 0.3, color: Colors.white),
              Container(
                  height: 16, width: size.width * 0.2, color: Colors.white),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(height: 24, width: 24, color: Colors.white),
                  const SizedBox(width: 16),
                  Container(height: 24, width: 24, color: Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
