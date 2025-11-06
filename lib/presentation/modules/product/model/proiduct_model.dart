
class ProductModel {
  final int productId;
  final String productName;
  final String ownerName;
  final String ownerContact;
  final double price;
  final String addedDate;
  final String detail;
  final String description;
  final String address;
  final int likes;
  final List<String> images;
  final int categoryId;
  final bool isFavorite;
  final Map<String, String> specs;
  final String condition;
  final double? sellerRating;
  final int? sellerTotalSales;

  ProductModel({
    required this.productId,
    required this.productName,
    required this.ownerName,
    required this.ownerContact,
    required this.price,
    required this.addedDate,
    required this.detail,
    required this.description,
    required this.address,
    required this.likes,
    required this.images,
    required this.categoryId,
    this.isFavorite = false,
    this.specs = const {},
    this.condition = 'Good',
    this.sellerRating,
    this.sellerTotalSales,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['productId'] as int,
      productName: json['productName'] as String,
      ownerName: json['ownerName'] as String,
      ownerContact: json['ownerContact'] as String,
      price: (json['price'] as num).toDouble(),
      addedDate: json['addedDate'] as String,
      detail: json['detail'] as String,
      description: json['description'] as String,
      address: json['address'] as String,
      likes: json['likes'] as int,
      images: List<String>.from(json['images'] as List),
      categoryId: json['categoryId'] as int,
      isFavorite: json['isFavorite'] as bool? ?? false,
      specs: json['specs'] != null
          ? Map<String, String>.from(json['specs'] as Map)
          : {},
      condition: json['condition'] as String? ?? 'Good',
      sellerRating: json['sellerRating'] != null
          ? (json['sellerRating'] as num).toDouble()
          : null,
      sellerTotalSales: json['sellerTotalSales'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'ownerName': ownerName,
      'ownerContact': ownerContact,
      'price': price,
      'addedDate': addedDate,
      'detail': detail,
      'description': description,
      'address': address,
      'likes': likes,
      'images': images,
      'categoryId': categoryId,
      'isFavorite': isFavorite,
      'specs': specs,
      'condition': condition,
      'sellerRating': sellerRating,
      'sellerTotalSales': sellerTotalSales,
    };
  }

  /// Helper to get formatted date
  DateTime get dateAdded => DateTime.parse(addedDate);

  /// Helper to format price with currency
  String get formattedPrice => '₹ ${price.toStringAsFixed(0)}';

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(dateAdded);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }


  /// Check if product has specs
  bool get hasSpecs => specs.isNotEmpty;

  /// Get formatted seller rating
  String get formattedRating {
    if (sellerRating == null) return 'New Seller';
    return '${sellerRating!.toStringAsFixed(1)} ⭐';
  }


}