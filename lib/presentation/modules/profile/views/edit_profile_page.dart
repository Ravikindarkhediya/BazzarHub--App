import 'package:bazzar_hub_app/app/core/utils/app_spacing.dart';
import 'package:bazzar_hub_app/manager/session_manager.dart';
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
import 'dart:convert';

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
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _talukaController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  // Location data
  List<Map<String, dynamic>> _locationsData = [];
  List<String> _statesList = [];
  List<String> _districtsList = [];
  List<String> _talukasList = [];
  List<String> _villagesList = [];

  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedTaluka;
  String? _selectedVillage;

  bool _isLoadingDistricts = false;
  bool _isLoadingTalukas = false;
  bool _isLoadingVillages = false;

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
    _loadLocationsData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isInitialLoading = true);

    try {
      final user = await SessionManager().getUser();
      if (user != null) {
        _currentUser = user;
        _nameController.text = user.name;
        _emailController.text = user.email;
        _uploadedAvatarUrl = user.avatar;
        _phoneController.text = user.phone;
        _bioController.text = user.bio ?? '';
        _selectedGender = user.gender.isNotEmpty ? user.gender : null;

        _stateController.text = user.state ?? '';
        _districtController.text = user.district ?? '';
        _talukaController.text = user.taluka ?? '';
        _villageController.text = user.village ?? '';

        _selectedState = user.state;
        _selectedDistrict = user.district;
        _selectedTaluka = user.taluka;
        _selectedVillage = user.village;

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
      setState(() => _isInitialLoading = false);
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
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _uploadAvatarImage(File imageFile) async {
    setState(() => _isUploadingImage = true);

    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "myfile": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      final dio = Dio();
      final token = await SessionManager().getToken();

      final response = await dio.post(
        'http://192.168.2.210:3000/v1/common/upload',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'accept': 'application/json',
          },
        ),
      );

      if (response.data['status'] == true) {
        setState(() {
          _uploadedAvatarUrl = response.data['data']['url'] as String;
        });
        AppToast.showSuccess('Avatar uploaded successfully!');
      } else {
        throw Exception('Upload failed');
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      AppToast.showError('Failed to upload image');
      setState(() => _selectedAvatarImage = null);
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _pickAvatarFromCamera() async {
    HapticFeedback.mediumImpact();
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image != null) {
      final file = File(image.path);
      setState(() => _selectedAvatarImage = file);
      await _uploadAvatarImage(file);
    }
  }

  Future<void> _pickAvatarFromGallery() async {
    HapticFeedback.mediumImpact();
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image != null) {
      final file = File(image.path);
      setState(() => _selectedAvatarImage = file);
      await _uploadAvatarImage(file);
    }
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const Text('Update Avatar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _pickAvatarFromCamera();
                  },
                  child: const Column(children: [
                    Icon(Icons.camera_alt, size: 32, color: AppColors.primary),
                    SizedBox(height: 8),
                    Text('Camera'),
                  ]),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _pickAvatarFromGallery();
                  },
                  child: const Column(children: [
                    Icon(Icons.photo_library, size: 32, color: AppColors.primary),
                    SizedBox(height: 8),
                    Text('Gallery'),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isUploadingImage) {
      AppToast.showError('Please wait for image upload to complete');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final params = <String, dynamic>{
        'name': _nameController.text.trim(),
        if (_uploadedAvatarUrl != null && _uploadedAvatarUrl!.isNotEmpty) 'avatar': _uploadedAvatarUrl!,
        'phone': _phoneController.text.trim(),
        if (_selectedGender != null) 'gender': _selectedGender!,
        if (_dobController.text.isNotEmpty) 'dob': _dobController.text,
        'bio': _bioController.text.trim(),
        if (_selectedState != null) 'state': _selectedState!,
        if (_selectedDistrict != null) 'district': _selectedDistrict!,
        if (_selectedTaluka != null) 'taluka': _selectedTaluka!,
        if (_selectedVillage != null) 'village': _selectedVillage!,
      };

      final apiClient = await getApiClient();
      final response = await apiClient.updateUserProfile(params);

      if (response.data.status) {
        await SessionManager().saveUserData(response.data.data!);
        AppToast.showSuccess('Profile updated successfully');
        Get.back(result: true);
      } else {
        AppToast.showError(response.data.message ?? 'Update failed');
      }
    } on DioException catch (e) {
      AppToast.showError(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      AppToast.showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _dobController.dispose();
    _villageController.dispose();
    _talukaController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // LOCATION DATA LOADING
  // ─────────────────────────────────────────────────────────────
  Future<void> _loadLocationsData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/india_locations.json');
      _locationsData = List<Map<String, dynamic>>.from(json.decode(jsonString));

      final seen = <String>{};
      _statesList = _locationsData
          .map((e) => e['state'] as String)
          .where((s) => seen.add(s))
          .toList()
        ..sort();

      setState(() {});

      // Restore saved state and cascade
      if (_selectedState != null && _statesList.contains(_selectedState)) {
        await _loadDistricts(_selectedState!);
      }
    } catch (e) {
      debugPrint('Location load error: $e');
    }
  }

  Future<void> _loadDistricts(String state) async {
    setState(() => _isLoadingDistricts = true);
    _districtsList.clear();
    _talukasList.clear();
    _villagesList.clear();
    _selectedDistrict = null;
    _selectedTaluka = null;
    _selectedVillage = null;

    try {
      final stateData = _locationsData.firstWhere(
        (e) => e['state'] == state,
        orElse: () => <String, dynamic>{},
      );

      if (stateData.isNotEmpty) {
        final districts = stateData['districts'] as List;
        final seen = <String>{};
        _districtsList = districts
            .map<String>((d) => d['district'] as String)
            .where((d) => seen.add(d))
            .toList();
        _districtsList.sort();

        if (_selectedDistrict != null && _districtsList.contains(_selectedDistrict)) {
          await _loadTalukas(state, _selectedDistrict!);
        }
      }
    } catch (e) {
      debugPrint('Error loading districts: $e');
    } finally {
      setState(() => _isLoadingDistricts = false);
    }
  }

  Future<void> _loadTalukas(String state, String district) async {
    setState(() => _isLoadingTalukas = true);
    _talukasList.clear();
    _villagesList.clear();
    _selectedTaluka = null;
    _selectedVillage = null;

    try {
      final stateData = _locationsData.firstWhere((e) => e['state'] == state, orElse: () => {});
      final districtData = (stateData['districts'] as List?)
          ?.firstWhere((d) => d['district'] == district, orElse: () => {}) ?? {};

      if (districtData.isNotEmpty) {
        final subs = districtData['subDistricts'] as List;
        final seen = <String>{};
        _talukasList = subs
            .map((s) => s['subDistrict'] as String)
            .where((t) => seen.add(t))
            .toList()
          ..sort();

        if (_selectedTaluka != null && _talukasList.contains(_selectedTaluka)) {
          await _loadVillages(state, district, _selectedTaluka!);
        }
      }
    } finally {
      setState(() => _isLoadingTalukas = false);
    }
  }

  Future<void> _loadVillages(String state, String district, String taluka) async {
    setState(() => _isLoadingVillages = true);
    _villagesList.clear();
    _selectedVillage = null;

    try {
      final stateData = _locationsData.firstWhere((e) => e['state'] == state, orElse: () => {});
      final districtData = (stateData['districts'] as List?)
          ?.firstWhere((d) => d['district'] == district, orElse: () => {}) ?? {};
      final subData = (districtData['subDistricts'] as List?)
          ?.firstWhere((s) => s['subDistrict'] == taluka, orElse: () => {}) ?? {};

      if (subData.isNotEmpty) {
        final villages = subData['villages'] as List;
        final seen = <String>{};
        _villagesList = villages.map((v) => v.toString()).where((v) => seen.add(v)).toList()..sort();

        if (_villageController.text.isNotEmpty && _villagesList.contains(_villageController.text)) {
          _selectedVillage = _villageController.text;
        }
      }
    } finally {
      setState(() => _isLoadingVillages = false);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // SEARCHABLE BOTTOM SHEET FOR LOCATION PICKER
  // ─────────────────────────────────────────────────────────────
  void _showLocationPicker({
    required String title,
    required List<String> items,
    required String? current,
    required Function(String) onSelect,
  }) {
    String query = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateSheet) {
          List<String> filtered = items
              .where((item) => item.toLowerCase().contains(query.toLowerCase()))
              .toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                      Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search $title...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: AppColors.grey100,
                    ),
                    onChanged: (val) => setStateSheet(() => query = val),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('No items found'))
                      : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final item = filtered[i];
                      return ListTile(
                        title: Text(item),
                        trailing: current == item ? const Icon(Icons.check, color: AppColors.primary) : null,
                        onTap: () {
                          onSelect(item);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // UI WIDGETS
  // ─────────────────────────────────────────────────────────────
  Widget _buildLocationField({
    required String label,
    required String? value,
    required IconData icon,
    required bool enabled,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    String getPlaceholder() {
      switch (label.toLowerCase()) {
        case 'state':
          return 'Select State';
        case 'district':
          return 'Select District';
        case 'taluka':
          return 'Select Taluka';
        case 'village':
          return 'Select Village';
        default:
          return 'Select $label';
      }
    }

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: enabled ? AppColors.primary : AppColors.grey400, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value ?? getPlaceholder(),
                style: TextStyle(
                  fontSize: 15,
                  color: enabled
                      ? (value != null ? AppColors.textPrimary : AppColors.textSecondary.withOpacity(0.7))
                      : AppColors.textSecondary.withOpacity(0.5),
                  fontWeight: value != null ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (enabled)
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineEditField({
    required String fieldKey,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    String getHintText() {
      switch (fieldKey) {
        case 'name':
          return 'Enter your full name';
        case 'email':
          return 'Enter your email address';
        case 'phone':
          return 'Enter your phone number';
        case 'bio':
          return 'Tell us about yourself';
        default:
          return 'Enter $fieldKey';
      }
    }

    final isBio = fieldKey == 'bio';

    // Set field heights - bio is 70, all others are 60
    final fieldHeight = isBio ? 70.0 : 60.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      height: fieldHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon with centered alignment
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: isBio
                ? SizedBox(
                    height: 70,  // Bio field is taller
                    child: TextFormField(
                      controller: controller,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: getHintText(),
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.6),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      validator: validator,
                    ),
                  )
                : SizedBox(
                    height: 48, // Standard field height (60 - 12 for padding)
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextFormField(
                        controller: controller,
                        keyboardType: keyboardType,
                        maxLines: 1,
                        style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.3),
                        decoration: InputDecoration(
                          hintText: getHintText(),
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.6),
                            height: 1.3,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        validator: validator,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldRow({
    required Widget icon,
    required Widget field,
  }) {
    return SizedBox(
      height: 60,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Expanded(child: field),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineGenderField() {
    return _buildFieldRow(
      icon: const Icon(Icons.wc_outlined, color: AppColors.primary, size: 24),
      field: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: _selectedGender,
          hint: const Text('Select Gender', style: TextStyle(color: AppColors.textSecondary)),
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          items: _genderOptions.map<DropdownMenuItem<String>>((g) => DropdownMenuItem<String>(
            value: g,
            child: Text(g),
          )).toList(),
          onChanged: (String? val) {
            if (val != null) {
              setState(() => _selectedGender = val);
            }
          },
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        ),
      ),
    );
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
          margin: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,           // આ ખાસ જરૂરી છે
            constraints: const BoxConstraints(), // આ પણ જરૂરી છે
          ),
        ),
        title: const Text('Edit Profile', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: _isInitialLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.verticalSpaceMD,

              // Avatar
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
                          border: Border.all(color: AppColors.primary, width: 3),
                        ),
                        child: ClipOval(
                          child: _isUploadingImage
                              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                              : _uploadedAvatarUrl != null && _uploadedAvatarUrl!.isNotEmpty
                              ? Image.network(_uploadedAvatarUrl!, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 50))
                              : _selectedAvatarImage != null
                              ? Image.file(_selectedAvatarImage!, fit: BoxFit.cover)
                              : const Icon(Icons.person, size: 50, color: AppColors.grey400),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImagePickerBottomSheet,
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.verticalSpaceMD,

              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: AppColors.surface,
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Name
                    _buildInlineEditField(
                      fieldKey: 'name',
                      icon: Icons.person_outline,
                      controller: _nameController,
                      validator: (v) => v?.isEmpty ?? true ? 'Name is required' : null,
                    ),
                    const Divider(height: 1),

                    // Email
                    _buildInlineEditField(fieldKey: 'email', icon: Icons.email_outlined, controller: _emailController),
                    const Divider(height: 1),

                    // Phone
                    _buildInlineEditField(fieldKey: 'phone', icon: Icons.phone_outlined, controller: _phoneController),
                    const Divider(height: 1),

                    // Gender
                    _buildInlineGenderField(),
                    const Divider(height: 1),

                    // Date of Birth
                    _buildFieldRow(
                      icon: const Icon(Icons.cake_outlined, color: AppColors.primary, size: 24),
                      field: InkWell(
                        onTap: _selectDate,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _dobController.text.isEmpty ? 'Select your date of birth' : _dobController.text,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: _dobController.text.isEmpty
                                      ? AppColors.textSecondary.withOpacity(0.7)
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const Icon(Icons.calendar_today, size: 20, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1),

                    // Bio
                    _buildInlineEditField(
                      fieldKey: 'bio',
                      icon: Icons.description_outlined,
                      controller: _bioController,
                    ),
                    const Divider(height: 1),

                    // ────── LOCATION FIELDS ──────
                    _buildLocationField(
                      label: "State",
                      value: _selectedState,
                      icon: Icons.map_outlined,
                      enabled: true,
                      isLoading: false,
                      onTap: () => _showLocationPicker(
                        title: "Select State",
                        items: _statesList,
                        current: _selectedState,
                        onSelect: (val) {
                          setState(() {
                            _selectedState = val;
                            _stateController.text = val;
                            _selectedDistrict = _selectedTaluka = _selectedVillage = null;
                            _districtController.clear();
                            _talukaController.clear();
                            _villageController.clear();
                          });
                          _loadDistricts(val);
                        },
                      ),
                    ),
                    const Divider(height: 1),

                    _buildLocationField(
                      label: "District",
                      value: _selectedDistrict,
                      icon: Icons.location_city_outlined,
                      enabled: _selectedState != null,
                      isLoading: _isLoadingDistricts,
                      onTap: () => _showLocationPicker(
                        title: "Select District",
                        items: _districtsList,
                        current: _selectedDistrict,
                        onSelect: (val) {
                          setState(() {
                            _selectedDistrict = val;
                            _districtController.text = val;
                            _selectedTaluka = _selectedVillage = null;
                            _talukaController.clear();
                            _villageController.clear();
                          });
                          _loadTalukas(_selectedState!, val);
                        },
                      ),
                    ),
                    const Divider(height: 1),

                    _buildLocationField(
                      label: "Taluka",
                      value: _selectedTaluka,
                      icon: Icons.place_outlined,
                      enabled: _selectedDistrict != null,
                      isLoading: _isLoadingTalukas,
                      onTap: () => _showLocationPicker(
                        title: "Select Taluka",
                        items: _talukasList,
                        current: _selectedTaluka,
                        onSelect: (val) {
                          setState(() {
                            _selectedTaluka = val;
                            _talukaController.text = val;
                            _selectedVillage = null;
                            _villageController.clear();
                          });
                          _loadVillages(_selectedState!, _selectedDistrict!, val);
                        },
                      ),
                    ),
                    const Divider(height: 1),

                    _buildLocationField(
                      label: "Village",
                      value: _selectedVillage,
                      icon: Icons.house_outlined,
                      enabled: _selectedTaluka != null,
                      isLoading: _isLoadingVillages,
                      onTap: () => _showLocationPicker(
                        title: "Select Village",
                        items: _villagesList,
                        current: _selectedVillage,
                        onSelect: (val) {
                          setState(() {
                            _selectedVillage = val;
                            _villageController.text = val;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),

              AppSpacing.verticalSpaceXL,

              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: (_isLoading || _isUploadingImage) ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 10,
                  ),
                  child: _isLoading
                      ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Updating...', style: TextStyle(color: Colors.white, fontSize: 16)),
                    SizedBox(width: 12),
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                  ])
                      : const Text('Update Profile', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              AppSpacing.verticalSpaceMD,
            ],
          ),
        ),
      ),
    );
  }
}