import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/home_data_model.dart';
import '../../data/repositories/home_repository.dart';

// Home state
class HomeState {
  final bool isLoading;
  final HomeDataModel? homeData;
  final List<RideCategoryModel> categories;
  final String? errorMessage;

  HomeState({
    this.isLoading = false,
    this.homeData,
    this.categories = const [],
    this.errorMessage,
  });

  HomeState copyWith({
    bool? isLoading,
    HomeDataModel? homeData,
    List<RideCategoryModel>? categories,
    String? errorMessage,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      homeData: homeData ?? this.homeData,
      categories: categories ?? this.categories,
      errorMessage: errorMessage,
    );
  }
}

// Home notifier
class HomeNotifier extends StateNotifier<HomeState> {
  final HomeRepository _homeRepository;

  HomeNotifier(this._homeRepository) : super(HomeState()) {
    // Load initial data
    loadHomeData();
  }

  // Load home page data
  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _homeRepository.getHomeData();
    
    if (result['success']) {
      state = state.copyWith(
        isLoading: false,
        homeData: result['data'],
        categories: result['data'].categories,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result['message'],
      );
    }
  }

  // Load ride categories
  Future<void> loadRideCategories() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _homeRepository.getRideCategories();
    
    if (result['success']) {
      state = state.copyWith(
        isLoading: false,
        categories: result['categories'],
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result['message'],
      );
    }
  }

  // Refresh all data
  Future<void> refreshData() async {
    await loadHomeData();
  }
}

// Provider for home state
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final homeRepository = ref.watch(homeRepositoryProvider);
  return HomeNotifier(homeRepository);
});
