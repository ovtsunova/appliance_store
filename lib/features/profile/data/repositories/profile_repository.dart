import 'package:dio/dio.dart';

import '../../domain/models/address.dart';
import '../../domain/models/user_profile.dart';

class ProfileRepository {
  final Dio dio;

  const ProfileRepository(this.dio);

  Future<UserProfile> getProfile() async {
    final response = await dio.get('/profile');
    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> updateProfile(UserProfile profile) async {
    await dio.put(
      '/profile',
      data: profile.toUpdateJson(),
    );
  }

  Future<void> createAddress(Address address) async {
    await dio.post(
      '/addresses',
      data: address.toCreateJson(),
    );
  }

  Future<void> updateAddress(Address address) async {
    if (address.id == null) {
      throw Exception('Не указан идентификатор адреса');
    }

    await dio.patch(
      '/addresses/${address.id}',
      data: address.toUpdateJson(),
    );
  }

  Future<void> deleteAddress(int addressId) async {
    await dio.delete('/addresses/$addressId');
  }
}