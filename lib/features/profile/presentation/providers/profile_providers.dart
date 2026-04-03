import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/profile_repository.dart';
import '../../domain/models/address.dart';
import '../../domain/models/user_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.read(dioProvider));
});

final profileProvider = FutureProvider<UserProfile>((ref) async {
  return ref.read(profileRepositoryProvider).getProfile();
});

class ProfileController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  final ProfileRepository repository;

  ProfileController({
    required this.ref,
    required this.repository,
  }) : super(const AsyncValue.data(null));

  Future<void> updateProfile(UserProfile profile) async {
    state = const AsyncValue.loading();
    try {
      await repository.updateProfile(profile);
      ref.invalidate(profileProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> createAddress(Address address) async {
    state = const AsyncValue.loading();
    try {
      await repository.createAddress(address);
      ref.invalidate(profileProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateAddress(Address address) async {
    state = const AsyncValue.loading();
    try {
      await repository.updateAddress(address);
      ref.invalidate(profileProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteAddress(int addressId) async {
    state = const AsyncValue.loading();
    try {
      await repository.deleteAddress(addressId);
      ref.invalidate(profileProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<void>>((ref) {
  return ProfileController(
    ref: ref,
    repository: ref.read(profileRepositoryProvider),
  );
});