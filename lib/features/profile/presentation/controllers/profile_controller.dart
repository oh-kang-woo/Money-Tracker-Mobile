import 'package:flutter/material.dart';
import 'package:utsproject/features/profile/domain/usecases/update_profile.dart';

class ProfileController extends ChangeNotifier {
  final UpdateProfile updateProfile;
  ProfileController({required this.updateProfile});
}