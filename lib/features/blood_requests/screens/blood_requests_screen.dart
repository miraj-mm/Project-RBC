import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../home/widgets/blood_request_card.dart';
import 'create_blood_request_screen.dart';
import '../../../core/widgets/app_top_bar.dart';

class BloodRequestsScreen extends StatelessWidget {
  const BloodRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: const AppTopBar(title: AppStrings.bloodRequest),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateBloodRequestScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primaryRed,
        child: const Icon(
          Icons.add,
          color: AppColors.white,
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        itemCount: _sampleBloodRequests.length,
        itemBuilder: (context, index) {
          return BloodRequestCard(
            bloodRequest: _sampleBloodRequests[index],
          );
        },
      ),
    );
  }
}

final List<BloodRequestModel> _sampleBloodRequests = [
  BloodRequestModel(
    id: '1',
    requesterId: 'requester1',
    patientName: 'John Doe',
    bloodGroup: 'O+',
    unitsRequired: 2,
    medicalCondition: 'Surgery',
    hospitalName: 'Dhaka Medical College Hospital',
    hospitalAddress: 'Bakshibazar Rd, Dhaka 1000',
    contactNumber: '+8801712345678',
    status: BloodRequestStatus.active,
    priority: BloodRequestPriority.urgent,
    requiredBy: DateTime.now().add(const Duration(days: 1)),
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  BloodRequestModel(
    id: '2',
    requesterId: 'requester2',
    patientName: 'Jane Smith',
    bloodGroup: 'AB+',
    unitsRequired: 1,
    medicalCondition: 'Emergency Surgery',
    hospitalName: 'Square Hospital',
    hospitalAddress: '18/F, Bir Uttam Qazi Nuruzzaman Sarak, Dhaka 1205',
    contactNumber: '+8801987654321',
    byStander: 'Mike Smith',
    byStanderContact: '+8801543210987',
    status: BloodRequestStatus.active,
    priority: BloodRequestPriority.critical,
    requiredBy: DateTime.now().add(const Duration(hours: 12)),
    additionalNotes: 'Critical condition, please respond immediately',
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
  ),
  BloodRequestModel(
    id: '3',
    requesterId: 'requester3',
    patientName: 'Ahmed Hassan',
    bloodGroup: 'B+',
    unitsRequired: 3,
    medicalCondition: 'Thalassemia',
    hospitalName: 'Apollo Hospital',
    hospitalAddress: 'Plot 81, Block E, Bashundhara R/A, Dhaka 1229',
    contactNumber: '+8801876543210',
    status: BloodRequestStatus.active,
    priority: BloodRequestPriority.normal,
    requiredBy: DateTime.now().add(const Duration(days: 3)),
    additionalNotes: 'Regular blood transfusion required',
    isNgoRequest: true,
    createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
  ),
  BloodRequestModel(
    id: '4',
    requesterId: 'requester4',
    patientName: 'Sarah Khan',
    bloodGroup: 'A-',
    unitsRequired: 1,
    medicalCondition: 'Post-operative care',
    hospitalName: 'Lab Aid Hospital',
    hospitalAddress: 'House 1, Road 4, Dhanmondi, Dhaka 1205',
    contactNumber: '+8801765432109',
    byStander: 'Karim Khan',
    byStanderContact: '+8801654321098',
    status: BloodRequestStatus.active,
    priority: BloodRequestPriority.urgent,
    requiredBy: DateTime.now().add(const Duration(hours: 18)),
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  BloodRequestModel(
    id: '5',
    requesterId: 'requester5',
    patientName: 'Fatima Ali',
    bloodGroup: 'O-',
    unitsRequired: 2,
    medicalCondition: 'Accident victim',
    hospitalName: 'United Hospital',
    hospitalAddress: 'Plot 15, Road 71, Gulshan 2, Dhaka 1212',
    contactNumber: '+8801987654321',
    status: BloodRequestStatus.active,
    priority: BloodRequestPriority.critical,
    requiredBy: DateTime.now().add(const Duration(hours: 6)),
    additionalNotes: 'Road accident victim, blood needed urgently',
    createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
  ),
];