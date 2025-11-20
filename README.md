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
1. Install Flutter (stable) and ensure `flutter` is on your PATH.
2. From the project root run:

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
flutter build apk --debug
```

Architecture
------------
- `lib/models/lead_model.dart` — Lead model and Hive TypeAdapter
- `lib/services/lead_storage.dart` —  wrapper around a Hive box for CRUD
- `lib/services/setting_storage.dart` —  wrapper around a Hive box for theme
------------
- `lib/cubit/lead_cubit.dart` (+ `lead_state.dart`) — Cubit for lead list and actions
- `lib/cubit/theme_cubit.dart` — Cubit for theme  and actions
- `lib/screens/` — UI screens: list, add/edit, detail
- `lib/widgets/` — reusable widgets

Packages used
------------
- hive, hive_flutter — local database
- flutter_bloc — Cubit state management
- equatable — value equality for state

Notes
------------
- Hive TypeAdapter was written manually (no codegen) for simplicity.
- This is a minimal, functional implementation intended for evaluation. Possible improvements: unit tests, UI polish, export/import, pagination.


Release apk
------------



Images
------------

![11](https://github.com/user-attachments/assets/5e435795-b4f2-4296-a791-ebed7070fd22)
![6](https://github.com/user-attachments/assets/6a16ab82-4d02-4359-91cb-3e10bb472913)
![8](https://github.com/user-attachments/assets/da5ae86e-4d22-4213-a7c1-1e692b056860)
![9](https://github.com/user-attachments/assets/f3472543-93e6-4d1b-ab6d-380cbc7a1643)
![4](https://github.com/user-attachments/assets/7d3a4cf8-8c09-47ef-9ddd-35ac273f01af)
![3](https://github.com/user-attachments/assets/0988e7e5-115f-42d8-b211-a7e859f7b2ed)
![1](https://github.com/user-attachments/assets/763f5198-9f14-439c-bcb1-59fb639c8b15)
![2](https://github.com/user-attachments/assets/9c966b13-2c53-445c-b8ba-a69f41f3afa9)
![10](https://github.com/user-attachments/assets/cdf2aa24-8836-45b7-b295-327b6ada1984)
![13](https://github.com/user-attachments/assets/bdb9f542-ab60-48ca-8f03-98cc29ba2d8e)
![12](https://github.com/user-attachments/assets/e92b05bf-d798-4c1a-aad8-435052351fd1)
![14](https://github.com/user-attachments/assets/d4ee6aff-70ab-4a0d-bb8a-a2eef0551334)
![5](https://github.com/user-attachments/assets/632939aa-397d-47a1-b72a-60bc4560117b)

Video
------------



Uploading 1.mp4…

