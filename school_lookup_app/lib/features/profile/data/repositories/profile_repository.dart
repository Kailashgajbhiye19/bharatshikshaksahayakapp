import 'package:hive/hive.dart';
import '../../domain/models/user_profile.dart';

class ProfileRepository {
  final Box _box;
  ProfileRepository(this._box);

  UserProfile getProfile() {
    return UserProfile(
      fullName: _box.get('fullName', defaultValue: 'Teacher Name'),
      email: _box.get('userEmail', defaultValue: 'teacher@example.com'),
      employeeId: _box.get('employeeId', defaultValue: 'N/A'),
      schoolName: _box.get('schoolName', defaultValue: 'Govt. School'),
      designation: _box.get('designation', defaultValue: 'Senior Teacher'),
    );
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _box.put('fullName', profile.fullName);
    await _box.put('userEmail', profile.email);
    await _box.put('employeeId', profile.employeeId);
    await _box.put('schoolName', profile.schoolName);
    await _box.put('designation', profile.designation);
  }
}
