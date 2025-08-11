import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/item_model.dart';
import '../repositories/item_repository.dart';
import '../services/api_service.dart';


// ApiService Provider
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Repository Provider
final userRepositoryProvider = Provider<UserRepository>(
      (ref) => UserRepository(ref.read(apiServiceProvider)),
);

// FutureProvider for fetching users
final userList = FutureProvider<List<User>>((ref) async {
  final repo = ref.read(userRepositoryProvider);
  return await repo.getUsers();
});
