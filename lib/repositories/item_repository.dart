

import '../models/user_details.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class UserRepository {
  final ApiService apiService;

  UserRepository(this.apiService);

  Future<List<User>> fetchUsers() async {
    return await apiService.getUsers();
  }
  Future<UserDetail> fetchUserDetails(int userId) async {
    return await apiService.getUserById(userId);
  }
}