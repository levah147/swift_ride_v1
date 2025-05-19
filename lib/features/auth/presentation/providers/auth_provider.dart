import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

// Auth state
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? errorMessage;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState()) {
    // Check if user is already logged in
    checkAuthStatus();
  }

  // Check if user is logged in
  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    
    final isLoggedIn = await _authRepository.isLoggedIn();
    
    if (isLoggedIn) {
      final result = await _authRepository.getUserProfile();
      if (result['success']) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: result['user'],
        );
      } else {
        // Token might be invalid, log out
        await _authRepository.logout();
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          user: null,
        );
      }
    } else {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
      );
    }
  }

  // Register a new user
  Future<bool> register({
    required String email,
    required String phoneNumber,
    required String fullName,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _authRepository.register(
      email: email,
      phoneNumber: phoneNumber,
      fullName: fullName,
      password: password,
      confirmPassword: confirmPassword,
    );
    
    if (result['success']) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: result['user'],
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

  // Login user
  Future<bool> login({
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _authRepository.login(
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );
    
    if (result['success']) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: result['user'],
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

  // Logout user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    await _authRepository.logout();
    
    state = state.copyWith(
      isLoading: false,
      isAuthenticated: false,
      user: null,
    );
  }

  // Update user profile
  Future<bool> updateProfile({
    String? fullName,
    String? email,
    String? phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _authRepository.updateUserProfile(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
    );
    
    if (result['success']) {
      state = state.copyWith(
        isLoading: false,
        user: result['user'],
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

  // Change password
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _authRepository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    
    state = state.copyWith(isLoading: false);
    
    if (result['success']) {
      return true;
    } else {
      state = state.copyWith(errorMessage: result['message']);
      return false;
    }
  }

  sendPasswordReset({String? email, String? phone}) {}
}

// Provider for auth state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
