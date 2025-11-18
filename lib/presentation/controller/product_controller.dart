import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../services/api_service.dart';
import '../services/models/Common/location_model.dart';
import '../services/models/categorie/categorie_model.dart';
import '../services/models/marketplace/marketplace_contact_info_model.dart';
import '../services/models/marketplace/marketplace_model.dart';
import '../services/models/user/user_model.dart';

/// Product Detail Controller
/// Manages state for product details, images, favorites, and actions
class ProductController extends ChangeNotifier {
  ProductController({required MarketplaceModel product})
    : _product = product,
      _isFavorite = product.favorites > 0 || product.favoritesCount > 0;

  // State Variables
  MarketplaceModel _product;
  int _currentImageIndex = 0;
  bool _isLoading = false;
  bool _isDescriptionExpanded = false;
  String? _errorMessage;
  bool _isFavorite = false;
  bool _favoriteLoading = false;

  // Getters
  MarketplaceModel get product => _product;
  int get currentImageIndex => _currentImageIndex;
  bool get isLoading => _isLoading;
  bool get isDescriptionExpanded => _isDescriptionExpanded;
  String? get errorMessage => _errorMessage;
  bool get isFavorite => _isFavorite;
  bool get isFavoriteLoading => _favoriteLoading;
  List<String> get images => _product.images;
  int get totalImages => _product.images.length;

  String get productTitle =>
      _product.title.isNotEmpty ? _product.title : 'Product';

  String get formattedPrice => '₹ ${_product.price.toStringAsFixed(0)}';

  String get sellerName {
    final name = _product.createdBy?.name.trim();
    return (name == null || name.isEmpty) ? 'Seller' : name;
  }

  String? get primaryPhone {
    final contactPhones = _product.contactInfo?.phone ?? [];
    if (contactPhones.isNotEmpty && contactPhones.first.trim().isNotEmpty) {
      return contactPhones.first;
    }
    final fallback = _product.createdBy?.phone.trim();
    if (fallback != null && fallback.isNotEmpty) {
      return fallback;
    }
    return null;
  }

  String? get primaryEmail {
    final emails = _product.contactInfo?.email ?? [];
    if (emails.isNotEmpty && emails.first.trim().isNotEmpty) {
      return emails.first;
    }
    final fallback = _product.createdBy?.email.trim();
    if (fallback != null && fallback.isNotEmpty) {
      return fallback;
    }
    return null;
  }

  String get locationSummary {
    final location = _product.location;
    if (location == null) return 'Location unavailable';
    final parts = [
      location.village,
      location.taluko,
      location.district,
      location.zipCode,
      location.country,
    ].where((part) => part.trim().isNotEmpty).toList();
    return parts.isEmpty ? 'Location unavailable' : parts.join(', ');
  }

  String get conditionLabel =>
      _product.condition.isNotEmpty ? _product.condition : 'Verified';

  DateTime? get createdAt =>
      _product.createdAt.isEmpty ? null : DateTime.tryParse(_product.createdAt);

  // Debounce timer for favorite toggle
  DateTime? _lastFavoriteToggle;
  static const _favoriteDebounceMs = 500;

  /// Update controller with new product data
  void updateProduct(MarketplaceModel product) {
    _product = product;
    _isFavorite = product.favorites > 0 || product.favoritesCount > 0;
    notifyListeners();
  }

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

