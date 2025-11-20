import 'package:hive/hive.dart';

class SettingsStorage {
  static const String boxName = 'settings_box';
  static const String keyIsDark = 'isDark';

  final Box _box;

  SettingsStorage._(this._box);

  //init method
  static Future<SettingsStorage> init() async {
    final box = await Hive.openBox(boxName);
    return SettingsStorage._(box);
  }

  //get isDark function
  bool getIsDark([bool defaultValue = false]) {
    try {
      return _box.get(keyIsDark, defaultValue: defaultValue) as bool;
    } catch (_) {
      return defaultValue;
    }
  }

  //set isDark
  Future<void> setIsDark(bool v) async {
    await _box.put(keyIsDark, v);
  }
}
