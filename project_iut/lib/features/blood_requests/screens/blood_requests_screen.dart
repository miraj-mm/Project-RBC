import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../home/widgets/blood_request_card.dart';
import 'create_blood_request_screen.dart';
import '../providers/blood_request_provider.dart';

class BloodRequestsScreen extends ConsumerStatefulWidget {
  const BloodRequestsScreen({super.key});

  @override
  ConsumerState<BloodRequestsScreen> createState() => _BloodRequestsScreenState();
}

class _BloodRequestsScreenState extends ConsumerState<BloodRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = SupabaseService.currentUser?.id;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          AppStrings.bloodRequest,
          style: TextStyle(
            color: AppColors.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.getSurfaceColor(context),
        foregroundColor: AppColors.getTextPrimaryColor(context),
        iconTheme: IconThemeData(
          color: AppColors.getTextPrimaryColor(context),
        ),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryRed,
          unselectedLabelColor: AppColors.getTextSecondaryColor(context),
          indicatorColor: AppColors.primaryRed,
          tabs: const [
            Tab(text: 'All Requests'),
            Tab(text: 'My Requests'),
          ],
        ),
      ),
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllRequestsTab(),
          _buildMyRequestsTab(currentUserId),
        ],
      ),
    );
  }

  Widget _buildAllRequestsTab() {
    final requestsState = ref.watch(bloodRequestProvider);

    if (requestsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (requestsState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${requestsState.error}'),
            const SizedBox(height: AppSizes.paddingM),
            ElevatedButton(
              onPressed: () {
                ref.read(bloodRequestProvider.notifier).refreshRequests();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final activeRequests = requestsState.requests
        .where((r) => r.status == BloodRequestStatus.active)
        .toList();

    if (activeRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bloodtype, size: 64, color: AppColors.getTextSecondaryColor(context)),
            const SizedBox(height: AppSizes.paddingM),
            Text('No active blood requests', style: TextStyle(color: AppColors.getTextSecondaryColor(context))),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(bloodRequestProvider.notifier).refreshRequests();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        itemCount: activeRequests.length,
        itemBuilder: (context, index) {
          return BloodRequestCard(
            bloodRequest: activeRequests[index],
          );
        },
      ),
    );
  }

  Widget _buildMyRequestsTab(String? currentUserId) {
    if (currentUserId == null) {
      return const Center(child: Text('Please sign in to view your requests'));
    }

    final requestsState = ref.watch(bloodRequestProvider);

    if (requestsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (requestsState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${requestsState.error}'),
            const SizedBox(height: AppSizes.paddingM),
            ElevatedButton(
              onPressed: () {
                ref.read(bloodRequestProvider.notifier).refreshRequests();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final myRequests = requestsState.requests
        .where((r) => r.requesterId == currentUserId)
        .toList();

    if (myRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: AppColors.getTextSecondaryColor(context)),
            const SizedBox(height: AppSizes.paddingM),
            Text('You have not made any requests', style: TextStyle(color: AppColors.getTextSecondaryColor(context))),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(bloodRequestProvider.notifier).refreshRequests();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        itemCount: myRequests.length,
        itemBuilder: (context, index) {
          return BloodRequestCard(
            bloodRequest: myRequests[index],
          );
        },
      ),
    );
  }
}