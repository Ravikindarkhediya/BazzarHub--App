import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../controllers/sell_product_controller.dart';
import '../widgets/image_upload_section.dart';

class SellProductPage extends StatefulWidget {
  const SellProductPage({super.key});

  @override
  State<SellProductPage> createState() => _SellProductPageState();
}

class _SellProductPageState extends State<SellProductPage> {
  late SellProductController _controller;
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = SellProductController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final success = await _controller.submitProduct(context);
    if (success && mounted) {
      // Navigate back or show success page
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.back, size: 28),
              Text('Back'),
            ],
          ),
        ),
        middle: const Text(
          'Sell Product',
          style: TextStyle(
            decoration: TextDecoration.none,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _controller.clearForm,
          child: const Text(
            'Clear',
            style: TextStyle(
              decoration: TextDecoration.none,
              fontSize: 16,
              color: CupertinoColors.destructiveRed,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: (isLandscape || isTablet)
            ? _buildLandscapeLayout()
            : _buildPortraitLayout(),
      ),
    );
  }

  /// Portrait Layout (Stacked)
  Widget _buildPortraitLayout() {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Image Upload Section
                ImageUploadSection(controller: _controller),

                const SizedBox(height: 32),

                /// Form Fields
                _buildFormSection(),

                const SizedBox(height: 32),

                /// Submit Button
                _buildSubmitButton(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Landscape Layout (Side by Side)
  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        /// Left: Image Section
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ImageUploadSection(controller: _controller),
          ),
        ),

        /// Divider
        Container(
          width: 1,
          color: CupertinoColors.separator,
        ),

        /// Right: Form Section
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildFormSection(),
                const SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Form Section
  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Category Selection
        _buildSectionTitle('Category *'),
        const SizedBox(height: 12),
        _buildCategorySelector(),

        const SizedBox(height: 24),

        /// Title
        _buildSectionTitle('Product Title *'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _controller.titleController,
          placeholder: 'e.g., iPhone 14 Pro 256GB',
          maxLength: 100,
        ),

        const SizedBox(height: 24),

        /// Description
        _buildSectionTitle('Description *'),
        const SizedBox(height: 8),
        _buildTextArea(
          controller: _controller.descriptionController,
          placeholder: 'Describe your product in detail...',
          maxLength: 1000,
        ),

        const SizedBox(height: 24),

        /// Price & Condition Row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Price *'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _controller.priceController,
                    placeholder: '0',
                    keyboardType: TextInputType.number,
                    prefix: const Text('₹ ', style: TextStyle(
                      decoration: TextDecoration.none,
                    ),),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Condition *'),
                  const SizedBox(height: 8),
                  _buildConditionPicker(),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        /// Location
        _buildSectionTitle('Location'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _controller.locationController,
          placeholder: 'City, State',
          prefixIcon: CupertinoIcons.location_solid,
        ),

        const SizedBox(height: 24),

        /// Contact
        _buildSectionTitle('Contact Number *'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _controller.contactController,
          placeholder: '+91 9876543210',
          keyboardType: TextInputType.phone,
          maxLength: 15,
          prefixIcon: CupertinoIcons.phone_fill,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        decoration: TextDecoration.none,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: CupertinoColors.black,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    int? maxLength,
    TextInputType? keyboardType,
    Widget? prefix,
    IconData? prefixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        maxLength: maxLength,
        keyboardType: keyboardType,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(10),
        ),
        prefix: prefix != null
            ? Padding(
          padding: const EdgeInsets.only(left: 16),
          child: prefix,
        )
            : prefixIcon != null
            ? Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Icon(prefixIcon, size: 20, color: CupertinoColors.systemGrey),
        )
            : null,
        style: const TextStyle(fontSize: 16,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String placeholder,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        maxLength: maxLength,
        maxLines: 5,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(10),
        ),
        style: const TextStyle(fontSize: 16,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final categories = [
          {'id': 1, 'name': 'Mobiles', 'icon': '📱'},
          {'id': 2, 'name': 'Cars', 'icon': '🚗'},
          {'id': 3, 'name': 'Bikes', 'icon': '🏍️'},
          {'id': 4, 'name': 'Fashion', 'icon': '👕'},
        ];

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final isSelected = _controller.selectedCategoryId == category['id'];
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                _controller.selectCategory(category['id'] as int);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? CupertinoColors.activeBlue
                      : CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.systemGrey4,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category['icon'] as String,
                      style: const TextStyle(fontSize: 20,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category['name'] as String,
                      style: TextStyle(
                        fontSize: 15,
                        decoration: TextDecoration.none,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : CupertinoColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildConditionPicker() {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return GestureDetector(
          onTap: () => _showConditionPicker(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _controller.selectedCondition,
                  style: const TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: 16,
                    color: CupertinoColors.black,
                  ),
                ),
                const Icon(
                  CupertinoIcons.chevron_down,
                  size: 18,
                  color: CupertinoColors.systemGrey,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showConditionPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(context),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const Text(
                    'Condition',
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.pop(context);
                      HapticFeedback.mediumImpact();
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 44,
                onSelectedItemChanged: (index) {
                  _controller.selectCondition(
                    SellProductController.conditions[index],
                  );
                },
                children: SellProductController.conditions
                    .map((condition) => Center(child: Text(condition)))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                CupertinoColors.activeBlue,
                Color(0xFF007AFF),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.activeBlue.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _controller.isLoading ? null : _handleSubmit,
            child: _controller.isLoading
                ? const CupertinoActivityIndicator(
              color: Colors.white,
            )
                : const Text(
              'List Product',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}