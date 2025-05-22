// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class RideHistoryScreen extends ConsumerStatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  ConsumerState<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends ConsumerState<RideHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  final List<RideHistoryItem> _completedRides = [];
  final List<RideHistoryItem> _cancelledRides = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRideHistory();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadRideHistory() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        
        // Sample completed rides
        _completedRides.addAll([
          RideHistoryItem(
            id: '1',
            date: DateTime.now().subtract(const Duration(days: 1)),
            pickupLocation: 'Home',
            dropoffLocation: 'Work',
            amount: 1200,
            status: 'Completed',
            driverName: 'John Doe',
            driverRating: 4.8,
          ),
          RideHistoryItem(
            id: '2',
            date: DateTime.now().subtract(const Duration(days: 3)),
            pickupLocation: 'Work',
            dropoffLocation: 'Home',
            amount: 1350,
            status: 'Completed',
            driverName: 'Jane Smith',
            driverRating: 4.9,
          ),
          RideHistoryItem(
            id: '3',
            date: DateTime.now().subtract(const Duration(days: 7)),
            pickupLocation: 'Home',
            dropoffLocation: 'Shopping Mall',
            amount: 850,
            status: 'Completed',
            driverName: 'Mike Johnson',
            driverRating: 4.7,
          ),
        ]);
        
        // Sample cancelled rides
        _cancelledRides.addAll([
          RideHistoryItem(
            id: '4',
            date: DateTime.now().subtract(const Duration(days: 2)),
            pickupLocation: 'Home',
            dropoffLocation: 'Airport',
            amount: 0,
            status: 'Cancelled',
            driverName: 'Driver not assigned',
            driverRating: 0,
          ),
          RideHistoryItem(
            id: '5',
            date: DateTime.now().subtract(const Duration(days: 5)),
            pickupLocation: 'Restaurant',
            dropoffLocation: 'Home',
            amount: 0,
            status: 'Cancelled',
            driverName: 'Driver not assigned',
            driverRating: 0,
          ),
        ]);
      });
    }
  }
  
  void _showRideDetails(RideHistoryItem ride) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Ride ID and date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ride #${ride.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy • h:mm a').format(ride.date),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: ride.status == 'Completed'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ride.status,
                    style: TextStyle(
                      color: ride.status == 'Completed' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Ride details
                const Text(
                  'Ride Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                _buildRideDetailItem(
                  icon: Icons.circle,
                  iconColor: Colors.green,
                  title: 'Pickup',
                  subtitle: ride.pickupLocation,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: SizedBox(
                    height: 20,
                    child: VerticalDivider(
                      thickness: 2,
                      color: Colors.grey,
                    ),
                  ),
                ),
                _buildRideDetailItem(
                  icon: Icons.location_on,
                  iconColor: Colors.red,
                  title: 'Dropoff',
                  subtitle: ride.dropoffLocation,
                ),
                const SizedBox(height: 24),
                
                // Payment details
                const Text(
                  'Payment Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Payment Method'),
                    Row(
                      children: [
                        const Icon(Icons.credit_card, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          ride.status == 'Completed' ? 'Cash' : 'N/A',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Ride Fare'),
                    Text(
                      ride.status == 'Completed' ? '₦${ride.amount}' : 'N/A',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Driver details
                if (ride.status == 'Completed') ...[
                  const Text(
                    'Driver Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey.shade200,
                        child: const Icon(Icons.person),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ride.driverName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 16, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text('${ride.driverRating}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.help_outline),
                        label: const Text('Get Help'),
                        onPressed: () {
                          // TODO0: Implement help functionality
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (ride.status == 'Completed')
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.repeat),
                          label: const Text('Book Again'),
                          onPressed: () {
                            // TODO0: Implement rebook functionality
                            Navigator.pop(context);
                          },
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildRideDetailItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Completed rides tab
                _buildRidesList(_completedRides),
                
                // Cancelled rides tab
                _buildRidesList(_cancelledRides),
              ],
            ),
    );
  }
  
  Widget _buildRidesList(List<RideHistoryItem> rides) {
    if (rides.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No rides found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rides.length,
      itemBuilder: (context, index) {
        final ride = rides[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => _showRideDetails(ride),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Date and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMM d, yyyy').format(ride.date),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ride.status == 'Completed'
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          ride.status,
                          style: TextStyle(
                            color: ride.status == 'Completed' ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Ride details
                  Row(
                    children: [
                      const Icon(Icons.circle, size: 12, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ride.pickupLocation,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: SizedBox(
                      height: 20,
                      child: VerticalDivider(
                        thickness: 2,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ride.dropoffLocation,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Amount and action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ride.status == 'Completed' ? '₦${ride.amount}' : 'Cancelled',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showRideDetails(ride),
                        child: const Text('View Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class RideHistoryItem {
  final String id;
  final DateTime date;
  final String pickupLocation;
  final String dropoffLocation;
  final double amount;
  final String status;
  final String driverName;
  final double driverRating;
  
  RideHistoryItem({
    required this.id,
    required this.date,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.amount,
    required this.status,
    required this.driverName,
    required this.driverRating,
  });
}
