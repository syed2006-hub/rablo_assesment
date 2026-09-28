import 'package:get/get.dart';
import '../../models/D1MM5_my_profile/profile_model.dart';

/// D1MM5 – Profile Service managing gym administrator / staff profile details.
class ProfileService extends GetxService {
  static ProfileService get to => Get.find<ProfileService>();

  final Rx<ProfileModel> profile = ProfileModel(
    id: 'ADMIN-001',
    fullName: 'Arjun Nair',
    email: 'arjun.nair@fitnessapp.com',
    phoneNumber: '+91 98450 12345',
    role: 'Head Fitness Director',
    gymBranch: 'Koramangala Prime Club, Bengaluru',
    bio:
        'Certified Master Trainer & ACSM specialist with 9+ years managing gym fitness operations, strength conditioning, and athlete development.',
    memberSince: DateTime(2023, 3, 15),
    totalWorkoutsSupervised: 1420,
    rating: 4.9,
  ).obs;

  void updateProfile(ProfileModel updated) {
    profile.value = updated;
  }
}
