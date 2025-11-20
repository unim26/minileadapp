# Hive Adapter Guide - Understanding Local Storage in Flutter

## Table of Contents
1. [What is Hive?](#what-is-hive)
2. [What is a Hive Adapter?](#what-is-a-hive-adapter)
3. [Understanding the LeadModelAdapter](#understanding-the-leadmodeladapter)
4. [How Serialization Works](#how-serialization-works)
5. [How Deserialization Works](#how-deserialization-works)
6. [Creating Your Own Adapter](#creating-your-own-adapter)
7. [Best Practices](#best-practices)

---

## What is Hive?

**Hive** is a lightweight and blazing-fast key-value database written in pure Dart. It's perfect for Flutter applications because:

- **No native dependencies**: Works on all platforms (iOS, Android, Web, Desktop)
- **Fast**: Optimized for mobile with lazy loading
- **Lightweight**: Small footprint (~1.5MB)
- **Strong encryption**: Built-in AES-256 encryption support
- **Type-safe**: Compile-time type checking with adapters

In this project, Hive is used to:
- Store lead information persistently (LeadModel objects)
- Store app settings like theme preference (dark/light mode)

---

## What is a Hive Adapter?

A **Hive Adapter** is a bridge between your Dart objects and Hive's binary storage format. 

### Why do we need adapters?

Hive stores data in a binary format for efficiency. Since Dart objects (like `LeadModel`) can't be directly converted to binary, we need an adapter to:

1. **Serialize**: Convert Dart objects → Binary data (for writing to storage)
2. **Deserialize**: Convert Binary data → Dart objects (for reading from storage)

### Two ways to create adapters:

1. **Manual** (used in this project): Write the adapter code yourself
2. **Code generation**: Use `hive_generator` to auto-generate adapters

This project uses the **manual approach** for learning purposes and to avoid build dependencies.

---

## Understanding the LeadModelAdapter

Let's break down the `LeadModelAdapter` from `lib/models/lead_model.dart`:

```dart
class LeadModelAdapter extends TypeAdapter<LeadModel> {
  @override
  final int typeId = 1;  // Unique identifier for this adapter

  @override
  LeadModel read(BinaryReader reader) {
    // Deserialization: Binary → LeadModel
  }

  @override
  void write(BinaryWriter writer, LeadModel obj) {
    // Serialization: LeadModel → Binary
  }
}
```

### Key Components:

#### 1. **TypeId**
```dart
final int typeId = 1;
```
- Every adapter needs a **unique** typeId (0-223)
- This tells Hive which adapter to use when reading data
- **Important**: Never change this after storing data, or Hive won't be able to read it!

#### 2. **Read Method (Deserialization)**
The `read` method reconstructs a `LeadModel` object from binary data.

#### 3. **Write Method (Serialization)**
The `write` method converts a `LeadModel` object into binary data.

---

## How Serialization Works

When you save a `LeadModel` to Hive, the `write` method is called:

```dart
@override
void write(BinaryWriter writer, LeadModel obj) {
  writer
    ..writeByte(7)              // Field count: 7 fields to write
    ..writeByte(0)              // Field index 0
    ..write(obj.id)             // Write id value
    ..writeByte(1)              // Field index 1
    ..write(obj.name)           // Write name value
    ..writeByte(2)              // Field index 2
    ..write(obj.phone)          // Write phone value
    ..writeByte(3)              // Field index 3
    ..write(obj.notes)          // Write notes value
    ..writeByte(4)              // Field index 4
    ..write(obj.status.index)   // Write status as integer index
    ..writeByte(5)              // Field index 5
    ..write(obj.createdAt.millisecondsSinceEpoch)  // Write date as milliseconds
    ..writeByte(6)              // Field index 6
    ..write(obj.email);         // Write email value
}
```

### Step-by-Step Process:

1. **Write field count**: `writeByte(7)` - tells Hive we're writing 7 fields
2. **For each field**:
   - Write the field index (0, 1, 2, etc.)
   - Write the actual value
3. **Special conversions**:
   - `LeadStatus` enum → `status.index` (converts enum to integer)
   - `DateTime` → `millisecondsSinceEpoch` (converts date to integer)

### Binary Format Example:
```
[7] [0] [id_value] [1] [name_value] [2] [phone_value] ...
 │   │      │       │       │         │       │
 │   │      │       │       │         │       └─ Phone data
 │   │      │       │       └─────────┴─────── Name field and data
 │   └──────┴───── ID field and data
 └─────────────── Number of fields
```

---

## How Deserialization Works

When you read a `LeadModel` from Hive, the `read` method is called:

```dart
@override
LeadModel read(BinaryReader reader) {
  final numOfFields = reader.readByte();  // Read field count
  final fields = <int, dynamic>{};        // Map to store field_index → value
  
  // Read all fields into the map
  for (var i = 0; i < numOfFields; i++) {
    fields[reader.readByte()] = reader.read();
  }
  
  // Reconstruct the LeadModel
  return LeadModel(
    id: fields[0] as int,
    name: fields[1] as String,
    phone: fields[2] as String,
    email: fields[6] as String?,
    notes: fields[3] as String?,
    status: LeadStatus.values[fields[4] as int],  // Convert int back to enum
    createdAt: DateTime.fromMillisecondsSinceEpoch(fields[5] as int),  // Convert milliseconds back to DateTime
  );
}
```

### Step-by-Step Process:

1. **Read field count**: How many fields were saved
2. **Read all fields**: Loop through and store field_index → value in a map
3. **Reconstruct object**: Create new `LeadModel` using the stored values
4. **Special conversions**:
   - Integer → `LeadStatus` enum using `LeadStatus.values[index]`
   - Milliseconds → `DateTime` using `DateTime.fromMillisecondsSinceEpoch()`

### Why use a Map?

The map approach (`fields[index] = value`) makes the adapter **version-tolerant**:
- If you add new fields later, old data can still be read
- Missing fields can have default values
- Field order doesn't matter during reading

---

## Creating Your Own Adapter

Let's create an example adapter for a `Task` model:

### Step 1: Define your model
```dart
class Task {
  final int id;
  final String title;
  final bool isCompleted;
  final DateTime dueDate;
  
  Task({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.dueDate,
  });
}
```

### Step 2: Create the adapter
```dart
class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 2;  // Use a unique ID (not 1, since LeadModel uses 1)

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    
    return Task(
      id: fields[0] as int,
      title: fields[1] as String,
      isCompleted: fields[2] as bool,
      dueDate: DateTime.fromMillisecondsSinceEpoch(fields[3] as int),
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(4)  // 4 fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.dueDate.millisecondsSinceEpoch);
  }
}
```

### Step 3: Register the adapter
```dart
void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());  // Register before using
  
  // Now you can use Task objects with Hive
  final box = await Hive.openBox<Task>('tasks');
}
```

---

## Best Practices

### 1. **TypeId Management**
- Keep a list of all your typeIds in one place
- Never reuse or change typeIds
- Use 0-223 range for custom adapters

### 2. **Field Indices**
- Use consistent field indices
- Don't change existing indices
- Add new fields with new indices at the end

### 3. **Nullable Fields**
- Handle nullable fields carefully
- Cast to nullable types: `fields[6] as String?`
- Provide defaults for missing fields

### 4. **Data Types**
Hive natively supports:
- `int`, `double`, `bool`, `String`
- `List`, `Map`
- `DateTime` (needs conversion to milliseconds)
- `Uint8List`

For other types:
- **Enums**: Convert to/from index
- **Custom objects**: Create another adapter
- **DateTime**: Convert to/from milliseconds

### 5. **Versioning**
If you need to add fields later:

```dart
// OLD: 3 fields
return Task(
  id: fields[0] as int,
  title: fields[1] as String,
  isCompleted: fields[2] as bool,
);

// NEW: 4 fields (added dueDate with default)
return Task(
  id: fields[0] as int,
  title: fields[1] as String,
  isCompleted: fields[2] as bool,
  dueDate: fields[3] != null 
    ? DateTime.fromMillisecondsSinceEpoch(fields[3] as int)
    : DateTime.now(),  // Default for old data
);
```

### 6. **Testing**
Always test your adapters:
```dart
test('Task adapter serialization', () async {
  Hive.registerAdapter(TaskAdapter());
  
  final task = Task(id: 1, title: 'Test', isCompleted: false, dueDate: DateTime.now());
  
  final box = await Hive.openBox<Task>('test_box');
  await box.put('task1', task);
  
  final retrieved = box.get('task1');
  expect(retrieved?.title, 'Test');
});
```

---

## How It's Used in This Project

### 1. **Initialization** (`main.dart`)
```dart
await Hive.initFlutter();              // Initialize Hive
Hive.registerAdapter(LeadModelAdapter());  // Register adapter
await Hive.openBox(LeadStorage.boxName);   // Open box
```

### 2. **Storage Wrapper** (`lead_storage.dart`)
```dart
class LeadStorage {
  final Box _box;
  
  Future<void> addLead(LeadModel lead) async {
    await _box.put(lead.id.toString(), lead);  // Adapter auto-serializes
  }
  
  LeadModel? getLead(int id) {
    return _box.get(id.toString()) as LeadModel?;  // Adapter auto-deserializes
  }
}
```

### 3. **Usage in App**
```dart
// In your cubit or service
final storage = await LeadStorage.init();
final lead = LeadModel(id: 1, name: 'John', phone: '123-456');

await storage.addLead(lead);  // Serialized and saved
final retrieved = storage.getLead(1);  // Deserialized and returned
```

---

## Common Issues and Solutions

### Issue 1: "Cannot read, unknown typeId"
**Solution**: Make sure you register the adapter before opening boxes:
```dart
Hive.registerAdapter(LeadModelAdapter());  // Register first
await Hive.openBox('leads_box');           // Then open box
```

### Issue 2: "Type mismatch"
**Solution**: Ensure field indices match between write and read:
```dart
// Write field 0 as int
..writeByte(0)
..write(obj.id)

// Read field 0 as int (not String!)
id: fields[0] as int
```

### Issue 3: "Data corrupted after adding field"
**Solution**: Handle missing fields with defaults:
```dart
newField: fields[7] != null ? fields[7] as String : 'default'
```

---

## Summary

### Key Takeaways:

1. **Hive Adapters** convert Dart objects ↔ Binary format
2. **TypeId** uniquely identifies each adapter (never change it!)
3. **Write method** serializes objects for storage
4. **Read method** deserializes binary data back to objects
5. **Field indices** create a flexible, version-tolerant format
6. **Special types** (DateTime, enums) need manual conversion

### The Power of Hive:

- **Fast**: Binary format is much faster than JSON
- **Efficient**: Smaller storage size
- **Type-safe**: Compile-time checking prevents errors
- **Flexible**: Easy to add fields without breaking old data

---

## Next Steps

1. **Experiment**: Modify the `LeadModelAdapter` and see what happens
2. **Create**: Make your own adapter for a new model
3. **Explore**: Check out `settings_storage.dart` for primitive type storage (no adapter needed!)
4. **Learn more**: Visit [Hive documentation](https://docs.hivedb.dev/)

---

## Additional Resources

- **Hive Documentation**: https://docs.hivedb.dev/
- **Hive GitHub**: https://github.com/hivedb/hive
- **Flutter Storage Options**: https://docs.flutter.dev/cookbook/persistence/

---

*This guide is part of the Mini Lead Manager project. Feel free to explore the code and experiment!*
