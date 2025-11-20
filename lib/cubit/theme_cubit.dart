import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/settings_storage.dart';

class ThemeCubit extends Cubit<bool> {
  final SettingsStorage storage;

  ThemeCubit({required this.storage}) : super(storage.getIsDark());

  Future<void> toggle() async {
    final next = !state;
    emit(next);
    await storage.setIsDark(next);
  }
}
