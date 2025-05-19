// ignore_for_file: unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const HomeTab(),
    const RideHistoryTab(),
    const ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    // Load home data
    Future.microtask(() {
      ref.read(homeProvider.notifier).loadHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Rides',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      body: homeState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : homeState.errorMessage != null
              ? Center(child: Text(homeState.errorMessage!))
              : CustomScrollView(
                  slivers: [
                    // App bar
                    SliverAppBar(
                      expandedHeight: 200,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text('Hello, ${user?.fullName.split(' ').first ?? 'User'}'),
                        background: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primaryContainer,
                              ],
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.notifications),
                          onPressed: () {
                            // TODO0: Navigate to notifications
                          },
                        ),
                      ],
                    ),
                    
                    // Content
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Where to?
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Where to?',
                                        prefixIcon: const Icon(Icons.search),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      onTap: () {
                                        // TODO0: Navigate to ride request screen
                                      },
                                      readOnly: true,
                                    ),
                                    const SizedBox(height: 16),
                                    // Saved locations
                                    if (homeState.homeData?.savedLocations.isNotEmpty ?? false)
                                      ...homeState.homeData!.savedLocations.take(2).map((location) {
                                        return ListTile(
                                          leading: Icon(
                                            location.type == 'home'
                                                ? Icons.home
                                                : location.type == 'work'
                                                    ? Icons.work
                                                    : Icons.star,
                                          ),
                                          title: Text(location.name),
                                          subtitle: Text(location.address),
                                          onTap: () {
                                            // TODO0: Navigate to ride request with this destination
                                          },
                                        );
                                      }).toList(),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Ride categories
                            const Text(
                              'Ride Options',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 120,
                              child: homeState.categories.isEmpty
                                  ? const Center(child: Text('No ride options available'))
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: homeState.categories.length,
                                      itemBuilder: (context, index) {
                                        final category = homeState.categories[index];
                                        return Card(
                                          margin: const EdgeInsets.only(right: 16),
                                          child: SizedBox(
                                            width: 100,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Image.network(
                                                  category.image ?? 'https://via.placeholder.com/50',
                                                  width: 50,
                                                  height: 50,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return const Icon(Icons.directions_car, size: 50);
                                                  },
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  category.name,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  '\$${category.baseFare.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Promotions
                            if (homeState.homeData?.promotions.isNotEmpty ?? false) ...[
                              const Text(
                                'Promotions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 150,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: homeState.homeData!.promotions.length,
                                  itemBuilder: (context, index) {
                                    final promotion = homeState.homeData!.promotions[index];
                                    return Card(
                                      margin: const EdgeInsets.only(right: 16),
                                      child: Container(
                                        width: 250,
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              promotion.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(promotion.description),
                                            const Spacer(),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Code: ${promotion.code}',
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    // TODO0: Apply promotion
                                                  },
                                                  child: const Text('Apply'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            
                            // Recent rides
                            if (homeState.homeData?.recentRides.isNotEmpty ?? false) ...[
                              const Text(
                                'Recent Rides',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...homeState.homeData!.recentRides.take(3).map((ride) {
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: ListTile(
                                    leading: const Icon(Icons.history),
                                    title: Text(ride.destinationAddress),
                                    subtitle: Text(
                                      '${ride.status} • \$${ride.totalFare.toStringAsFixed(2)}',
                                    ),
                                    trailing: Text(
                                      _formatDate(ride.requestedAt),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    onTap: () {
                                      // TODO0: Navigate to ride details
                                    },
                                  ),
                                );
                              }).toList(),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class RideHistoryTab extends StatelessWidget {
  const RideHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Ride History Tab - Coming Soon'),
    );
  }
}

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

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
      body: authState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? const Center(child: Text('User not found'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Profile header
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Profile image
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: user.profileImage != null
                                  ? NetworkImage(user.profileImage!)
                                  : null,
                              child: user.profileImage == null
                                  ? Text(
                                      user.fullName.isNotEmpty
                                          ? user.fullName.substring(0, 1).toUpperCase()
                                          : 'U',
                                      style: const TextStyle(fontSize: 40),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            
                            // User name
                            Text(
                              user.fullName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // User info
                            Text(
                              user.email,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              user.phoneNumber,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Edit profile button
                            OutlinedButton.icon(
                              onPressed: () {
                                // TODO0: Navigate to edit profile
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit Profile'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Profile menu
                    const Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Saved locations
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: const Text('Saved Locations'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO0: Navigate to saved locations
                      },
                    ),
                    
                    // Payment methods
                    ListTile(
                      leading: const Icon(Icons.payment),
                      title: const Text('Payment Methods'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO0: Navigate to payment methods
                      },
                    ),
                    
                    // Change password
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Change Password'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO0: Navigate to change password
                      },
                    ),
                    
                    const Divider(),
                    
                    // Support
                    const Text(
                      'Support',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Help & Support
                    ListTile(
                      leading: const Icon(Icons.help),
                      title: const Text('Help & Support'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO0: Navigate to help & support
                      },
                    ),
                    
                    // About
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('About'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO0: Navigate to about
                      },
                    ),
                    
                    // Terms & Conditions
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text('Terms & Conditions'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO0: Navigate to terms & conditions
                      },
                    ),
                    
                    // Privacy Policy
                    ListTile(
                      leading: const Icon(Icons.privacy_tip),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO0: Navigate to privacy policy
                      },
                    ),
                    
                    const Divider(),
                    
                    // Logout
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        // Show confirmation dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ref.read(authProvider.notifier).logout();
                                },
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
    );
  }
}
