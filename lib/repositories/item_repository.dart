

import '../models/item_model.dart';
import '../services/api_service.dart';

class UserRepository {
  final ApiService apiService;

  UserRepository(this.apiService);

  Future<List<User>> getUsers() async {
    try {
      return await apiService.fetchUsers();
    } catch (e) {
      throw Exception('Repository Error: ${e.toString()}');
    }
  }
}
