// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/route_constants.dart';

class RideTrackingScreen extends ConsumerStatefulWidget {
  const RideTrackingScreen({super.key});

  @override
  ConsumerState<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends ConsumerState<RideTrackingScreen> {
  GoogleMapController? _mapController;
  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(9.0820, 8.6753), // Nigeria's coordinates
    zoom: 14.0,
  );
  
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  
  Timer? _driverUpdateTimer;
  int _estimatedTimeInMinutes = 5;
  String _rideStatus = 'Driver is on the way';
  
  @override
  void initState() {
    super.initState();
    _setupMap();
    _simulateDriverMovement();
  }
  
  @override
  void dispose() {
    _driverUpdateTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
  
  void _setupMap() {
    // Add markers for pickup and destination
    _markers = {
      const Marker(
        markerId: MarkerId('pickup'),
        position: LatLng(9.0820, 8.6753),
        infoWindow: InfoWindow(title: 'Pickup Location'),
      ),
      const Marker(
        markerId: MarkerId('destination'),
        position: LatLng(9.0920, 8.6853),
        infoWindow: InfoWindow(title: 'Destination'),
      ),
      const Marker(
        markerId: MarkerId('driver'),
        position: LatLng(9.0780, 8.6700),
        infoWindow: InfoWindow(title: 'Your Driver'),
      ),
    };
    
    // Add route polyline
    _polylines = {
      const Polyline(
        polylineId: PolylineId('route'),
        color: Colors.blue,
        width: 5,
        points: [
          LatLng(9.0780, 8.6700), // Driver starting position
          LatLng(9.0800, 8.6720),
          LatLng(9.0820, 8.6753), // Pickup
          LatLng(9.0850, 8.6780),
          LatLng(9.0880, 8.6810),
          LatLng(9.0920, 8.6853), // Destination
        ],
      ),
    };
  }
  
  void _simulateDriverMovement() {
    // Simulate driver movement with a timer
    const List<LatLng> driverPath = [
      LatLng(9.0780, 8.6700),
      LatLng(9.0800, 8.6720),
      LatLng(9.0810, 8.6740),
      LatLng(9.0820, 8.6753), // Pickup point
    ];
    
    int pathIndex = 0;
    
    _driverUpdateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (pathIndex < driverPath.length) {
        setState(() {
          // Update driver marker position
          _markers = {
            ..._markers.where((m) => m.markerId.value != 'driver'),
            Marker(
              markerId: const MarkerId('driver'),
              position: driverPath[pathIndex],
              infoWindow: const InfoWindow(title: 'Your Driver'),
            ),
          };
          
          // Update ETA
          _estimatedTimeInMinutes = (driverPath.length - pathIndex - 1) * 2;
          
          // Update status when driver arrives at pickup
          if (pathIndex == driverPath.length - 1) {
            _rideStatus = 'Driver has arrived';
          }
        });
        
        pathIndex++;
      } else {
        // Driver has arrived at pickup point
        timer.cancel();
        
        // After a delay, simulate ride starting
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _rideStatus = 'On the way to destination';
              _estimatedTimeInMinutes = 10;
            });
            
            // Simulate ride to destination
            _simulateRideToDestination();
          }
        });
      }
    });
  }
  
  void _simulateRideToDestination() {
    const List<LatLng> ridePath = [
      LatLng(9.0820, 8.6753), // Pickup point
      LatLng(9.0850, 8.6780),
      LatLng(9.0880, 8.6810),
      LatLng(9.0920, 8.6853), // Destination
    ];
    
    int pathIndex = 0;
    
    _driverUpdateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (pathIndex < ridePath.length) {
        setState(() {
          // Update both driver and user position
          _markers = {
            ..._markers.where((m) => m.markerId.value != 'driver' && m.markerId.value != 'user'),
            Marker(
              markerId: const MarkerId('driver'),
              position: ridePath[pathIndex],
              infoWindow: const InfoWindow(title: 'Your Driver'),
            ),
            Marker(
              markerId: const MarkerId('user'),
              position: ridePath[pathIndex],
              infoWindow: const InfoWindow(title: 'You'),
            ),
          };
          
          // Update ETA
          _estimatedTimeInMinutes = (ridePath.length - pathIndex - 1) * 3;
        });
        
        pathIndex++;
      } else {
        // Arrived at destination
        timer.cancel();
        
        if (mounted) {
          setState(() {
            _rideStatus = 'Arrived at destination';
            _estimatedTimeInMinutes = 0;
          });
          
          // Show ride completion dialog after a delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              _showRideCompletionDialog();
            }
          });
        }
      }
    });
  }
  
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }
  
  void _cancelRide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ride'),
        content: const Text('Are you sure you want to cancel this ride? Cancellation fees may apply.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(RouteConstants.home);
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
  
  void _contactDriver() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Contact Driver',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Call Driver'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO0: Implement call functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Message Driver'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO0: Implement messaging functionality
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showRideCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Ride Completed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How was your ride?'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => IconButton(
                  icon: Icon(
                    index < 4 ? Icons.star : Icons.star_border,
                    color: index < 4 ? Colors.amber : null,
                  ),
                  onPressed: () {
                    // TODO0: Submit rating
                    Navigator.of(context).pop();
                    context.go(RouteConstants.home);
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(RouteConstants.home);
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            markers: _markers,
            polylines: _polylines,
          ),
          
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  _cancelRide();
                },
              ),
            ),
          ),
          
          // Ride info panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status and ETA
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _rideStatus,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (_estimatedTimeInMinutes > 0)
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'ETA: $_estimatedTimeInMinutes min',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Driver info
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
                            const Text(
                              'John Doe',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 16, color: Colors.amber),
                                const SizedBox(width: 4),
                                const Text('4.8'),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Toyota Camry',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'ABC-123-XYZ',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone),
                        onPressed: _contactDriver,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Ride details
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.circle, size: 12, color: Colors.green),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Current Location',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              '₦1,200',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
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
                        const Row(
                          children: [
                            Icon(Icons.location_on, size: 12, color: Colors.red),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Destination',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.close),
                          label: const Text('Cancel'),
                          onPressed: _cancelRide,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.share),
                          label: const Text('Share Trip'),
                          onPressed: () {
                            // TODO0: Implement share trip functionality
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
