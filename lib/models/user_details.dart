import 'package:yunusco_ppt_tv/models/user_model.dart';

class UserDetail extends User {
  final String phone;
  final Address address;

  UserDetail({
    required int id,
    required String name,
    required String email,
    required this.phone,
    required this.address,
  }) : super(id: id, name: name, email: email);

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      id: json['id'],
      name: '${json['firstName']} ${json['lastName']}',
      email: json['email'],
      phone: json['phone'],
      address: Address.fromJson(json['address']),
    );
  }
}

class Address {
  final String street;
  final String city;

  Address({required this.street, required this.city});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['address'] ?? json['street'], // Handle different API responses
      city: json['city'],
    );
  }
}