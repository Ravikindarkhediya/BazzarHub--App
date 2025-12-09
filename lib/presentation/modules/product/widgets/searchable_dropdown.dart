import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';

class SearchableDropdown extends StatefulWidget {
  final String label;
  final String hint;
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final IconData icon;
  final bool allowManualEntry;
  final bool isRequired;

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    this.selectedValue,
    required this.onChanged,
    this.enabled = true,
    required this.icon,
    this.allowManualEntry = false,
    this.isRequired = false,
  });

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  final TextEditingController _searchController = TextEditingController();
  bool _isDropdownOpen = false;

  bool get _canOpenDropdown =>
      widget.enabled && (widget.items.isNotEmpty || widget.allowManualEntry);

  @override
  void initState() {
    super.initState();
    // ✅ Set initial value
    _updateControllerText(widget.selectedValue ?? '');
  }

  @override
  void didUpdateWidget(covariant SearchableDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ Only update if dropdown is closed and value actually changed
    if (!_isDropdownOpen) {
      if (widget.selectedValue != oldWidget.selectedValue) {
        // ✅ Use post frame callback to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isDropdownOpen) {
            _updateControllerText(widget.selectedValue ?? '');
          }
        });
      } else if (!listEquals(widget.items, oldWidget.items)) {
        // ✅ Items changed, reset to selected value
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isDropdownOpen) {
            _updateControllerText(widget.selectedValue ?? '');
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✅ Helper method to update controller text safely
  void _updateControllerText(String text) {
    if (_searchController.text != text) {
      _searchController.text = text;
    }
  }

  void _showDropdown() {
    if (!_canOpenDropdown) {
      HapticFeedback.selectionClick();
      return;
    }
    if (_isDropdownOpen) return;

    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();

    setState(() {
      _isDropdownOpen = true;
    });

    // ✅ Set text and selection safely
    final currentValue = widget.selectedValue ?? '';
    _searchController
      ..text = currentValue
      ..selection = TextSelection(
        baseOffset: 0,
        extentOffset: currentValue.length,
      );

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheet(),
    ).whenComplete(() {
      if (mounted) {
        setState(() => _isDropdownOpen = false);
      }
    });
  }

  Widget _buildBottomSheet() {
    return AnimatedBuilder(
      animation: _searchController,
      builder: (context, child) {
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;

        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(bottom: viewInsets),
          child: SafeArea(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusXL),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.only(top: AppSpacing.sm),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius:
                      BorderRadius.circular(AppSpacing.radiusCircle),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: AppSpacing.paddingMD,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Select ${widget.label}',
                            style: AppTextStyles.h5.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // Search box
                  Padding(
                    padding: AppSpacing.horizontalMD,
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search ${widget.label.toLowerCase()}...',
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.primary),
                        filled: true,
                        fillColor: AppColors.grey100,
                        border: OutlineInputBorder(
                          borderRadius: AppSpacing.borderRadiusMD,
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // List
                  Expanded(
                    child: _buildItemsList(viewInsets),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ✅ Separate method for items list
  Widget _buildItemsList(double viewInsets) {
    final query = _searchController.text.trim().toLowerCase();
    final filteredItems = query.isEmpty
        ? widget.items
        : widget.items
        .where((item) => item.toLowerCase().contains(query))
        .toList();

    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 16),
            Text(
              widget.allowManualEntry
                  ? 'No matches. Add your village manually.'
                  : 'No results found',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.allowManualEntry) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  final customValue = _searchController.text.trim();
                  if (customValue.isNotEmpty) {
                    widget.onChanged(customValue);
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.add),
                label: Text('Use "${_searchController.text}"'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(
        bottom: viewInsets + 24,
        left: AppSpacing.md,
        right: AppSpacing.md,
      ),
      itemCount: filteredItems.length,
      separatorBuilder: (_, __) => const Divider(height: 0),
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        final isSelected = item == widget.selectedValue;

        return ListTile(
          title: Text(
            item,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: AppColors.primary)
              : null,
          onTap: () {
            widget.onChanged(item);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: widget.label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: widget.enabled
                  ? AppColors.textPrimary
                  : AppColors.textDisabled,
            ),
            children: [
              if (widget.isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: widget.enabled ? 1 : 0.5,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppSpacing.borderRadiusMD,
              onTap: _canOpenDropdown ? _showDropdown : null,
              child: Ink(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: widget.enabled ? AppColors.white : AppColors.grey100,
                  borderRadius: AppSpacing.borderRadiusMD,
                  border: Border.all(
                    color: widget.enabled
                        ? AppColors.borderLight
                        : AppColors.grey300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      color: widget.enabled
                          ? AppColors.primary
                          : AppColors.textDisabled,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.selectedValue ?? widget.hint,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: widget.selectedValue != null
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: widget.enabled
                          ? AppColors.textPrimary
                          : AppColors.textDisabled,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
