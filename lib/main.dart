import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'models/lead_model.dart';
import 'services/lead_storage.dart';
import 'services/settings_storage.dart';
import 'cubit/lead_cubit.dart';
import 'cubit/theme_cubit.dart';
import 'screens/lead_list_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(LeadModelAdapter());
  // open boxes early
  await Hive.openBox(LeadStorage.boxName);
  await Hive.openBox(SettingsStorage.boxName);

  // Initialize storage instances
  final storage = await LeadStorage.init();
  final settings = await SettingsStorage.init();

  // Run the app
  runApp(MainApp(storage: storage, settings: settings));
}

class MainApp extends StatelessWidget {
  // Storage instances
  final LeadStorage storage;
  final SettingsStorage settings;

  // Constructor
  const MainApp({super.key, required this.storage, required this.settings});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provide LeadCubit and ThemeCubit
        BlocProvider<LeadCubit>(create: (_) => LeadCubit(storage: storage)),
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit(storage: settings)),
      ],
      child: BlocBuilder<ThemeCubit, bool>(
        builder: (context, isDark) {
          return MaterialApp(
            title: 'Mini Lead Manager',
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            home: const LeadListScreen(),
          );
        },
      ),
    );
  }
}
