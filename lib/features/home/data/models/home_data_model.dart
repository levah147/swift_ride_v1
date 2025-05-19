import 'package:equatable/equatable.dart';

import '../../../auth/data/models/user_model.dart';
import '../../../rides/data/models/ride_model.dart';

class HomeDataModel extends Equatable {
  final UserModel user;
  final List<SavedLocationModel> savedLocations;
  final int nearbyDriversCount;
  final List<RideCategoryModel> categories;
  final List<RideModel> recentRides;
  final List<PromotionModel> promotions;

  const HomeDataModel({
    required this.user,
    required this.savedLocations,
    required this.nearbyDriversCount,
    required this.categories,
    required this.recentRides,
    required this.promotions,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    return HomeDataModel(
      user: UserModel.fromJson(json['user']),
      savedLocations: (json['saved_locations'] as List)
          .map((x) => SavedLocationModel.fromJson(x))
          .toList(),
      nearbyDriversCount: json['nearby_drivers_count'],
      categories: (json['categories'] as List)
          .map((x) => RideCategoryModel.fromJson(x))
          .toList(),
      recentRides: (json['recent_rides'] as List)
          .map((x) => RideModel.fromJson(x))
          .toList(),
      promotions: (json['promotions'] as List)
          .map((x) => PromotionModel.fromJson(x))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        user,
        savedLocations,
        nearbyDriversCount,
        categories,
        recentRides,
        promotions,
      ];
}

class RideCategoryModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final double baseFare;
  final double perKmRate;
  final double perMinuteRate;
  final int capacity;
  final String? image;
  final bool isActive;

  const RideCategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.baseFare,
    required this.perKmRate,
    required this.perMinuteRate,
    required this.capacity,
    this.image,
    this.isActive = true,
  });

  factory RideCategoryModel.fromJson(Map<String, dynamic> json) {
    return RideCategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      baseFare: double.parse(json['base_fare'].toString()),
      perKmRate: double.parse(json['per_km_rate'].toString()),
      perMinuteRate: double.parse(json['per_minute_rate'].toString()),
      capacity: json['capacity'],
      image: json['image'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'base_fare': baseFare,
      'per_km_rate': perKmRate,
      'per_minute_rate': perMinuteRate,
      'capacity': capacity,
      'image': image,
      'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        baseFare,
        perKmRate,
        perMinuteRate,
        capacity,
        image,
        isActive,
      ];
}

class PromotionModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String code;
  final DateTime expiresAt;
  final String imageUrl;

  const PromotionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.code,
    required this.expiresAt,
    required this.imageUrl,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      code: json['code'],
      expiresAt: DateTime.parse(json['expires_at']),
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'code': code,
      'expires_at': expiresAt.toIso8601String(),
      'image_url': imageUrl,
    };
  }

  @override
  List<Object?> get props => [id, title, description, code, expiresAt, imageUrl];
}
