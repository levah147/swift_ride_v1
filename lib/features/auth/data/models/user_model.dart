import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String phoneNumber;
  final String fullName;
  final String? profileImage;
  final bool isVerified;
  final DateTime dateJoined;
  final List<SavedLocationModel> savedLocations;
  final List<PaymentMethodModel> paymentMethods;
  final int totalRides;

  const UserModel({
    required this.id,
    required this.email,
    required this.phoneNumber,
    required this.fullName,
    this.profileImage,
    required this.isVerified,
    required this.dateJoined,
    this.savedLocations = const [],
    this.paymentMethods = const [],
    this.totalRides = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      fullName: json['full_name'],
      profileImage: json['profile_image'],
      isVerified: json['is_verified'] ?? false,
      dateJoined: DateTime.parse(json['date_joined']),
      savedLocations: json['saved_locations'] != null
          ? List<SavedLocationModel>.from(
              json['saved_locations'].map((x) => SavedLocationModel.fromJson(x)))
          : [],
      paymentMethods: json['payment_methods'] != null
          ? List<PaymentMethodModel>.from(
              json['payment_methods'].map((x) => PaymentMethodModel.fromJson(x)))
          : [],
      totalRides: json['total_rides'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone_number': phoneNumber,
      'full_name': fullName,
      'profile_image': profileImage,
      'is_verified': isVerified,
      'date_joined': dateJoined.toIso8601String(),
      'saved_locations': savedLocations.map((x) => x.toJson()).toList(),
      'payment_methods': paymentMethods.map((x) => x.toJson()).toList(),
      'total_rides': totalRides,
    };
  }

  @override
  List<Object?> get props => [
        id,
        email,
        phoneNumber,
        fullName,
        profileImage,
        isVerified,
        dateJoined,
        savedLocations,
        paymentMethods,
        totalRides,
      ];
}

class SavedLocationModel extends Equatable {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String type;
  final bool isFavorite;

  const SavedLocationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.isFavorite = false,
  });

  factory SavedLocationModel.fromJson(Map<String, dynamic> json) {
    return SavedLocationModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      type: json['type'],
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
      'is_favorite': isFavorite,
    };
  }

  @override
  List<Object?> get props => [id, name, address, latitude, longitude, type, isFavorite];
}

class PaymentMethodModel extends Equatable {
  final String id;
  final String type;
  final bool isDefault;
  final String? cardLastFour;
  final String? cardBrand;
  final String? walletProvider;
  final String? walletNumber;

  const PaymentMethodModel({
    required this.id,
    required this.type,
    this.isDefault = false,
    this.cardLastFour,
    this.cardBrand,
    this.walletProvider,
    this.walletNumber,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'],
      type: json['type'],
      isDefault: json['is_default'] ?? false,
      cardLastFour: json['card_last_four'],
      cardBrand: json['card_brand'],
      walletProvider: json['wallet_provider'],
      walletNumber: json['wallet_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'is_default': isDefault,
      'card_last_four': cardLastFour,
      'card_brand': cardBrand,
      'wallet_provider': walletProvider,
      'wallet_number': walletNumber,
    };
  }

  @override
  List<Object?> get props => [
        id,
        type,
        isDefault,
        cardLastFour,
        cardBrand,
        walletProvider,
        walletNumber,
      ];
}
