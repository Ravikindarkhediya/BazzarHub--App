import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';

import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../commons/widgets/custom_app_bar.dart';
import '../../../controller/location_controller.dart';
import '../models/panchayat_model.dart';

class PanchayatFormScreen extends StatefulWidget {
  final Panchayat? panchayat;

  const PanchayatFormScreen({Key? key, this.panchayat}) : super(key: key);

  @override
  _PanchayatFormScreenState createState() => _PanchayatFormScreenState();
}

class _PanchayatFormScreenState extends State<PanchayatFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  
  // Location controllers
  final LocationController _locationController = Get.put(LocationController());
  final _locationFormKey = GlobalKey<FormState>();

  final List<String> _panchayatCategories = [
    'Temple',
    'School',
    'Hospital',
    'Community Center',
    'Government Office',
    'Park',
    'Library',
    'Other'
  ];

  String _selectedCategory = 'Temple';
  List<File> _imageFiles = [];
  List<Uint8List> _webImages = [];
  final ImagePicker _picker = ImagePicker();
  final int _maxImages = 5; // Maximum number of images allowed

  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.panchayat != null;
    
    // Initialize location data
    _locationController.loadLocationsData().then((_) {
      if (_isEdit) {
        _loadPanchayatData();
      }
    });
  }

  Future<void> _loadPanchayatData() async {
    final panchayat = widget.panchayat;
    if (panchayat != null) {
      _nameController.text = panchayat.name;
      _descriptionController.text = panchayat.description;
      _addressController.text = panchayat.address;
      _contactController.text = panchayat.contactNumber;
      _emailController.text = panchayat.email;
      _cityController.text = panchayat.city;
      _selectedCategory = panchayat.category;
      
      // Set location data
      if (panchayat.state != null && panchayat.state!.isNotEmpty) {
        await _locationController.initializeWithUserLocation(
          state: panchayat.state,
          district: panchayat.district,
          taluka: panchayat.taluka,
          village: panchayat.village,
        );
      }
      // Handle image loading if needed
    }
  }

  Future<void> _pickImages() async {
    if ((_imageFiles.length + _webImages.length) >= _maxImages) {
      Get.snackbar(
        'Maximum limit reached',
        'You can upload up to $_maxImages images',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        if (kIsWeb) {
          for (var file in pickedFiles) {
            final bytes = await file.readAsBytes();
            if ((_webImages.length + _imageFiles.length) < _maxImages) {
              _webImages.add(bytes);
            } else {
              break;
            }
          }
        } else {
          for (var file in pickedFiles) {
            if ((_imageFiles.length + _webImages.length) < _maxImages) {
              _imageFiles.add(File(file.path));
            } else {
              break;
            }
          }
        }
        setState(() {});
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick images: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      if (kIsWeb) {
        _webImages.removeAt(index);
      } else {
        _imageFiles.removeAt(index);
      }
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Handle form submission
      Get.back(result: true);
    }
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Text(
          _isEdit ? 'Update Panchayat' : 'Add Panchayat',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Edit Panchayat' : 'Add New Panchayat',
          style: AppTextStyles.h5.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? screenWidth * 0.2 : 16,
          vertical: 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePicker(),
              const SizedBox(height: 24),

              // Responsive layout for form fields
              if (isDesktop || isTablet)
                _buildDesktopTabletLayout()
              else
                _buildMobileLayout(),

              const SizedBox(height: 24),

              // Submit Button
              _buildSubmitButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    final hasImages = _imageFiles.isNotEmpty || _webImages.isNotEmpty;
    final remainingImages = _maxImages - _imageFiles.length - _webImages.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Panchayat Photos',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (hasImages) _buildImageGrid(),
        const SizedBox(height: AppSpacing.md),
        if ((_imageFiles.length + _webImages.length) < _maxImages)
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.grey300,
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 32,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add ${remainingImages > 1 ? 'up to $remainingImages more photos' : '1 more photo'}\n(Max $_maxImages)',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageGrid() {
    final images = kIsWeb ? _webImages : _imageFiles;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.grey300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: kIsWeb
                    ? Image.memory(
                        _webImages[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : Image.file(
                        _imageFiles[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
              ),
            ),
            Positioned(
              right: 4,
              top: 4,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildFormField(
          labelText: 'Name',
          hintText: 'Enter name',
          prefixIcon: Icons.business,
          controller: _nameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a name';
            }
            return null;
          },
        ),
        _buildCategoryDropdown(),
        _buildFormField(
          labelText: 'Description',
          hintText: 'Enter description',
          prefixIcon: Icons.description,
          maxLines: 4,
          controller: _descriptionController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
        _buildFormField(
          labelText: 'Address',
          hintText: 'Enter full address',
          prefixIcon: Icons.location_on,
          maxLines: 2,
          controller: _addressController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an address';
            }
            return null;
          },
        ),
        _buildContactFields(),
        _buildLocationField(),
      ],
    );
  }

  Widget _buildDesktopTabletLayout() {
    return Column(
      children: [
        // First row: Name and Category
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildFormField(
                labelText: 'Name',
                hintText: 'Enter name',
                prefixIcon: Icons.business,
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: _buildCategoryDropdown()),
          ],
        ),
        const SizedBox(height: 16),
        // Description
        _buildFormField(
          labelText: 'Description',
          hintText: 'Enter description',
          prefixIcon: Icons.description,
          maxLines: 4,
          controller: _descriptionController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Address
        _buildFormField(
          labelText: 'Address',
          hintText: 'Enter full address',
          prefixIcon: Icons.location_on,
          maxLines: 2,
          controller: _addressController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an address';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Contact and Email
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildFormField(
                labelText: 'Contact Number',
                hintText: 'Enter contact number',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                controller: _contactController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a contact number';
                  }
                  // Add phone number validation if needed
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFormField(
                labelText: 'Email',
                hintText: 'Enter email',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildLocationField(),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category',
        hintText: 'Select category',
        prefixIcon: Icon(Icons.category_outlined, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.grey300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      items: _panchayatCategories
          .map<DropdownMenuItem<String>>(
            (category) => DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            ),
          )
          .toList(),
      onChanged: (String? value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a category';
        }
        return null;
      },
    );
  }

  Widget _buildFormField({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    int? maxLines = 1,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: Icon(prefixIcon, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.grey300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.grey300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  Widget _buildContactFields() {
    return Column(
      children: [
        _buildFormField(
          labelText: 'Contact Number',
          hintText: 'Enter contact number',
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
          controller: _contactController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a contact number';
            }
            // Add phone number validation if needed
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildFormField(
          labelText: 'Email',
          hintText: 'Enter email',
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          controller: _emailController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // State Dropdown
        DropdownButtonFormField<String>(
          value: _locationController.selectedState.value,
          decoration: InputDecoration(
            labelText: 'State',
            prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
          ),
          items: _locationController.statesList.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            _locationController.selectedState.value = newValue!;
            _locationController.selectedDistrict.value = null;
            _locationController.selectedTaluka.value = null;
            _locationController.selectedVillage.value = null;
            _locationController.loadDistricts(newValue);
          },
          validator: (value) => value == null ? 'Please select a state' : null,
        ),
        const SizedBox(height: AppSpacing.md),
        // District Dropdown
        DropdownButtonFormField<String>(
          value: _locationController.selectedDistrict.value,
          decoration: InputDecoration(
            labelText: 'District',
            prefixIcon: Icon(Icons.location_city_outlined, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
          ),
          items: _locationController.districtsList.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: _locationController.canSelectDistrict
              ? (String? newValue) {
                  _locationController.selectedDistrict.value = newValue!;
                  _locationController.selectedTaluka.value = null;
                  _locationController.selectedVillage.value = null;
                  _locationController.loadTalukas(
                    _locationController.selectedState.value!,
                    newValue,
                  );
                }
              : null,
          validator: (value) => value == null ? 'Please select a district' : null,
        ),
        const SizedBox(height: AppSpacing.md),
        // Taluka Dropdown
        DropdownButtonFormField<String>(
          value: _locationController.selectedTaluka.value,
          decoration: InputDecoration(
            labelText: 'Taluka',
            prefixIcon: Icon(Icons.location_city_outlined, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
          ),
          items: _locationController.talukasList.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: _locationController.canSelectTaluka
              ? (String? newValue) {
                  _locationController.selectedTaluka.value = newValue!;
                  _locationController.selectedVillage.value = null;
                  _locationController.loadVillages(
                    _locationController.selectedState.value!,
                    _locationController.selectedDistrict.value!,
                    newValue,
                  );
                }
              : null,
          validator: (value) => value == null ? 'Please select a taluka' : null,
        ),
        const SizedBox(height: AppSpacing.md),
        // Village Dropdown
        DropdownButtonFormField<String>(
          value: _locationController.selectedVillage.value,
          decoration: InputDecoration(
            labelText: 'Village',
            prefixIcon: Icon(Icons.home_outlined, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
          ),
          items: _locationController.villagesList.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: _locationController.canSelectVillage
              ? (String? newValue) {
                  _locationController.selectedVillage.value = newValue!;
                }
              : null,
          validator: (value) => value == null ? 'Please select a village' : null,
        ),
        const SizedBox(height: AppSpacing.md),

      ],
    ));
  }
}
