import 'package:equatable/equatable.dart';

import '../../../auth/data/models/user_model.dart';
import '../../../home/data/models/home_data_model.dart';

class RideModel extends Equatable {
  final String id;
  final UserModel? user;
  final DriverModel? driver;
  final RideCategoryModel? category;
  final PaymentMethodModel? paymentMethod;
  
  final double pickupLatitude;
  final double pickupLongitude;
  final String pickupAddress;
  final double destinationLatitude;
  final double destinationLongitude;
  final String destinationAddress;
  
  final double estimatedDistanceKm;
  final int estimatedDurationMinutes;
  final double? actualDistanceKm;
  final int? actualDurationMinutes;
  
  final String status;
  final String paymentStatus;
  
  final double baseFare;
  final double distanceFare;
  final double timeFare;
  final double surgeMultiplier;
  final double totalFare;
  
  final DateTime requestedAt;
  final DateTime? acceptedAt;
  final DateTime? driverArrivedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  
  final String? cancelledBy;
  final String? cancellationReason;
  
  final int? userRating;
  final String? userFeedback;
  final int? driverRating;
  final String? driverFeedback;
  
  final List<RideLocationModel> locationUpdates;

  const RideModel({
    required this.id,
    this.user,
    this.driver,
    this.category,
    this.paymentMethod,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.pickupAddress,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.destinationAddress,
    required this.estimatedDistanceKm,
    required this.estimatedDurationMinutes,
    this.actualDistanceKm,
    this.actualDurationMinutes,
    required this.status,
    required this.paymentStatus,
    required this.baseFare,
    required this.distanceFare,
    required this.timeFare,
    required this.surgeMultiplier,
    required this.totalFare,
    required this.requestedAt,
    this.acceptedAt,
    this.driverArrivedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancelledBy,
    this.cancellationReason,
    this.userRating,
    this.userFeedback,
    this.driverRating,
    this.driverFeedback,
    this.locationUpdates = const [],
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      driver: json['driver'] != null ? DriverModel.fromJson(json['driver']) : null,
      category: json['category'] != null ? RideCategoryModel.fromJson(json['category']) : null,
      paymentMethod: json['payment_method'] != null ? PaymentMethodModel.fromJson(json['payment_method']) : null,
      pickupLatitude: double.parse(json['pickup_latitude'].toString()),
      pickupLongitude: double.parse(json['pickup_longitude'].toString()),
      pickupAddress: json['pickup_address'],
      destinationLatitude: double.parse(json['destination_latitude'].toString()),
      destinationLongitude: double.parse(json['destination_longitude'].toString()),
      destinationAddress: json['destination_address'],
      estimatedDistanceKm: double.parse(json['estimated_distance_km'].toString()),
      estimatedDurationMinutes: json['estimated_duration_minutes'],
      actualDistanceKm: json['actual_distance_km'] != null ? double.parse(json['actual_distance_km'].toString()) : null,
      actualDurationMinutes: json['actual_duration_minutes'],
      status: json['status'],
      paymentStatus: json['payment_status'],
      baseFare: double.parse(json['base_fare'].toString()),
      distanceFare: double.parse(json['distance_fare'].toString()),
      timeFare: double.parse(json['time_fare'].toString()),
      surgeMultiplier: double.parse(json['surge_multiplier'].toString()),
      totalFare: double.parse(json['total_fare'].toString()),
      requestedAt: DateTime.parse(json['requested_at']),
      acceptedAt: json['accepted_at'] != null ? DateTime.parse(json['accepted_at']) : null,
      driverArrivedAt: json['driver_arrived_at'] != null ? DateTime.parse(json['driver_arrived_at']) : null,
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      cancelledAt: json['cancelled_at'] != null ? DateTime.parse(json['cancelled_at']) : null,
      cancelledBy: json['cancelled_by'],
      cancellationReason: json['cancellation_reason'],
      userRating: json['user_rating'],
      userFeedback: json['user_feedback'],
      driverRating: json['driver_rating'],
      driverFeedback: json['driver_feedback'],
      locationUpdates: json['location_updates'] != null
          ? List<RideLocationModel>.from(
              json['location_updates'].map((x) => RideLocationModel.fromJson(x)))
          : [],
    );
  }

  @override
  List<Object?> get props => [
        id,
        user,
        driver,
        category,
        paymentMethod,
        pickupLatitude,
        pickupLongitude,
        pickupAddress,
        destinationLatitude,
        destinationLongitude,
        destinationAddress,
        estimatedDistanceKm,
        estimatedDurationMinutes,
        actualDistanceKm,
        actualDurationMinutes,
        status,
        paymentStatus,
        baseFare,
        distanceFare,
        timeFare,
        surgeMultiplier,
        totalFare,
        requestedAt,
        acceptedAt,
        driverArrivedAt,
        startedAt,
        completedAt,
        cancelledAt,
        cancelledBy,
        cancellationReason,
        userRating,
        userFeedback,
        driverRating,
        driverFeedback,
        locationUpdates,
      ];
}

class DriverModel extends Equatable {
  final String id;
  final UserModel user;
  final String vehicleMake;
  final String vehicleModel;
  final int vehicleYear;
  final String vehicleColor;
  final String vehicleLicensePlate;
  final bool isAvailable;
  final double rating;
  final int totalRides;
  final double? currentLatitude;
  final double? currentLongitude;

  const DriverModel({
    required this.id,
    required this.user,
    required this.vehicleMake,
    required this.vehicleModel,
    required this.vehicleYear,
    required this.vehicleColor,
    required this.vehicleLicensePlate,
    this.isAvailable = false,
    required this.rating,
    required this.totalRides,
    this.currentLatitude,
    this.currentLongitude,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'],
      user: UserModel.fromJson(json['user']),
      vehicleMake: json['vehicle_make'],
      vehicleModel: json['vehicle_model'],
      vehicleYear: json['vehicle_year'],
      vehicleColor: json['vehicle_color'],
      vehicleLicensePlate: json['vehicle_license_plate'],
      isAvailable: json['is_available'] ?? false,
      rating: double.parse(json['rating'].toString()),
      totalRides: json['total_rides'],
      currentLatitude: json['current_latitude'] != null ? double.parse(json['current_latitude'].toString()) : null,
      currentLongitude: json['current_longitude'] != null ? double.parse(json['current_longitude'].toString()) : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        user,
        vehicleMake,
        vehicleModel,
        vehicleYear,
        vehicleColor,
        vehicleLicensePlate,
        isAvailable,
        rating,
        totalRides,
        currentLatitude,
        currentLongitude,
      ];
}

class RideLocationModel extends Equatable {
  final String id;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  const RideLocationModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory RideLocationModel.fromJson(Map<String, dynamic> json) {
    return RideLocationModel(
      id: json['id'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  @override
  List<Object?> get props => [id, latitude, longitude, timestamp];
}
