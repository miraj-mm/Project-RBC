import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../providers/blood_request_provider.dart';

class CreateBloodRequestScreen extends ConsumerStatefulWidget {
  const CreateBloodRequestScreen({super.key});

  @override
  ConsumerState<CreateBloodRequestScreen> createState() => _CreateBloodRequestScreenState();
}

class _CreateBloodRequestScreenState extends ConsumerState<CreateBloodRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _medicalConditionController = TextEditingController();
  final _hospitalNameController = TextEditingController();
  final _hospitalAddressController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _byStanderController = TextEditingController();
  final _byStanderContactController = TextEditingController();
  final _additionalNotesController = TextEditingController();

  String _selectedBloodGroup = 'A+';
  int _unitsRequired = 1;
  BloodRequestPriority _selectedPriority = BloodRequestPriority.normal;
  DateTime? _requiredByDate;
  TimeOfDay? _requiredByTime;
  bool _isNgoRequest = false;
  bool _isLoading = false;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Request Blood Donation',
          style: TextStyle(
            color: AppColors.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.getSurfaceColor(context),
        foregroundColor: AppColors.getTextPrimaryColor(context),
        iconTheme: IconThemeData(
          color: AppColors.getTextPrimaryColor(context),
        ),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitRequest,
            child: Text(
              'Submit',
              style: TextStyle(
                color: _isLoading ? AppColors.getTextSecondaryColor(context) : AppColors.primaryRed,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emergency Notice
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(
                    color: AppColors.error.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.emergency,
                      color: AppColors.error,
                      size: AppSizes.iconS,
                    ),
                    SizedBox(width: AppSizes.paddingS),
                    Expanded(
                      child: Text(
                        'For life-threatening emergencies, please call emergency services immediately: 999',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.paddingL),

              // Patient Information Section
              _buildSection(
                title: 'Patient Information',
                icon: Icons.person,
                children: [
                  _buildTextField(
                    controller: _patientNameController,
                    label: 'Patient Name',
                    hint: 'Enter patient\'s full name',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter patient name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSizes.paddingM),

                  _buildTextField(
                    controller: _medicalConditionController,
                    label: 'Medical Condition',
                    hint: 'e.g., Surgery, Accident, Thalassemia',
                    icon: Icons.medical_services,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter medical condition';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSizes.paddingM),

                  // Blood Group and Units Required Row
                  Row(
                    children: [
                      // Blood Group
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Blood Group *',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.getTextPrimaryColor(context),
                              ),
                            ),
                            const SizedBox(height: AppSizes.paddingS),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedBloodGroup,
                              onChanged: (value) {
                                setState(() {
                                  _selectedBloodGroup = value!;
                                });
                              },
                              dropdownColor: AppColors.getCardBackgroundColor(context),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.bloodtype,
                                  color: _getBloodGroupColor(),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                                  borderSide: BorderSide(color: AppColors.getBorderColor(context)),
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
                          ],
                        ),
                      ),

                      const SizedBox(width: AppSizes.paddingM),

                      // Units Required
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Units Required *',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.getTextPrimaryColor(context),
                              ),
                            ),
                            const SizedBox(height: AppSizes.paddingS),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.getBorderColor(context)),
                                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: _unitsRequired > 1 ? () {
                                      setState(() {
                                        _unitsRequired--;
                                      });
                                    } : null,
                                    icon: const Icon(Icons.remove),
                                    color: AppColors.primaryRed,
                                  ),
                                  Expanded(
                                    child: Text(
                                      '$_unitsRequired',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.getTextPrimaryColor(context),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _unitsRequired < 10 ? () {
                                      setState(() {
                                        _unitsRequired++;
                                      });
                                    } : null,
                                    icon: const Icon(Icons.add),
                                    color: AppColors.primaryRed,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.paddingM),

                  // Priority Level
                  Text(
                    'Priority Level *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getTextPrimaryColor(context),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingS),
                  Row(
                    children: [
                      _buildPriorityChip(
                        label: 'Normal',
                        priority: BloodRequestPriority.normal,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: AppSizes.paddingS),
                      _buildPriorityChip(
                        label: 'Urgent',
                        priority: BloodRequestPriority.urgent,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: AppSizes.paddingS),
                      _buildPriorityChip(
                        label: 'Critical',
                        priority: BloodRequestPriority.critical,
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.paddingL),

              // Hospital Information Section
              _buildSection(
                title: 'Hospital Information',
                icon: Icons.local_hospital,
                children: [
                  _buildTextField(
                    controller: _hospitalNameController,
                    label: 'Hospital Name',
                    hint: 'Enter hospital name',
                    icon: Icons.local_hospital,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter hospital name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSizes.paddingM),

                  _buildTextField(
                    controller: _hospitalAddressController,
                    label: 'Hospital Address',
                    hint: 'Enter complete hospital address',
                    icon: Icons.location_on,
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter hospital address';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.paddingL),

              // Contact Information Section
              _buildSection(
                title: 'Contact Information',
                icon: Icons.phone,
                children: [
                  _buildTextField(
                    controller: _contactNumberController,
                    label: 'Primary Contact Number',
                    hint: '+8801XXXXXXXXX',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter contact number';
                      }
                      if (value.length < 11) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSizes.paddingM),

                  _buildTextField(
                    controller: _byStanderController,
                    label: 'Bystander Name (Optional)',
                    hint: 'Name of person accompanying patient',
                    icon: Icons.person_add,
                  ),

                  const SizedBox(height: AppSizes.paddingM),

                  _buildTextField(
                    controller: _byStanderContactController,
                    label: 'Bystander Contact (Optional)',
                    hint: 'Alternative contact number',
                    icon: Icons.phone_android,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.paddingL),

              // Timeline Section
              _buildSection(
                title: 'Required Timeline',
                icon: Icons.schedule,
                children: [
                  // Required By Date
                  Text(
                    'Required By Date *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getTextPrimaryColor(context),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingS),
                  GestureDetector(
                    onTap: _selectRequiredDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.getBorderColor(context)),
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
                            _requiredByDate != null
                                ? '${_requiredByDate!.day}/${_requiredByDate!.month}/${_requiredByDate!.year}'
                                : 'Select required date',
                            style: TextStyle(
                              color: _requiredByDate != null
                                  ? AppColors.getTextPrimaryColor(context)
                                  : AppColors.getTextSecondaryColor(context),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.paddingM),

                  // Required By Time
                  Text(
                    'Required By Time (Optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getTextPrimaryColor(context),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingS),
                  GestureDetector(
                    onTap: _selectRequiredTime,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.getBorderColor(context)),
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: AppColors.getTextSecondaryColor(context),
                            size: AppSizes.iconS,
                          ),
                          const SizedBox(width: AppSizes.paddingM),
                          Text(
                            _requiredByTime != null
                                ? _requiredByTime!.format(context)
                                : 'Select preferred time',
                            style: TextStyle(
                              color: _requiredByTime != null
                                  ? AppColors.getTextPrimaryColor(context)
                                  : AppColors.getTextSecondaryColor(context),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.paddingL),

              // Additional Information Section
              _buildSection(
                title: 'Additional Information',
                icon: Icons.note,
                children: [
                  _buildTextField(
                    controller: _additionalNotesController,
                    label: 'Additional Notes (Optional)',
                    hint: 'Any special requirements or additional information',
                    icon: Icons.note_add,
                    maxLines: 3,
                  ),

                  const SizedBox(height: AppSizes.paddingM),

                  // NGO Request Toggle
                  CheckboxListTile(
                    value: _isNgoRequest,
                    onChanged: (value) {
                      setState(() {
                        _isNgoRequest = value ?? false;
                      });
                    },
                    title: Text(
                      'This is an NGO request',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.getTextPrimaryColor(context),
                      ),
                    ),
                    subtitle: Text(
                      'Check if this request is being made on behalf of an NGO or organization',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextSecondaryColor(context),
                      ),
                    ),
                    activeColor: AppColors.primaryRed,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.paddingXL),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRequest,
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
                      : const Text(
                          'Submit Blood Request',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: AppSizes.paddingM),

              // Disclaimer
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                          size: AppSizes.iconS,
                        ),
                        SizedBox(width: AppSizes.paddingS),
                        Text(
                          'Important Information',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.paddingS),
                    Text(
                      '• Your request will be shared with registered donors\n'
                      '• Ensure all information is accurate and up-to-date\n'
                      '• You will receive notifications when donors respond\n'
                      '• For emergencies, always contact medical services first',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextSecondaryColor(context),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.paddingXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(context),
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
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primaryRed,
                size: AppSizes.iconM,
              ),
              const SizedBox(width: AppSizes.paddingS),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
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
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.getTextPrimaryColor(context),
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          style: TextStyle(color: AppColors.getTextPrimaryColor(context)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.getTextSecondaryColor(context)),
            prefixIcon: Icon(
              icon,
              color: AppColors.getTextSecondaryColor(context),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
              borderSide: BorderSide(color: AppColors.getBorderColor(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
              borderSide: BorderSide(color: AppColors.getBorderColor(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
              borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
            ),
            contentPadding: const EdgeInsets.all(AppSizes.paddingM),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityChip({
    required String label,
    required BloodRequestPriority priority,
    required Color color,
  }) {
    final isSelected = _selectedPriority == priority;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPriority = priority;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.paddingS,
            horizontal: AppSizes.paddingM,
          ),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            border: Border.all(
              color: color,
              width: 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.white : color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
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

  Future<void> _selectRequiredDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _requiredByDate = picked;
      });
    }
  }

  Future<void> _selectRequiredTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _requiredByTime = picked;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Ensure user is authenticated
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to submit a blood request.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_requiredByDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select required date'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch requester name and phone from users table
      final userResponse = await SupabaseService.from('users')
          .select('name, phone')
          .eq('id', userId)
          .single();

      final requesterName = userResponse['name'] as String? ?? 'Unknown';
      final requesterPhone = userResponse['phone'] as String? ?? _contactNumberController.text.trim();

      // Combine date and time
      DateTime requiredBy = _requiredByDate!;
      if (_requiredByTime != null) {
        requiredBy = DateTime(
          _requiredByDate!.year,
          _requiredByDate!.month,
          _requiredByDate!.day,
          _requiredByTime!.hour,
          _requiredByTime!.minute,
        );
      }

      // Create blood request (without id, let DB generate)
      final bloodRequest = BloodRequestModel(
        id: '', // Placeholder; DB will generate
        requesterId: userId,
        requesterName: requesterName,
        requesterPhone: requesterPhone,
        patientName: _patientNameController.text.trim(),
        bloodGroup: _selectedBloodGroup,
        unitsRequired: _unitsRequired,
        medicalCondition: _medicalConditionController.text.trim(),
        hospitalName: _hospitalNameController.text.trim(),
        hospitalAddress: _hospitalAddressController.text.trim(),
        contactNumber: requesterPhone,
        byStander: _byStanderController.text.trim().isNotEmpty ? _byStanderController.text.trim() : null,
        byStanderContact: _byStanderContactController.text.trim().isNotEmpty ? _byStanderContactController.text.trim() : null,
        status: BloodRequestStatus.active,
        priority: _selectedPriority,
        requiredBy: requiredBy,
        additionalNotes: _additionalNotesController.text.trim().isNotEmpty ? _additionalNotesController.text.trim() : null,
        isNgoRequest: _isNgoRequest,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Submit to provider/database (uses toJsonForInsert)
      await ref.read(bloodRequestProvider.notifier).createBloodRequest(bloodRequest);

      if (mounted) {
        // Show success dialog
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit request: ${e.toString()}'),
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.success,
            ),
            SizedBox(width: AppSizes.paddingS),
            Text('Request Submitted'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your blood donation request has been successfully submitted.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: AppSizes.paddingM),
            const Text(
              'What happens next:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              '• Eligible donors will be notified\n'
              '• You\'ll receive calls/messages from donors\n'
              '• Track responses in your dashboard\n'
              '• Update request status as needed',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.getTextSecondaryColor(context),
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to previous screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: AppColors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _medicalConditionController.dispose();
    _hospitalNameController.dispose();
    _hospitalAddressController.dispose();
    _contactNumberController.dispose();
    _byStanderController.dispose();
    _byStanderContactController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }
}
