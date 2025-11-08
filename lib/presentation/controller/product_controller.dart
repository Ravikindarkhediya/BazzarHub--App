import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../modules/product/model/proiduct_model.dart';

/// Product Detail Controller
/// Manages state for product details, images, favorites, and actions
class ProductController extends ChangeNotifier {
  ProductController({required ProductModel product}) : _product = product;

  // State Variables
  ProductModel _product;
  int _currentImageIndex = 0;
  bool _isLoading = false;
  bool _isDescriptionExpanded = false;
  String? _errorMessage;

  // Getters
  ProductModel get product => _product;
  int get currentImageIndex => _currentImageIndex;
  bool get isLoading => _isLoading;
  bool get isDescriptionExpanded => _isDescriptionExpanded;
  String? get errorMessage => _errorMessage;
  bool get isFavorite => _product.isFavorite;
  List<String> get images => _product.images;
  int get totalImages => _product.images.length;

  // Debounce timer for favorite toggle
  DateTime? _lastFavoriteToggle;
  static const _favoriteDebounceMs = 500;

  /// Update current image index
  void updateImageIndex(int index) {
    if (index >= 0 && index < _product.images.length) {
      _currentImageIndex = index;
      notifyListeners();
    }
  }

  /// Toggle description expanded state
  void toggleDescription() {
    _isDescriptionExpanded = !_isDescriptionExpanded;
    notifyListeners();
  }

  /// Toggle favorite status with debounce
  Future<void> toggleFavorite(BuildContext context) async {
    // Debounce check
    final now = DateTime.now();
    if (_lastFavoriteToggle != null &&
        now.difference(_lastFavoriteToggle!).inMilliseconds <
            _favoriteDebounceMs) {
      return;
    }
    _lastFavoriteToggle = now;

    // Optimistic update
    _product = _product.copyWith(isFavorite: !_product.isFavorite);
    notifyListeners();
  }

  /// Share product
  Future<void> shareProduct(BuildContext context) async {
    try {
      final shareText =
          '''
${_product.productName}
Price: ${_product.formattedPrice}
Location: ${_product.address}

Check out this amazing product on BazzarHub!
      '''
              .trim();

      await Share.share(shareText, subject: _product.productName);

    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Failed to share product', isError: true);
      }
    }
  }

  /// Handle buy action
  Future<void> buyProduct(BuildContext context) async {
    _setLoading(true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // In real app: await _repository.initiatePurchase(product.productId);

      if (context.mounted) {
        _showSnackBar(context, '🎉 Proceeding to checkout...', isError: false);

        // Navigate to checkout page
        // Navigator.pushNamed(context, AppRoutes.checkout, arguments: product);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Failed to process request', isError: true);
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Open chat with seller
  Future<void> chatWithSeller(BuildContext context) async {
    try {
      // Simulate opening chat
      await Future.delayed(const Duration(milliseconds: 300));

      if (context.mounted) {
        _showSnackBar(
          context,
          '💬 Opening chat with ${_product.ownerName}...',
          isError: false,
        );

        // Navigate to chat page
        // Navigator.pushNamed(
        //   context,
        //   AppRoutes.chat,
        //   arguments: ChatArgs(
        //     sellerId: product.ownerId,
        //     productId: product.productId,
        //   ),
        // );
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Failed to open chat', isError: true);
      }
    }
  }

  /// Call seller
  Future<void> callSeller(BuildContext context) async {
    try {
      // In real app: await _urlLauncher.launch('tel:${product.ownerContact}');

      if (context.mounted) {
        _showSnackBar(
          context,
          '📞 Calling ${_product.ownerContact}...',
          isError: false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Failed to initiate call', isError: true);
      }
    }
  }

  /// Load similar products (for future implementation)
  Future<List<ProductModel>> loadSimilarProducts() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // In real app: return await _repository.getSimilarProducts(
      //   categoryId: product.categoryId,
      //   excludeId: product.productId,
      // );

      return []; // Return empty for now
    } catch (e) {
      _errorMessage = 'Failed to load similar products';
      notifyListeners();
      return [];
    }
  }

  /// Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFE74C3C) // AppColors.error
            : const Color(0xFF00A65A), // AppColors.success
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
}

/// Extension to ProductModel for copyWith functionality
extension ProductModelExtension on ProductModel {
  ProductModel copyWith({
    int? productId,
    String? productName,
    String? ownerName,
    String? ownerContact,
    double? price,
    String? addedDate,
    String? detail,
    String? description,
    String? address,
    int? likes,
    List<String>? images,
    int? categoryId,
    bool? isFavorite,
    Map<String, String>? specs,
    String? condition,
    String? stockStatus,
  }) {
    return ProductModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      ownerName: ownerName ?? this.ownerName,
      ownerContact: ownerContact ?? this.ownerContact,
      price: price ?? this.price,
      addedDate: addedDate ?? this.addedDate,
      detail: detail ?? this.detail,
      description: description ?? this.description,
      address: address ?? this.address,
      likes: likes ?? this.likes,
      images: images ?? this.images,
      categoryId: categoryId ?? this.categoryId,
      isFavorite: isFavorite ?? this.isFavorite,
      specs: specs ?? this.specs,
      condition: condition ?? this.condition,
    );
  }
}
