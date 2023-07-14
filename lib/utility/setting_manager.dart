import 'dart:convert';
import 'dart:io';

import 'package:image_resizer/model/image_resize_config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SettingKey {
  threads('threads');

  const SettingKey(this.name);
  final String name;
}

class SettingManager {
  static final SettingManager _singleton = SettingManager._private();
  List<ImageResizeConfig> profiles = [];
  SharedPreferences? _prefs;
  String documentsPath = '';

  SettingManager._private();

  Future<void> loadProfile() async {
    _prefs ??= await SharedPreferences.getInstance();
    Directory directory = await getApplicationDocumentsDirectory();
    documentsPath = directory.path;
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

  Future<void> setSetting(SettingKey key, String value) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(key.name, value);
  }

  Future<String?> getSetting(SettingKey key) async {
    _prefs ??= await SharedPreferences.getInstance();
    String? value = _prefs!.getString(key.name);
    return value;
  }

  factory SettingManager() {
    return _singleton;
  }
}
