import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/data/models/home_data_model.dart';
import '../../data/models/ride_model.dart';
import '../../data/repositories/ride_repository.dart';

// Ride state
class RideState {
  final bool isLoading;
  final RideModel? activeRide;
  final List<RideModel> rideHistory;
  final List<RideCategoryModel> categories;
  final String? errorMessage;

  RideState({
    this.isLoading = false,
    this.activeRide,
    this.rideHistory = const [],
    this.categories = const [],
    this.errorMessage,
  });

  RideState copyWith({
    bool? isLoading,
    RideModel? activeRide,
    List<RideModel>? rideHistory,
    List<RideCategoryModel>? categories,
    String? errorMessage,
  }) {
    return RideState(
      isLoading: isLoading ?? this.isLoading,
      activeRide: activeRide ?? this.activeRide,
      rideHistory: rideHistory ?? this.rideHistory,
      categories: categories ?? this.categories,
      errorMessage: errorMessage,
    );
  }
}

// Ride notifier
class RideNotifier extends StateNotifier<RideState> {
  final RideRepository _rideRepository;

  RideNotifier(this._rideRepository) : super(RideState()) {
    // Check for active ride on initialization
    checkActiveRide();
  }

  // Check if there's an active ride
  Future<void> checkActiveRide() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _rideRepository.getActiveRide();
    
    if (result['success']) {
      state = state.copyWith(
        isLoading: false,
        activeRide: result['ride'],
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result['message'],
      );
    }
  }

  // Request a new ride
  Future<bool> requestRide({
    required String categoryId,
    String? paymentMethodId,
    required double pickupLatitude,
    required double pickupLongitude,
    required String pickupAddress,
    required double destinationLatitude,
    required double destinationLongitude,
    required String destinationAddress,
    required double estimatedDistanceKm,
    required int estimatedDurationMinutes,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _rideRepository.requestRide(
      categoryId: categoryId,
      paymentMethodId: paymentMethodId,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      pickupAddress: pickupAddress,
      destinationLatitude: destinationLatitude,
      destinationLongitude: destinationLongitude,
      destinationAddress: destinationAddress,
      estimatedDistanceKm: estimatedDistanceKm,
      estimatedDurationMinutes: estimatedDurationMinutes,
    );
    
    if (result['success']) {
      state = state.copyWith(
        isLoading: false,
        activeRide: result['ride'],
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result['message'],
      );
      return false;
    }
  }

  // Cancel active ride
  Future<bool> cancelRide({String? reason}) async {
    if (state.activeRide == null) {
      state = state.copyWith(
        errorMessage: 'No active ride to cancel',
      );
      return false;
    }
    
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _rideRepository.cancelRide(
      state.activeRide!.id,
      reason: reason,
    );
    
    if (result['success']) {
      state = state.copyWith(
        isLoading: false,
        activeRide: result['ride'],
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result['message'],
      );
      return false;
    }
  }

  // Rate a ride
  Future<bool> rateRide(String rideId, {required int rating, String? feedback}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _rideRepository.rateRide(
      rideId,
      rating: rating,
      feedback: feedback,
    );
    
    if (result['success']) {
      // Update ride in history if it exists
      final updatedRide = result['ride'];
      final updatedHistory = [...state.rideHistory];
      final index = updatedHistory.indexWhere((ride) => ride.id == rideId);
      
      if (index != -1) {
        updatedHistory[index] = updatedRide;
      }
      
      state = state.copyWith(
        isLoading: false,
        rideHistory: updatedHistory,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result['message'],
      );
      return false;
    }
  }

  // Load ride history
  Future<void> loadRideHistory({
    String? status,
    String? dateFrom,
    String? dateTo,
    bool refresh = false,
  }) async {
    state = state.copyWith(
      isLoading: true, 
      errorMessage: null,
      rideHistory: refresh ? [] : state.rideHistory,
    );
    
    final result = await _rideRepository.getRideHistory(
      status: status,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
    
    if (result['success']) {
      state = state.copyWith(
        isLoading: false,
        rideHistory: result['rides'],
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result['message'],
      );
    }
  }

  // Refresh active ride status
  Future<void> refreshActiveRide() async {
    if (state.activeRide == null) return;
    
    final result = await _rideRepository.getRideDetails(state.activeRide!.id);
    
    if (result['success']) {
      state = state.copyWith(
        activeRide: result['ride'],
      );
    }
  }
}

// Provider for ride state
final rideProvider = StateNotifierProvider<RideNotifier, RideState>((ref) {
  final rideRepository = ref.watch(rideRepositoryProvider);
  return RideNotifier(rideRepository);
});
