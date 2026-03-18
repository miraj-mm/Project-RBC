import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../core/core.dart';
import '../../../core/widgets/app_top_bar.dart';

class LocationInputScreen extends ConsumerStatefulWidget {
  const LocationInputScreen({super.key});

  @override
  ConsumerState<LocationInputScreen> createState() => _LocationInputScreenState();
}

class _LocationInputScreenState extends ConsumerState<LocationInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _focusNode = FocusNode();
  final bool _isLoading = false;
  bool _isGettingLocation = false;
  final bool _isValidating = false;
  bool _showSuggestions = false;
  final List<dynamic> _suggestions = [];
  dynamic _validationResult;
  String _googleMapsLink = '';
  Timer? _debounceTimer;

  @override
  void dispose() {
    _locationController.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: const AppTopBar(title: 'Location'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSizes.paddingXL),
              Text(
                'Enter your details below to proceed',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.getTextSecondaryColor(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.paddingXXL),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      children: [
                        TextFormField(
                          controller: _locationController,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            labelText: 'Enter your current Location',
                            hintText: 'Type your location...',
                            prefixIcon: Icon(Icons.location_on),
                            suffixIcon: _buildValidationIcon(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusS),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your location';
                            }
                            if (_validationResult != null && !_validationResult['isValid']) {
                              return _validationResult['error'];
                            }
                            return null;
                          },
                          onTap: () {
                            if (_suggestions.isNotEmpty) {
                              setState(() {
                                _showSuggestions = true;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    if (_showSuggestions && _suggestions.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: AppColors.getCardBackgroundColor(context),
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.grey.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _suggestions.length,
                          itemBuilder: (context, index) {
                            final suggestion = _suggestions[index];
                            return ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.location_on_outlined,
                                color: AppColors.getTextSecondaryColor(context),
                                size: 20,
                              ),
                              title: Text(
                                suggestion['mainText'] ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: (suggestion['secondaryText'] ?? '').isNotEmpty
                                  ? Text(
                                      suggestion['secondaryText'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.getTextSecondaryColor(context),
                                      ),
                                    )
                                  : null,
                              onTap: () => _selectSuggestion(suggestion),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: AppSizes.paddingL),
                    OutlinedButton.icon(
                      onPressed: _isGettingLocation ? null : _getCurrentLocation,
                      icon: _isGettingLocation
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.my_location),
                      label: Text(
                        _isGettingLocation
                            ? 'Getting location...'
                            : 'Use your current Location',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryRed,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.paddingM,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingL),
                    if (_googleMapsLink.isNotEmpty)
                      _buildGoogleMapsLink(),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.paddingXL),
              Container(
                margin: const EdgeInsets.all(AppSizes.paddingL),
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: AppSizes.iconM,
                    ),
                    const SizedBox(width: AppSizes.paddingM),
                    Expanded(
                      child: Text(
                        'We use your location to find nearby bus routes and blood donation centers.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.info,
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL, vertical: AppSizes.paddingM),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingL),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
            ),
            onPressed: _canProceed() ? _handleProceed : null,
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Proceed',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildValidationIcon() {
    if (_isValidating) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (_validationResult != null) {
      return Icon(
        _validationResult['isValid'] ? Icons.check_circle : Icons.error,
        color: _validationResult['isValid'] ? AppColors.success : AppColors.error,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildGoogleMapsLink() {
    return Container(
      margin: const EdgeInsets.only(top: AppSizes.paddingL),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.link, color: AppColors.success),
          const SizedBox(width: AppSizes.paddingS),
          Expanded(
            child: SelectableText(
              _googleMapsLink,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextPrimaryColor(context),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.copy, color: AppColors.success),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _googleMapsLink));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied Google Maps link!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }


  void _selectSuggestion(dynamic suggestion) {
    setState(() {
      _locationController.text = suggestion['mainText'] ?? '';
      _showSuggestions = false;
    });
  }

  void _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    // Simulate location fetching
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _locationController.text = "Current Location - Dhaka, Bangladesh";
        _googleMapsLink = "https://maps.google.com/?q=23.8103,90.4125";
        _validationResult = {'isValid': true};
        _isGettingLocation = false;
      });
    }
  }

  bool _canProceed() {
    return !_isLoading && 
           !_isValidating && 
           _locationController.text.isNotEmpty && 
           (_validationResult?['isValid'] ?? false);
  }

  void _handleProceed() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop();
    }
  }
}

