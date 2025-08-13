import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_details.dart';
import '../models/user_model.dart';
import '../repositories/item_repository.dart';
import '../services/api_service.dart';


// Service Provider
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.read(apiServiceProvider));
});

// Main Provider that exposes users
final usersProvider = FutureProvider<List<User>>((ref) async {
  final repository = ref.read(userRepositoryProvider);
  return await repository.fetchUsers();
});

final userDetailProvider = FutureProvider.autoDispose.family<UserDetail, int>((ref, userId) async {
  final repository = ref.read(userRepositoryProvider);
  return await repository.fetchUserDetails(userId);
});