  /// Toggle favorite status with backend sync
  Future<void> toggleFavorite(BuildContext context) async {
    if (_favoriteLoading) return;

    final listingId = _product.id;
    if (listingId.isEmpty) {
      _showSnackBar(context, 'Product information unavailable.', isError: true);
      return;
    }

    // Debounce check
    final now = DateTime.now();
    if (_lastFavoriteToggle != null &&
        now.difference(_lastFavoriteToggle!).inMilliseconds <
            _favoriteDebounceMs) {
      return;
    }
    _lastFavoriteToggle = now;

    final previousState = _isFavorite;
    final targetState = !previousState;

    _setFavoriteLoading(true);

    try {
      final services = await getApiClient();
      final response = await services.addToFavorite({'listingId': listingId});

      if (!response.data.status) {
        throw Exception(
          response.data.message ?? 'Unable to update favorite status.',
        );
      }

      final data = response.data.data;
      int? updatedCount;

      if (data is Map<String, dynamic>) {
        final rawCount = data['favoritesCount'];
        if (rawCount is int) {
          updatedCount = rawCount;
        } else if (rawCount is num) {
          updatedCount = rawCount.toInt();
        }
      }

      _isFavorite = targetState;
      _updateFavoritesCount(
        updatedCount ?? _fallbackFavoriteCount(targetState),
      );
      notifyListeners();

      final message =
          response.data.message ?? 'Favorite status updated successfully.';
      _showSnackBar(context, message, isError: false);
    } on DioException catch (error) {
      _isFavorite = previousState;
      _showSnackBar(context, _mapDioError(error), isError: true);
    } catch (error) {
      _isFavorite = previousState;
      _showSnackBar(
        context,
        error.toString().isNotEmpty
            ? error.toString()
            : 'Failed to update favorite status.',
        isError: true,
      );
    } finally {
      _setFavoriteLoading(false);
    }
  }

  /// Share product
  Future<void> shareProduct(BuildContext context) async {
    try {
      final shareText =
          '''
$productTitle
Price: $formattedPrice
Location: $locationSummary

Check out this amazing product on BazzarHub!
      '''
              .trim();

      await Share.share(shareText, subject: productTitle);
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

      if (context.mounted) {
        _showSnackBar(context, '🎉 Proceeding to checkout...', isError: false);
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
      await Future.delayed(const Duration(milliseconds: 300));

      if (context.mounted) {
        _showSnackBar(
          context,
          '💬 Opening chat with $sellerName...',
          isError: false,
        );
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
      final phone = primaryPhone;
      if (phone == null) {
        throw Exception('Seller contact not available.');
      }

      if (context.mounted) {
        _showSnackBar(context, '📞 Calling $phone...', isError: false);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, e.toString(), isError: true);
      }
    }
  }

  /// Load similar products (for future implementation)
  Future<List<MarketplaceModel>> loadSimilarProducts() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
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

  void _setFavoriteLoading(bool loading) {
    _favoriteLoading = loading;
    notifyListeners();
  }

  void _updateFavoritesCount(int count) {
    final safeCount = count < 0 ? 0 : count;
    _product = _product.copyWith(
      favoritesCount: safeCount,
      favorites: _isFavorite ? 1 : 0,
    );
  }

  int _fallbackFavoriteCount(bool willBeFavorite) {
    final nextCount = willBeFavorite
        ? _product.favoritesCount + 1
        : _product.favoritesCount - 1;
    return nextCount < 0 ? 0 : nextCount;
  }

  String _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Connection timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'Network unavailable. Check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        return 'Server error${statusCode != null ? ' ($statusCode)' : ''}. Please try again later.';
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return error.message ?? 'Unexpected error occurred.';
    }
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

extension MarketplaceModelCopyWith on MarketplaceModel {
  MarketplaceModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    CategoryModel? category,
    List<String>? images,
    String? condition,
    String? type,
    int? views,
    int? favoritesCount,
    int? favorites,
    bool? isActive,
    LocationModel? location,
    MarketplaceContactInfoModel? contactInfo,
    UserModel? createdBy,
    String? createdAt,
    String? updatedAt,
    int? version,
  }) {
    return MarketplaceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      images: images ?? this.images,
      condition: condition ?? this.condition,
      type: type ?? this.type,
      views: views ?? this.views,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      favorites: favorites ?? this.favorites,
      isActive: isActive ?? this.isActive,
      location: location ?? this.location,
      contactInfo: contactInfo ?? this.contactInfo,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }
}
