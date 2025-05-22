import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constants.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoading = true;
  
  // Mock user data
  final Map<String, dynamic> _userData = {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
    'phone': '+234 801 234 5678',
    'profileImage': null, // No image for now
    'totalRides': 15,
    'memberSince': DateTime(2023, 6, 15),
    'savedLocations': [
      {'name': 'Home', 'address': '123 Main St, Lagos', 'icon': Icons.home},
      {'name': 'Work', 'address': '456 Office Blvd, Lagos', 'icon': Icons.work},
      {'name': 'Gym', 'address': '789 Fitness Ave, Lagos', 'icon': Icons.fitness_center},
    ],
    'paymentMethods': [
      {'type': 'Cash', 'isDefault': true, 'icon': Icons.money},
      {'type': 'Credit Card', 'isDefault': false, 'icon': Icons.credit_card, 'last4': '4242'},
    ],
  };
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO0: Implement actual logout logic
              context.go(RouteConstants.login);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO0: Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: _userData['profileImage'] != null
                        ? null // TODO0: Display profile image
                        : Icon(
                            Icons.person,
                            size: 50,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userData['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userData['email'],
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userData['phone'],
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      // TODO0: Navigate to edit profile
                    },
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  icon: Icons.directions_car,
                  value: _userData['totalRides'].toString(),
                  label: 'Total Rides',
                ),
                _buildStatItem(
                  icon: Icons.calendar_today,
                  value: 'Since ${_userData['memberSince'].year}',
                  label: 'Member',
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Saved locations
            _buildSectionHeader('Saved Locations'),
            const SizedBox(height: 8),
            ..._userData['savedLocations'].map<Widget>((location) {
              return _buildListItem(
                icon: location['icon'],
                title: location['name'],
                subtitle: location['address'],
                onTap: () {
                  // TODO0: Navigate to edit location
                },
              );
            }).toList(),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add New Location'),
              onPressed: () {
                // TODO0: Navigate to add location
              },
            ),
            const SizedBox(height: 24),
            
            // Payment methods
            _buildSectionHeader('Payment Methods'),
            const SizedBox(height: 8),
            ..._userData['paymentMethods'].map<Widget>((method) {
              return _buildListItem(
                icon: method['icon'],
                title: method['type'],
                subtitle: method['last4'] != null ? '•••• ${method['last4']}' : null,
                trailing: method['isDefault'] ? const Text('Default') : null,
                onTap: () {
                  // TODO0: Navigate to payment method details
                },
              );
            }).toList(),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Payment Method'),
              onPressed: () {
                // TODO0: Navigate to add payment method
              },
            ),
            const SizedBox(height: 24),
            
            // Other options
            _buildSectionHeader('More'),
            const SizedBox(height: 8),
            _buildListItem(
              icon: Icons.history,
              title: 'Ride History',
              onTap: () {
                context.go(RouteConstants.rideHistory);
              },
            ),
            _buildListItem(
              icon: Icons.support_agent,
              title: 'Support',
              onTap: () {
                // TODO0: Navigate to support
              },
            ),
            _buildListItem(
              icon: Icons.info_outline,
              title: 'About',
              onTap: () {
                // TODO0: Navigate to about
              },
            ),
            _buildListItem(
              icon: Icons.logout,
              title: 'Logout',
              textColor: Colors.red,
              onTap: _logout,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildListItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
