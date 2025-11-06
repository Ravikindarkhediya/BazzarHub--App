
import '../../product/model/proiduct_model.dart';

class CategoryModel {
  final int categoryId;
  final String categoryName;
  final String categoryIcon;
  final List<ProductModel> products;

  CategoryModel({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.products,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String,
      categoryIcon: json['categoryIcon'] as String,
      products: (json['products'] as List)
          .map((product) => ProductModel.fromJson(product))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'products': products.map((product) => product.toJson()).toList(),
    };
  }
}




