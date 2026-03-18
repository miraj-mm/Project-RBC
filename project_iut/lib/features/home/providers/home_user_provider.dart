import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_model.dart';

// Sample user data provider for demonstration
final sampleUserProvider = Provider<UserModel>((ref) {
  return UserModel(
    id: '1',
    name: 'Ahmed Rahman', 
    email: 'ahmed.rahman@example.com',
    phone: '+8801712345678',
    gender: 'Male',
    age: 24,
    bloodGroup: 'B+',
    lastDonationDate: DateTime.now().subtract(const Duration(days: 90)),
    profilePictureUrl: null, // We'll use initials for now
    livesSaved: 12,
    isActive: true,
    createdAt: DateTime.now().subtract(const Duration(days: 365)),
    updatedAt: DateTime.now(),
  );
});

// You can add more sample users here
final sampleUsersProvider = Provider<List<UserModel>>((ref) {
  return [
    UserModel(
      id: '1',
      name: 'Ahmed Rahman',
      email: 'ahmed.rahman@example.com', 
      phone: '+8801712345678',
      gender: 'Male',
      age: 24,
      bloodGroup: 'B+',
      lastDonationDate: DateTime.now().subtract(const Duration(days: 90)),
      livesSaved: 12,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    ),
    UserModel(
      id: '2', 
      name: 'Fatima Khan',
      email: 'fatima.khan@example.com',
      phone: '+8801987654321',
      gender: 'Female',
      age: 22,
      bloodGroup: 'O-',
      lastDonationDate: DateTime.now().subtract(const Duration(days: 45)),
      livesSaved: 8,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
      updatedAt: DateTime.now(),
    ),
    UserModel(
      id: '3',
      name: 'Mohammad Ali',
      email: 'mohammad.ali@example.com', 
      phone: '+8801555666777',
      gender: 'Male',
      age: 28,
      bloodGroup: 'A+',
      lastDonationDate: DateTime.now().subtract(const Duration(days: 120)),
      livesSaved: 15,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 500)),
      updatedAt: DateTime.now(),
    ),
  ];
});

// Current user provider that switches between sample and real data
final currentHomeUserProvider = Provider<UserModel>((ref) {
  // For now, we'll use sample data. Later this can be switched to real data
  return ref.watch(sampleUserProvider);
});