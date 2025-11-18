import 'package:bazzar_hub_app/app/core/utils/app_spacing.dart';
import 'package:bazzar_hub_app/app/core/utils/session_manager.dart';
import 'package:bazzar_hub_app/app/core/utils/utils.dart';
import 'package:bazzar_hub_app/app/data/constants/app_colors.dart';
import 'package:bazzar_hub_app/presentation/commons/dialogs/app_toasts.dart';
import 'package:bazzar_hub_app/presentation/modules/auth/widget/common_widget.dart';
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
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  File? _selectedAvatarImage;
  String? _uploadedAvatarUrl;
  final ImagePicker _picker = ImagePicker();

  String? _selectedGender;
  UserModel? _currentUser;

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

  /// Upload image to common upload URL
  Future<void> _uploadAvatarImage(File imageFile) async {
    setState(() {
      _isUploadingImage = true;
    });

    try {
      final apiClient = await getApiClient();

      // Create FormData for image upload
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "myfile": await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      // REAL UPLOAD CODE - Using your upload API
      final dio = Dio();

      // Get auth token from session
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

  /// Pick image from camera for avatar
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
        // Upload image immediately after selection
        await _uploadAvatarImage(imageFile);
      }
    } catch (e) {
      debugPrint('Error picking avatar from camera: $e');
      AppToast.showError('Failed to capture image');
    }
  }

  /// Pick image from gallery for avatar
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
        // Upload image immediately after selection
        await _uploadAvatarImage(imageFile);
      }
    } catch (e) {
      debugPrint('Error picking avatar from gallery: $e');
      AppToast.showError('Failed to select image');
    }
  }

  /// Show image picker bottom sheet
  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
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
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 32,
                            color: AppColors.primary,
                          ),
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
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: const Icon(
                            Icons.photo_library,
                            size: 32,
                            color: AppColors.primary,
                          ),
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
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final horizontalPadding = isTablet ? AppSpacing.xl : AppSpacing.md;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.white,
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
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
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
                              : _uploadedAvatarUrl != null && _uploadedAvatarUrl!.isNotEmpty
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
                            loadingBuilder: (context, child, loadingProgress) {
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
                        onTap: _isUploadingImage ? null : _showImagePickerBottomSheet,
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

              AppSpacing.verticalSpaceSM,

              Center(
                child: Text(
                  _isUploadingImage
                      ? 'Uploading image...'
                      : 'Tap to change avatar',
                  style: TextStyle(
                    color: _isUploadingImage ? AppColors.primary : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: _isUploadingImage ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),

              AppSpacing.verticalSpaceLG,

              // Name Field
              CommonWidget().buildTextField(
                label: "Full Name",
                controller: _nameController,
                icon: Icons.person_outline,
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

              AppSpacing.verticalSpaceMD,

              // Phone Field
              CommonWidget().buildTextField(
                label: "Phone Number",
                controller: _phoneController,
                icon: Icons.phone_outlined,
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

              AppSpacing.verticalSpaceMD,

              // Gender Dropdown
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  labelText: "Gender",
                  labelStyle: const TextStyle(color: AppColors.primary),
                  prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.white.withOpacity(0.1),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.white.withOpacity(0.4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.primary.withOpacity(0.8),
                      width: 1.5,
                    ),
                  ),
                ),
                items: _genderOptions.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender,style: TextStyle(color: AppColors.primary),),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
              ),

              AppSpacing.verticalSpaceMD,

              // Date of Birth Field
              TextFormField(
                controller: _dobController,
                readOnly: true,
                onTap: _selectDate,
                decoration: InputDecoration(
                  labelText: "Date of Birth",
                  labelStyle: const TextStyle(color: AppColors.primary),
                  prefixIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
                  suffixIcon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.white.withOpacity(0.1),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.white.withOpacity(0.4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.primary.withOpacity(0.8),
                      width: 1.5,
                    ),
                  ),
                ),
                style: const TextStyle(fontSize: 16, color: AppColors.primary),
              ),

              AppSpacing.verticalSpaceMD,

              // Location Field
              CommonWidget().buildTextField(
                label: "Location",
                controller: _locationController,
                icon: Icons.location_on_outlined,
                keyboardType: TextInputType.streetAddress,
                validator: (value) {
                  return null;
                },
              ),

              AppSpacing.verticalSpaceMD,

              // Bio Field
              TextFormField(
                controller: _bioController,
                maxLines: 4,
                minLines: 3,
                decoration: InputDecoration(
                  labelText: "Bio",
                  labelStyle: const TextStyle(color: AppColors.primary),
                  prefixIcon: const Icon(Icons.description_outlined, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.white.withOpacity(0.1),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.white.withOpacity(0.4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.primary.withOpacity(0.8),
                      width: 1.5,
                    ),
                  ),
                ),
                style: const TextStyle(fontSize: 16, color: AppColors.primary),
                validator: (value) {
                  return null;
                },
              ),

              AppSpacing.verticalSpaceXL,

              // Update Button
              // Update Button
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: (_isLoading || _isUploadingImage) ? null : _updateProfile,
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
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                      ),
                    ],
                  )
                      : const Text(
                    "Update",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              AppSpacing.verticalSpaceLG,
            ],
          ),
        ),
      ),
    );
  }
}

