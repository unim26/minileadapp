# Hive Adapter Quick Reference

## Quick Start Checklist

✅ **Setup (do once in main.dart)**
```dart
await Hive.initFlutter();
Hive.registerAdapter(YourModelAdapter());
await Hive.openBox('your_box_name');
```

✅ **Create an Adapter**
```dart
class YourModelAdapter extends TypeAdapter<YourModel> {
  @override
  final int typeId = X;  // Unique number 0-223
  
  @override
  YourModel read(BinaryReader reader) { /* ... */ }
  
  @override
  void write(BinaryWriter writer, YourModel obj) { /* ... */ }
}
```

✅ **Use the Box**
```dart
final box = await Hive.openBox('box_name');
await box.put('key', value);  // Save
final value = box.get('key');  // Load
await box.delete('key');       // Delete
```

---

## Adapter Template

Copy and modify this template for your own models:

```dart
import 'package:hive/hive.dart';

// Your model class
class YourModel {
  final int id;
  final String name;
  final bool isActive;
  
  YourModel({
    required this.id,
    required this.name,
    required this.isActive,
  });
}

// Your adapter class
class YourModelAdapter extends TypeAdapter<YourModel> {
  @override
  final int typeId = 2;  // ⚠️ CHANGE THIS - must be unique!

  @override
  YourModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    
    return YourModel(
      id: fields[0] as int,
      name: fields[1] as String,
      isActive: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, YourModel obj) {
    writer
      ..writeByte(3)  // Number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.isActive);
  }
}
```

---

## Common Data Type Conversions

### Enums
```dart
// Write
..write(obj.status.index)  // Enum → int

// Read
status: MyEnum.values[fields[X] as int]  // int → Enum
```

### DateTime
```dart
// Write
..write(obj.date.millisecondsSinceEpoch)  // DateTime → int

// Read
date: DateTime.fromMillisecondsSinceEpoch(fields[X] as int)  // int → DateTime
```

### Nullable Fields
```dart
// Write (Hive handles nulls automatically)
..write(obj.optionalField)

// Read (cast to nullable type)
optionalField: fields[X] as String?
```

### Lists
```dart
// Write (Hive handles Lists automatically)
..write(obj.myList)

// Read
myList: (fields[X] as List).cast<String>()
```

### Custom Objects (needs another adapter)
```dart
// Write
..write(obj.customObject)  // Must have its own adapter registered

// Read
customObject: fields[X] as CustomType
```

---

## Field Management

### Adding a New Field (Safe)
```dart
// OLD version (3 fields)
void write(BinaryWriter writer, Model obj) {
  writer
    ..writeByte(3)  // 3 fields
    ..writeByte(0)..write(obj.field1)
    ..writeByte(1)..write(obj.field2)
    ..writeByte(2)..write(obj.field3);
}

// NEW version (4 fields) - just add at the end!
void write(BinaryWriter writer, Model obj) {
  writer
    ..writeByte(4)  // NOW 4 fields
    ..writeByte(0)..write(obj.field1)
    ..writeByte(1)..write(obj.field2)
    ..writeByte(2)..write(obj.field3)
    ..writeByte(3)..write(obj.newField);  // NEW!
}

// In read(), provide default for missing field:
newField: fields[3] != null ? fields[3] as String : 'default'
```

### ⚠️ Don't Do This!
```dart
// ❌ Don't change typeId
typeId = 2  // Was 1, now 2 - BREAKS OLD DATA!

// ❌ Don't change existing field indices
..writeByte(0)..write(obj.name)  // Was obj.id!

// ❌ Don't change field types
id: fields[0] as String  // Was int!
```

---

## Common Patterns

### Pattern 1: Storage Service (Recommended)
```dart
class MyStorage {
  static const boxName = 'my_box';
  final Box _box;
  
  MyStorage._(this._box);
  
  static Future<MyStorage> init() async {
    final box = await Hive.openBox(boxName);
    return MyStorage._(box);
  }
  
  Future<void> save(String key, MyModel model) async {
    await _box.put(key, model);
  }
  
  MyModel? get(String key) {
    return _box.get(key) as MyModel?;
  }
}
```

