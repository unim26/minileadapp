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

  // ============================================================================
  // HIVE INITIALIZATION PROCESS
  // ============================================================================
  // This is the standard 3-step process to set up Hive in a Flutter app:
  
  // Step 1: Initialize Hive with Flutter-specific path handling
  // This sets up Hive to store data in the correct app directory
  await Hive.initFlutter();

  // Step 2: Register all custom TypeAdapters
  // IMPORTANT: Adapters must be registered BEFORE opening boxes that use them
  // Each adapter teaches Hive how to serialize/deserialize a custom type
  Hive.registerAdapter(LeadModelAdapter());
  // Note: Primitive types (String, int, bool) don't need adapters
  
  // Step 3: Open the Hive boxes (similar to opening database tables)
  // A "box" is like a key-value store or table in traditional databases
  await Hive.openBox(LeadStorage.boxName);     // Box for storing LeadModel objects
  await Hive.openBox(SettingsStorage.boxName); // Box for storing app settings (theme)

  // ============================================================================
  // STORAGE LAYER INITIALIZATION
  // ============================================================================
  // Create wrapper classes that provide a clean API over the raw Hive boxes
  // These wrappers handle CRUD operations and error handling
  final storage = await LeadStorage.init();     // Manages lead data
  final settings = await SettingsStorage.init(); // Manages app settings

  // Run the app with the storage instances
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
