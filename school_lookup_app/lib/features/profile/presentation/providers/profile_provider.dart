import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../domain/models/user_profile.dart';
import '../../data/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider((ref) => ProfileRepository(Hive.box('settings')));

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
  return ProfileNotifier(ref.watch(profileRepositoryProvider));
});

class ProfileNotifier extends StateNotifier<UserProfile> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository) : super(_repository.getProfile());

  Future<void> updateProfile(UserProfile profile) async {
    await _repository.updateProfile(profile);
    state = profile;
  }
}
