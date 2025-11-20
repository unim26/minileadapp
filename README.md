# Mini Lead Manager — teamleadapp

This is a small CRM-style "Mini Lead Manager" Flutter app built for the internship assignment.

Features implemented:
------------

- Add / edit / delete leads
- View leads list with status badges
- Filter by status (All, New, Contacted, Converted, Lost)
- Search by name
- Lead detail screen with status update
- Local persistence using Hive
- State management with Cubit (flutter_bloc)

How to run
---------
- Install Flutter (stable) and ensure `flutter` is on your PATH.


```bash
git clone https://github.com/unim26/minileadapp.git
```

```bash
cd minileadapp
```

```bash
flutter pub get
```

```bash
flutter run
```

build  APK:

```bash
flutter build apk
```

Architecture
------------
- `lib/models/lead_model.dart` — Lead model and Hive TypeAdapter
- `lib/services/lead_storage.dart` —  wrapper around a Hive box for CRUD
- `lib/services/setting_storage.dart` —  wrapper around a Hive box for theme
- `lib/cubit/lead_cubit.dart` (+ `lead_state.dart`) — Cubit for lead list and actions
- `lib/cubit/theme_cubit.dart` — Cubit for theme  and actions
- `lib/screens/` — UI screens: list, add/edit, detail
- `lib/widgets/` — reusable widgets


Learning Resources
------------
📚 **Want to learn about Hive adapters?** Check out these guides:
- **[HIVE_ADAPTER_GUIDE.md](HIVE_ADAPTER_GUIDE.md)** — Comprehensive guide explaining how Hive adapters work with step-by-step examples
- **[HIVE_QUICK_REFERENCE.md](HIVE_QUICK_REFERENCE.md)** — Quick reference with templates and common patterns
- **Code comments** — The code now includes detailed educational comments explaining how everything works


Packages used
------------
- hive, hive_flutter — local database
- flutter_bloc — Cubit state management
- equatable — value equality for state


Notes
------------
- Hive TypeAdapter was written manually (no codegen) for simplicity.
- This is a minimal, functional implementation intended for evaluation. Possible improvements: unit tests, UI polish, export/import, pagination.
- images, videos and release apk is uploded to google drive and can be accessed through provided link



Google drive link
------------

[Drive (Abhishek Kumar)](https://drive.google.com/drive/folders/1cuI7BvEURVwwQ6BXrB3yeP63HujB6upz?usp=drive_link)





