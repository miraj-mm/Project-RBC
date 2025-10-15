import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Mohammed Rafeek');
  final _emailController = TextEditingController(text: 'mohammed.rafeek@example.com');
  final _phoneController = TextEditingController(text: '+8801700000000');
  final _addressController = TextEditingController(text: 'Dhaka, Bangladesh');
  final _emergencyContactController = TextEditingController(text: '+8801700000001');
  
  String _selectedBloodGroup = 'A+';
  String _selectedGender = 'Male';
  DateTime? _selectedDateOfBirth;
  bool _isLoading = false;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              'Save',
              style: TextStyle(
                color: _isLoading ? AppColors.getTextSecondaryColor(context) : AppColors.primaryRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.paddingL),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.getBackgroundColor(context),
                          child: Icon(
                            Icons.person,
                            color: AppColors.getTextSecondaryColor(context),
                            size: 50,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _changeProfilePicture,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryRed,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: AppColors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    Text(
                      'Tap camera icon to change photo',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextSecondaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.paddingM),

              // Personal Information
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingM),

                    // Full Name
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSizes.paddingM),

                    // Email
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSizes.paddingM),

                    // Phone
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSizes.paddingM),

                    // Blood Group
                    Text(
                      'Blood Group',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    DropdownButtonFormField<String>(
                      value: _selectedBloodGroup,
                      onChanged: (value) {
                        setState(() {
                          _selectedBloodGroup = value!;
                        });
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.bloodtype,
                          color: _getBloodGroupColor(),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                          borderSide: const BorderSide(color: AppColors.inputBorder),
                        ),
                        contentPadding: const EdgeInsets.all(AppSizes.paddingM),
                      ),
                      items: _bloodGroups.map((bloodGroup) {
                        return DropdownMenuItem<String>(
                          value: bloodGroup,
                          child: Text(bloodGroup),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppSizes.paddingM),

                    // Gender
                    Text(
                      'Gender',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person,
                          color: AppColors.getTextSecondaryColor(context),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                          borderSide: const BorderSide(color: AppColors.inputBorder),
                        ),
                        contentPadding: const EdgeInsets.all(AppSizes.paddingM),
                      ),
                      items: _genders.map((gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppSizes.paddingM),

                    // Date of Birth
                    Text(
                      'Date of Birth',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    GestureDetector(
                      onTap: _selectDateOfBirth,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.inputBorder),
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: AppColors.getTextSecondaryColor(context),
                              size: AppSizes.iconS,
                            ),
                            const SizedBox(width: AppSizes.paddingM),
                            Text(
                              _selectedDateOfBirth != null
                                  ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                                  : 'Select date of birth',
                              style: TextStyle(
                                color: _selectedDateOfBirth != null
                                    ? AppColors.textPrimary
                                    : AppColors.getTextSecondaryColor(context),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSizes.paddingM),

                    // Address
                    _buildTextField(
                      controller: _addressController,
                      label: 'Address',
                      icon: Icons.location_on,
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.paddingM),

              // Emergency Contact
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Contact',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingM),

                    _buildTextField(
                      controller: _emergencyContactController,
                      label: 'Emergency Contact Number',
                      icon: Icons.emergency,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter emergency contact number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.paddingXL),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingL),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        )
                      : Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: AppSizes.paddingM),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: AppColors.getTextSecondaryColor(context),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            contentPadding: const EdgeInsets.all(AppSizes.paddingM),
          ),
        ),
      ],
    );
  }

  Color _getBloodGroupColor() {
    switch (_selectedBloodGroup) {
      case 'A+':
      case 'A-':
        return AppColors.bloodGroupA;
      case 'B+':
      case 'B-':
        return AppColors.bloodGroupB;
      case 'AB+':
      case 'AB-':
        return AppColors.bloodGroupAB;
      case 'O+':
      case 'O-':
        return AppColors.bloodGroupO;
      default:
        return AppColors.primaryRed;
    }
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(1990),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  void _changeProfilePicture() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                // Implement camera functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Camera functionality would be implemented here'),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                // Implement gallery functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gallery functionality would be implemented here'),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel),
              title: Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }
}
