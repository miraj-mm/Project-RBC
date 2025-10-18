import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/core.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  final String? verifiedEmail; // Email from OTP verification
  
  const SignUpScreen({super.key, this.verifiedEmail});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _lastDonationController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;
  String? _selectedGender;
  String? _selectedBloodGroup;
  DateTime? _lastDonationDate;
  File? _profileImage;
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill email if provided from OTP verification
    if (widget.verifiedEmail != null) {
      _emailController.text = widget.verifiedEmail!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _lastDonationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.background,
      appBar: const AppTopBar(title: AppStrings.signUp),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Text
              Text(
                AppStrings.enterDetailsBelow,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSizes.paddingXL),
              
              // Profile Picture Section (Optional)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.paddingL),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.darkCard : AppColors.white,
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
                          backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.background,
                          backgroundImage: _profileImage != null 
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? Icon(
                                  Icons.person,
                                  color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                  size: 50,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showImageSourceDialog,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryRed,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
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
                      _profileImage == null 
                          ? 'Add Profile Picture (Optional)'
                          : 'Change Profile Picture',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSizes.paddingL),
              
              // Sign Up Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(
                        color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: AppStrings.name,
                        hintText: 'Enter your full name',
                        prefixIcon: Icon(
                          Icons.person,
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        labelStyle: TextStyle(
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        hintStyle: TextStyle(
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppSizes.paddingM),
                    
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: TextStyle(
                        color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: AppStrings.password,
                        hintText: AppStrings.enterPassword,
                        prefixIcon: Icon(
                          Icons.lock,
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        labelStyle: TextStyle(
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        hintStyle: TextStyle(
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible 
                                ? Icons.visibility 
                                : Icons.visibility_off,
                            color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppSizes.paddingM),
                    
                    // Mobile Number Field
                    TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(
                        color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: AppStrings.mobileNumber,
                        hintText: 'Enter your mobile number',
                        prefixIcon: Icon(
                          Icons.phone,
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        labelStyle: TextStyle(
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        hintStyle: TextStyle(
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your mobile number';
                        }
                        if (value.length < 10) {
                          return 'Please enter a valid mobile number';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppSizes.paddingM),
                    
                    // Email Field (Read-only if verified)
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      readOnly: widget.verifiedEmail != null, // Make read-only if verified
                      style: TextStyle(
                        color: widget.verifiedEmail != null 
                          ? (isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary)
                          : (isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary),
                      ),
                      decoration: InputDecoration(
                        labelText: AppStrings.emailId,
                        hintText: 'Enter your email address',
                        prefixIcon: Icon(
                          Icons.email,
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        labelStyle: TextStyle(
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        hintStyle: TextStyle(
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        filled: widget.verifiedEmail != null, // Grey background if verified
                        fillColor: widget.verifiedEmail != null 
                          ? (isDarkMode ? AppColors.darkBorder.withOpacity(0.3) : Colors.grey[200])
                          : null,
                        suffixIcon: widget.verifiedEmail != null 
                          ? const Icon(Icons.check_circle, color: AppColors.success)
                          : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.toLowerCase().endsWith('@iut-dhaka.edu')) {
                          return 'Please use your IUT email (@iut-dhaka.edu)';
                        }
                        if (!RegExp(r'^[\w-\.]+@iut-dhaka\.edu$').hasMatch(value.toLowerCase())) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppSizes.paddingM),
                    
                    // Gender and Age Row
                    Row(
                      children: [
                        // Gender Dropdown
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedGender,
                            style: TextStyle(
                              color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              labelText: AppStrings.gender,
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                              labelStyle: TextStyle(
                                color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                            ),
                            dropdownColor: isDarkMode ? AppColors.darkCard : AppColors.cardBackground,
                            items: _genders.map((gender) {
                              return DropdownMenuItem(
                                value: gender,
                                child: Text(
                                  gender,
                                  style: TextStyle(
                                    color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select gender';
                              }
                              return null;
                            },
                          ),
                        ),
                        
                        const SizedBox(width: AppSizes.paddingM),
                        
                        // Age Field
                        Expanded(
                          child: TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              labelText: AppStrings.age,
                              hintText: '25',
                              prefixIcon: Icon(
                                Icons.cake,
                                color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                              labelStyle: TextStyle(
                                color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                              hintStyle: TextStyle(
                                color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter age';
                              }
                              final age = int.tryParse(value);
                              if (age == null || age < 18 || age > 65) {
                                return 'Age must be 18-65';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSizes.paddingM),
                    
                    // Blood Group Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedBloodGroup,
                      style: TextStyle(
                        color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: AppStrings.bloodGroup,
                        prefixIcon: Icon(
                          Icons.bloodtype,
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        labelStyle: TextStyle(
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                      dropdownColor: isDarkMode ? AppColors.darkCard : AppColors.cardBackground,
                      items: _bloodGroups.map((bloodGroup) {
                        Color bgColor = _getBloodGroupColor(bloodGroup);
                        return DropdownMenuItem(
                          value: bloodGroup,
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    bloodGroup,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSizes.paddingS),
                              Text(bloodGroup),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBloodGroup = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select blood group';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppSizes.paddingM),
                    
                    // Last Blood Donation Date
                    TextFormField(
                      controller: _lastDonationController,
                      readOnly: true,
                      style: TextStyle(
                        color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: AppStrings.lastBloodDonationDate,
                        hintText: '16 March 2020',
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        suffixIcon: Icon(
                          Icons.arrow_drop_down,
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        labelStyle: TextStyle(
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        hintStyle: TextStyle(
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                      onTap: _selectLastDonationDate,
                    ),
                    
                    const SizedBox(height: AppSizes.paddingL),
                    
                    // Terms and Conditions
                    Row(
                      children: [
                        Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                          },
                          activeColor: AppColors.primaryRed,
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: '${AppStrings.iAgree} ',
                              style: TextStyle(color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary),
                              children: [
                                TextSpan(
                                  text: AppStrings.termsConditions,
                                  style: TextStyle(
                                    color: AppColors.primaryRed,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSizes.paddingXL),
                    
                    // Sign Up Button
                    ElevatedButton(
                      onPressed: (_isLoading || !_agreeToTerms) ? null : _handleSignUp,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                              ),
                            )
                          : const Text(
                              AppStrings.signUpButton,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBloodGroupColor(String bloodGroup) {
    switch (bloodGroup) {
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

  void _selectLastDonationDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lastDonationDate ?? DateTime.now().subtract(const Duration(days: 90)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primaryRed,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _lastDonationDate = picked;
        _lastDonationController.text = DateFormat('dd MMMM yyyy').format(picked);
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_profileImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text('Remove Photo', style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _profileImage = null;
                  });
                },
              ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<String?> _uploadProfilePicture(String userId) async {
    if (_profileImage == null) return null;

    try {
      final fileName = 'profile_$userId.jpg';
      final filePath = '$userId/$fileName';

      // Read file as bytes
      final fileBytes = await _profileImage!.readAsBytes();

      // Upload to Supabase Storage (will overwrite if exists)
      await SupabaseService.storage
          .from('profile-pictures')
          .uploadBinary(
            filePath,
            fileBytes,
          );

      // Get public URL
      final publicUrl = SupabaseService.storage
          .from('profile-pictures')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      rethrow;
    }
  }

  void _handleSignUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // First create the auth account to get the user ID
        final email = _emailController.text.trim();
        final password = _passwordController.text;
        
        // Get current user (who was authenticated via OTP)
        final currentUser = SupabaseService.currentUser;
        if (currentUser == null) {
          throw Exception('No authenticated user found');
        }

        // Upload profile picture if selected
        String? profilePictureUrl;
        if (_profileImage != null) {
          try {
            profilePictureUrl = await _uploadProfilePicture(currentUser.id);
            debugPrint('✅ Profile picture uploaded: $profilePictureUrl');
          } catch (e) {
            debugPrint('⚠️ Failed to upload profile picture: $e');
            // Continue even if upload fails
          }
        }

        // Prepare user data with profile picture URL
        final userData = {
          'name': _nameController.text.trim(),
          'phone': _mobileController.text.trim(),
          'age': int.parse(_ageController.text),
          'gender': _selectedGender,
          'blood_group': _selectedBloodGroup,
          'last_donation_date': _lastDonationDate?.toIso8601String(),
          if (profilePictureUrl != null) 'profile_picture_url': profilePictureUrl,
        };

        // Sign up with email and password (this will create the DB entry)
        await ref.read(authStateProvider.notifier).signUpWithEmailPassword(
          email: email,
          password: password,
          userData: userData,
        );
        
        // Sign out to force user to login with credentials
        await ref.read(authStateProvider.notifier).signOut();
        
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully! Please login with your credentials.'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 5),
            ),
          );
          
          // Navigate to login
          context.go(AppRoutes.login);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign up failed: ${e.toString()}'),
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
  }
}


