// // lib/features/home/presentation/controllers/filter_controller.dart
//
// import 'package:flutter/material.dart';
// import '../modules/product/model/proiduct_model.dart';
//
// /// Filter Controller
// /// Manages search query, filters, and product filtering logic
// class FilterController extends ChangeNotifier {
//   // Search State
//   String _searchQuery = '';
//
//
//   //
//   // Filter State
//   double? _minPrice;
//   double? _maxPrice;
//   String _sortBy = 'newest'; // 'newest', 'oldest', 'price_low', 'price_high'
//   bool _isFilterApplied = false;
//
//   // Original & Filtered Products
//   List<ProductModel> _allProducts = [];
//   List<ProductModel> _filteredProducts = [];
//
//   // Getters
//   String get searchQuery => _searchQuery;
//   double? get minPrice => _minPrice;
//   double? get maxPrice => _maxPrice;
//   String get sortBy => _sortBy;
//   bool get isFilterApplied => _isFilterApplied;
//   List<ProductModel> get filteredProducts => _filteredProducts;
//   int get resultCount => _filteredProducts.length;
//
//   /// Initialize with all products
//   void setAllProducts(List<ProductModel> products) {
//     _allProducts = products;
//     _filteredProducts = products;
//     notifyListeners();
//     debugPrint('✅ FilterController: Initialized with ${products.length} products');
//   }
//
//   /// Update search query and filter
//   void updateSearchQuery(String query) {
//     _searchQuery = query.trim();
//     _applyFilters();
//     debugPrint('🔍 Search Query Updated: "$_searchQuery"');
//   }
//
//   /// Update price range
//   void updatePriceRange({double? min, double? max}) {
//     try {
//       if (min != null && max != null && min > max) {
//         debugPrint('⚠️ Min price cannot be greater than max price');
//         return;
//       }
//
//       _minPrice = min;
//       _maxPrice = max;
//       debugPrint('💰 Price Range Updated: Min=$_minPrice, Max=$_maxPrice');
//     } catch (e) {
//       debugPrint('❌ Error updating price range: $e');
//     }
//   }
//
//   /// Update sort option
//   void updateSortBy(String sortOption) {
//     _sortBy = sortOption;
//     debugPrint('📊 Sort By Updated: $_sortBy');
//   }
//
//   /// Apply all filters
//   void applyFilters() {
//     _isFilterApplied = _minPrice != null ||
//         _maxPrice != null ||
//         _sortBy != 'newest';
//     _applyFilters();
//     debugPrint('✅ Filters Applied: isApplied=$_isFilterApplied');
//   }
//
//   /// Reset all filters
//   void resetFilters() {
//     _searchQuery = '';
//     _minPrice = null;
//     _maxPrice = null;
//     _sortBy = 'newest';
//     _isFilterApplied = false;
//     _applyFilters();
//     debugPrint('🔄 Filters Reset');
//   }
//
//   /// Internal method to apply all filters
//   void _applyFilters() {
//     try {
//       List<ProductModel> results = List.from(_allProducts);
//
//       // 1. Apply Search Filter
//       if (_searchQuery.isNotEmpty) {
//         results = results.where((product) {
//           final query = _searchQuery.toLowerCase();
//           return product.productName.toLowerCase().contains(query) ||
//               product.description.toLowerCase().contains(query) ||
//               product.detail.toLowerCase().contains(query) ||
//               product.address.toLowerCase().contains(query);
//         }).toList();
//         debugPrint('🔍 After Search: ${results.length} products');
//       }
//
//       // 2. Apply Price Range Filter
//       if (_minPrice != null) {
//         results = results.where((product) => product.price >= _minPrice!).toList();
//         debugPrint('💰 After Min Price ($minPrice): ${results.length} products');
//       }
//
//       if (_maxPrice != null) {
//         results = results.where((product) => product.price <= _maxPrice!).toList();
//         debugPrint('💰 After Max Price ($maxPrice): ${results.length} products');
//       }
//
//       // 3. Apply Sorting
//       switch (_sortBy) {
//         case 'newest':
//           results.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
//           break;
//         case 'oldest':
//           results.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
//           break;
//         case 'price_low':
//           results.sort((a, b) => a.price.compareTo(b.price));
//           break;
//         case 'price_high':
//           results.sort((a, b) => b.price.compareTo(a.price));
//           break;
//       }
//       debugPrint('📊 After Sorting by $_sortBy: ${results.length} products');
//
//       _filteredProducts = results;
//       notifyListeners();
//     } catch (e) {
//       debugPrint('❌ Error applying filters: $e');
//       _filteredProducts = _allProducts;
//       notifyListeners();
//     }
//   }
//
//   /// Clear search only
//   void clearSearch() {
//     _searchQuery = '';
//     _applyFilters();
//     debugPrint('🗑️ Search Cleared');
//   }
//
//   /// Get filter summary for UI display
//   String getFilterSummary() {
//     final List<String> summaryParts = [];
//
//     if (_minPrice != null || _maxPrice != null) {
//       if (_minPrice != null && _maxPrice != null) {
//         summaryParts.add('₹${_minPrice!.toInt()} - ₹${_maxPrice!.toInt()}');
//       } else if (_minPrice != null) {
//         summaryParts.add('₹${_minPrice!.toInt()}+');
//       } else if (_maxPrice != null) {
//         summaryParts.add('Up to ₹${_maxPrice!.toInt()}');
//       }
//     }
//
//     if (_sortBy != 'newest') {
//       switch (_sortBy) {
//         case 'oldest':
//           summaryParts.add('Oldest First');
//           break;
//         case 'price_low':
//           summaryParts.add('Price: Low to High');
//           break;
//         case 'price_high':
//           summaryParts.add('Price: High to Low');
//           break;
//       }
//     }
//
//     return summaryParts.isEmpty ? 'No filters' : summaryParts.join(' • ');
//   }
//
//   @override
//   void dispose() {
//     debugPrint('🗑️ FilterController Disposed');
//     super.dispose();
//   }
// }