### Pattern 2: Direct Box Access (Simple)
```dart
final box = await Hive.openBox<MyModel>('my_box');
await box.put('key', myModel);
final model = box.get('key');
```

### Pattern 3: Auto-incrementing IDs
```dart
class MyStorage {
  int _getNextId() {
    final allIds = _box.keys.map((k) => int.parse(k)).toList();
    return allIds.isEmpty ? 1 : allIds.reduce(max) + 1;
  }
  
  Future<void> add(MyModel model) async {
    final id = _getNextId();
    final newModel = model.copyWith(id: id);
    await _box.put(id.toString(), newModel);
  }
}
```

---

## Debugging Tips

### Check Registered Adapters
```dart
print(Hive.isAdapterRegistered(1));  // true if typeId 1 is registered
```

### View All Keys
```dart
print(box.keys);  // See all keys in the box
```

### View All Values
```dart
print(box.values);  // See all stored objects
```

### Clear All Data (for testing)
```dart
await box.clear();  // Remove all entries
```

### Delete Box Completely
```dart
await box.deleteFromDisk();  // Delete the entire box file
```

---

## Performance Tips

1. **Lazy Boxes** for large data:
   ```dart
   final box = await Hive.openLazyBox('large_box');
   final value = await box.get('key');  // Only loads when accessed
   ```

2. **Batch Operations**:
   ```dart
   await box.putAll({
     'key1': model1,
     'key2': model2,
     'key3': model3,
   });
   ```

3. **Listen to Changes**:
   ```dart
   box.watch().listen((event) {
     print('Key ${event.key} changed');
   });
   ```

---

## Error Handling

```dart
try {
  await box.put('key', value);
} catch (e) {
  if (e is HiveError) {
    print('Hive error: $e');
  } else {
    print('Unknown error: $e');
  }
}
```

---

## Migration Example

When you need to change your data structure:

```dart
@override
MyModel read(BinaryReader reader) {
  final numOfFields = reader.readByte();
  final fields = <int, dynamic>{};
  
  for (var i = 0; i < numOfFields; i++) {
    fields[reader.readByte()] = reader.read();
  }
  
  // Handle old data without 'email' field
  return MyModel(
    id: fields[0] as int,
    name: fields[1] as String,
    email: fields[2] != null 
      ? fields[2] as String 
      : 'no-email@example.com',  // Default for old records
  );
}
```

---

## Testing Your Adapter

```dart
void main() {
  test('Adapter serialization works', () async {
    await Hive.initFlutter();
    Hive.registerAdapter(MyModelAdapter());
    
    final box = await Hive.openBox('test_box');
    final original = MyModel(id: 1, name: 'Test');
    
    await box.put('test', original);
    final retrieved = box.get('test') as MyModel;
    
    expect(retrieved.id, original.id);
    expect(retrieved.name, original.name);
    
    await box.close();
    await box.deleteFromDisk();
  });
}
```

---

## This Project's Adapters

### LeadModelAdapter (typeId: 1)
- **Location**: `lib/models/lead_model.dart`
- **Stores**: Lead information (name, phone, email, status, etc.)
- **Field Count**: 7 fields
- **Special Handling**: Enum (LeadStatus), DateTime

### No Adapter Needed
- **SettingsStorage**: Stores primitive types (bool for theme)
- **Primitive types**: int, String, bool, double don't need adapters

---

## Resources

- **Full Guide**: See `HIVE_ADAPTER_GUIDE.md` for detailed explanations
- **Code Examples**: Check `lib/models/lead_model.dart` and `lib/services/lead_storage.dart`
- **Official Docs**: https://docs.hivedb.dev/

---

## Summary

**3 Steps to Use Hive:**
1. **Init & Register**: `Hive.initFlutter()` → `registerAdapter()` → `openBox()`
2. **Create Adapter**: Extend `TypeAdapter`, implement `read()` and `write()`
3. **Use Box**: `put()` to save, `get()` to load, `delete()` to remove

**Key Rule**: TypeId and field indices = permanent! Never change them.

---

*Quick reference for the Mini Lead Manager project*
