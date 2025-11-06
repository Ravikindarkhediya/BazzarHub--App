import 'package:flutter/material.dart' show BoxFit, TextStyle, StatefulWidget, State, TextEditingController, BuildContext, Widget, Text, EdgeInsets, Icon, Center, Navigator, MaterialPageRoute, AppBar, Icons, IconButton, Colors, BorderRadius, BorderSide, OutlineInputBorder, InputDecoration, TextField, Padding, ListView, Image, ListTile, Expanded, Column, Scaffold;
import '../../product/model/proiduct_model.dart';
import '../../product/views/product_detail_page.dart';

class SearchPage extends StatefulWidget {
  final List<Map<String, dynamic>> categoryData;

  const SearchPage({super.key, required this.categoryData});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filtered = [];

  @override
  void initState() {
    super.initState();
    // Flatten all products from category JSON
    for (var category in widget.categoryData) {
      final products = category['products'] as List;
      _allProducts.addAll(products.map((e) => ProductModel.fromJson(e)));
    }
    _filtered = _allProducts;
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = _allProducts;
      } else {
        _filtered = _allProducts
            .where((p) =>
        p.productName.toLowerCase().contains(query.toLowerCase()) ||
            p.description.toLowerCase().contains(query.toLowerCase()) ||
            p.detail.toLowerCase().contains(query.toLowerCase()) ||
            p.address.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _openProductDetail(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Products'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 Search Field
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _controller,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search for products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    _onSearch('');
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),

          // 📋 Result List
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
              child: Text(
                "No matching products found 😕",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final product = _filtered[index];
                return ListTile(
                  leading: Image.asset(
                    product.images.first,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(product.productName),
                  subtitle: Text(product.formattedPrice),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 16),
                  onTap: () => _openProductDetail(product),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
