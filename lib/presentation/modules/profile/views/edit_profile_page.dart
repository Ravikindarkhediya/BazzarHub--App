import 'package:bazzar_hub_app/app/core/utils/app_spacing.dart';
import 'package:bazzar_hub_app/app/core/utils/session_manager.dart';
import 'package:bazzar_hub_app/app/core/utils/utils.dart';
import 'package:bazzar_hub_app/app/data/constants/app_colors.dart';
import 'package:bazzar_hub_app/presentation/commons/dialogs/app_toasts.dart';
import 'package:bazzar_hub_app/presentation/services/api_service.dart';
import 'package:bazzar_hub_app/presentation/services/models/user/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isInitialLoading = true;
  bool _isUploadingImage = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _talukaController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  File? _selectedAvatarImage;
  String? _uploadedAvatarUrl;
  final ImagePicker _picker = ImagePicker();

  String? _selectedGender;
  UserModel? _currentUser;

  // Track which field is being edited
  String? _editingField;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isInitialLoading = true;
    });

    try {
      final user = await SessionManager().getUser();
      if (user != null) {
        _currentUser = user;
        _nameController.text = user.name;
        _emailController.text = user.email;
        _uploadedAvatarUrl = user.avatar;
        _phoneController.text = user.phone;
        _locationController.text = user.location;
        _bioController.text = user.bio;
        _selectedGender = user.gender.isNotEmpty ? user.gender : null;

        if (user.dob != null && user.dob!.isNotEmpty) {
          try {
            final date = DateTime.parse(user.dob!);
            _dobController.text = DateFormat('yyyy-MM-dd').format(date);
          } catch (e) {
            _dobController.text = user.dob!;
          }
        }
      }
    } catch (e) {
      AppToast.showError('Error loading user data');
    } finally {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dobController.text.isNotEmpty
          ? DateTime.tryParse(_dobController.text) ?? DateTime.now()
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _uploadAvatarImage(File imageFile) async {
    setState(() {
      _isUploadingImage = true;
    });

    try {
      final apiClient = await getApiClient();

      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "myfile": await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final dio = Dio();
      final session = await SessionManager().getToken();

      final response = await dio.post(
        'http://192.168.2.210:3000/v1/common/upload',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Authorization': 'Bearer $session',
            'accept': 'application/json',
          },
        ),
      );

      if (response.data['status'] == true) {
        setState(() {
          _uploadedAvatarUrl = response.data['data']['url'] as String? ?? '';
        });
        AppToast.showSuccess('Avatar uploaded successfully!');
      } else {
        AppToast.showError('Failed to upload avatar');
        setState(() {
          _selectedAvatarImage = null;
        });
      }
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      AppToast.showError('Error uploading image: $e');
      setState(() {
        _selectedAvatarImage = null;
      });
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _pickAvatarFromCamera() async {
    try {
      HapticFeedback.mediumImpact();
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        setState(() {
          _selectedAvatarImage = imageFile;
        });
        await _uploadAvatarImage(imageFile);
      }
    } catch (e) {
      debugPrint('Error picking avatar from camera: $e');
      AppToast.showError('Failed to capture image');
    }
  }

  Future<void> _pickAvatarFromGallery() async {
    try {
      HapticFeedback.mediumImpact();
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        setState(() {
          _selectedAvatarImage = imageFile;
        });
        await _uploadAvatarImage(imageFile);
      }
    } catch (e) {
      debugPrint('Error picking avatar from gallery: $e');
      AppToast.showError('Failed to select image');
    }
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor:AppColors.background,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Update Avatar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickAvatarFromCamera();
                    },
                    child: Column(
                      children: [
                        const Icon(
                          Icons.camera_alt,
                          size: 32,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Camera',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickAvatarFromGallery();
                    },
                    child: Column(
                      children: [
                        const Icon(
                          Icons.photo_library,
                          size: 32,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Gallery',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isUploadingImage) {
      AppToast.showError('Please wait for image upload to complete');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final params = <String, dynamic>{
        'name': _nameController.text.trim(),
        if (_uploadedAvatarUrl != null && _uploadedAvatarUrl!.isNotEmpty)
          'avatar': _uploadedAvatarUrl!,
        'phone': _phoneController.text.trim(),
        if (_selectedGender != null) 'gender': _selectedGender!,
        if (_dobController.text.isNotEmpty) 'dob': _dobController.text.trim(),
        'location': _locationController.text.trim(),
        'bio': _bioController.text.trim(),
      };

      final apiClient = await getApiClient();
      final response = await apiClient.updateUserProfile(params);

      if (response.data.status) {
        if (response.data.data != null) {
          await SessionManager().saveUserData(response.data.data!);
          AppToast.showSuccess('Profile updated successfully');
          Get.back(result: true);
        } else {
          AppToast.showError('Failed to update profile');
        }
      } else {
        AppToast.showError(
          response.data.message ?? 'Something went wrong, Please try again.',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Error updating profile';
      if (e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      AppToast.showError(errorMessage);
    } catch (error) {
      AppToast.showError('Error: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _dobController.dispose();
    _villageController.dispose();
    _talukaController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  String _getFieldPlaceholder(String fieldKey) {
    switch (fieldKey) {
      case 'name':
        return 'Name';
      case 'email':
        return 'Email';
      case 'phone':
        return 'Phone';
      case 'location':
        return 'Location';
      case 'village':
        return 'Village';
      case 'taluka':
        return 'Taluka';
      case 'district':
        return 'District';
      case 'state':
        return 'State';
      case 'bio':
        return 'Bio';
      default:
        return 'Enter details';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final horizontalPadding = isTablet ? AppSpacing.xl : AppSpacing.md;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.white,
            ),
          ),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isInitialLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: AppSpacing.md,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.verticalSpaceMD,

              // Avatar Image Section
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _showImagePickerBottomSheet,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 7,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _isUploadingImage
                              ? Container(
                            color: AppColors.grey200,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 3,
                              ),
                            ),
                          )
                              : _uploadedAvatarUrl != null &&
                              _uploadedAvatarUrl!.isNotEmpty
                              ? Image.network(
                            _uploadedAvatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.grey200,
                                child: const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: AppColors.grey400,
                                ),
                              );
                            },
                            loadingBuilder:
                                (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: AppColors.grey200,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                          )
                              : _selectedAvatarImage != null
                              ? Image.file(
                            _selectedAvatarImage!,
                            fit: BoxFit.cover,
                          )
                              : Container(
                            color: AppColors.grey200,
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.grey400,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _isUploadingImage
                            ? null
                            : _showImagePickerBottomSheet,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: AppColors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.verticalSpaceMD,

              // Card containing all form fields with inline editing
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: AppColors.surface,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    children: [
                      // Name Field - Inline Editable
                      SizedBox(height: 5,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: _buildInlineEditField(
                          fieldKey: 'name',
                          icon: Icons.person_outline,
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your full name";
                            }
                            if (value.length < 2) {
                              return "Name must be at least 2 characters";
                            }
                            return null;
                          },
                        ),
                      ),

                      const Divider(height: 8),

                      // Email Field - Inline Editable
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: _buildInlineEditField(
                          fieldKey: 'email',
                          icon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return "Enter a valid email address";
                              }
                            }
                            return null;
                          },
                        ),
                      ),

                      const Divider(height: 8),

                      // Phone Field - Inline Editable
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: _buildInlineEditField(
                          fieldKey: 'phone',
                          icon: Icons.phone_outlined,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (value.length < 10) {
                                return "Enter a valid phone number";
                              }
                            }
                            return null;
                          },
                        ),
                      ),

                      const Divider(height: 8),

                      // Gender Field - Inline Selectable
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: _buildInlineGenderField(),
                      ),

                      const Divider(height: 8),

                      // Date of Birth Field - Inline Selectable
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: _buildProfileListTile(
                          icon: Icons.cake_outlined,
                          subtitle: _dobController.text.isEmpty
                              ? "Not specified"
                              : _dobController.text,
                          onTap: _selectDate,
                        ),
                      ),

                      const Divider(height: 8),

                      // Location Field - Inline Editable
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: _buildInlineEditField(
                          fieldKey: 'location',
                          icon: Icons.location_on_outlined,
                          controller: _locationController,
                          keyboardType: TextInputType.streetAddress,
                        ),
                      ),

                      const Divider(height: 8),

                      // Bio Field - Inline Editable
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: _buildInlineEditField(
                          fieldKey: 'bio',
                          icon: Icons.description_outlined,
                          controller: _bioController,
                          keyboardType: TextInputType.multiline,
                          maxLines: 3,
                        ),
                      ),

                      const Divider(height: 8),

                      // Village Field - Inline Editable
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: _buildInlineEditField(
                          fieldKey: 'village',
                          icon: Icons.location_city_outlined,
                          controller: _villageController,
                          keyboardType: TextInputType.text,
                        ),
                      ),

                      const Divider(height: 8),

                      // Taluka Field - Inline Editable
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: _buildInlineEditField(
                          fieldKey: 'taluka',
                          icon: Icons.map_outlined,
                          controller: _talukaController,
                          keyboardType: TextInputType.text,
                        ),
                      ),

                      const Divider(height: 8),

                      // District Field - Inline Editable
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: _buildInlineEditField(
                          fieldKey: 'district',
                          icon: Icons.apartment_outlined,
                          controller: _districtController,
                          keyboardType: TextInputType.text,
                        ),
                      ),

                      const Divider(height: 8),

                      // State Field - Inline Editable
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: _buildInlineEditField(
                          fieldKey: 'state',
                          icon: Icons.public_outlined,
                          controller: _stateController,
                          keyboardType: TextInputType.text,
                        ),
                      ),

                      SizedBox(height: 5,)
                    ],
                  ),
                ),
              ),

              AppSpacing.verticalSpaceXL,

              // Update Button
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed:
                  (_isLoading || _isUploadingImage) ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.grey400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 12,
                    shadowColor: AppColors.primary.withOpacity(0.7),
                  ),
                  child: _isLoading
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Updating...',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10),
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white),
                        ),
                      ),
                    ],
                  )
                      : const Text(
                    "Update Profile",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              AppSpacing.verticalSpaceMD,
            ],
          ),
        ),
      ),
    );
  }

  // Build inline editable field
      Widget _buildInlineEditField({
    required String fieldKey,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final isEditing = _editingField == fieldKey;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          // Icon
          Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),

          // Content - Either text or text field
          Expanded(
            child: isEditing
                ? TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              autofocus: true,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),

              // decoration: InputDecoration(
              //   border: OutlineInputBorder(
              //     borderRadius: BorderRadius.circular(8),
              //     borderSide: const BorderSide(color: AppColors.primary),
              //   ),
              //   focusedBorder: OutlineInputBorder(
              //     borderRadius: BorderRadius.circular(8),
              //     borderSide: const BorderSide(
              //       color: AppColors.primary,
              //       width: 2,
              //     ),
              //   ),
              //   contentPadding: const EdgeInsets.symmetric(
              //     horizontal: 12,
              //     vertical: 8,
              //   ),
              //   isDense: true,
              // ),
              validator: validator,
            )
                : GestureDetector(
              onTap: () {
                setState(() {
                  _editingField = fieldKey;
                });
              },
              child: Text(
                controller.text.isEmpty
                    ? _getFieldPlaceholder(fieldKey)
                    : controller.text,
                style: TextStyle(
                  fontSize: 15,
                  color: controller.text.isEmpty
                      ? AppColors.textSecondary.withOpacity(0.6)
                      : AppColors.textPrimary,
                ),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Action Icon
        ],
      ),
    );
  }

  // Build inline gender selector
  // Build inline gender dropdown selector
  Widget _buildInlineGenderField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          // Icon
          const Icon(
            Icons.wc_outlined,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),

          // Dropdown Content
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedGender,
              hint: Text(
                "Select gender",
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary.withOpacity(0.6),
                ),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
              icon: const Icon(
                Icons.arrow_drop_down,
                color: AppColors.textSecondary,
              ),
              dropdownColor: AppColors.surface,
              isExpanded: true,
              items: _genderOptions.map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(
                    gender,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
              validator: (value) {
                // Optional: Add validation if gender is required
                // if (value == null || value.isEmpty) {
                //   return "Please select your gender";
                // }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }


  // Build regular list tile (for date picker) - WITHOUT title and WITHOUT trailing pencil icon
  Widget _buildProfileListTile({
    required IconData icon,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
