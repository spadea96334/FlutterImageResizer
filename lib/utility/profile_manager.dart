import 'dart:convert';

import 'package:image_resizer/model/image_resize_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileManager {
  static final ProfileManager _singleton = ProfileManager._private();
  List<ImageResizeConfig> profiles = [];
  SharedPreferences? _prefs;

  ProfileManager._private();

  Future<void> loadProfile() async {
    _prefs ??= await SharedPreferences.getInstance();
    String? jsonString = _prefs!.get('profiles') as String?;
    if (jsonString == null) {
      createDefaultProfile();
      return;
    }

    Map<String, dynamic> json = jsonDecode(jsonString);
    try {
      profiles = ImageResizeProfiles.fromJson(json).profiles;
    } catch (error) {
      createDefaultProfile();
    }
  }

  Future<void> saveProfile() async {
    _prefs ??= await SharedPreferences.getInstance();
    ImageResizeProfiles profiles = ImageResizeProfiles();
    profiles.profiles = this.profiles;
    await _prefs!.setString('profiles', jsonEncode(profiles.toJson()));
  }

  void createDefaultProfile() {
    ImageResizeConfig config = ImageResizeConfig();
    config.name = 'default';
    profiles.add(config);
  }

  factory ProfileManager() {
    return _singleton;
  }
}
