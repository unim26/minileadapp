import 'package:hive/hive.dart';


class LeadModel {
  int id;
  String name;
  String phone;
  String? email;
  String? notes;
  LeadStatus status;
  DateTime createdAt;

  LeadModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.notes,
    this.status = LeadStatus.newLead,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  LeadModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? notes,
    LeadStatus? status,
    DateTime? createdAt,
  }) {
    return LeadModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }


  String get contact => phone;
}

enum LeadStatus { newLead, contacted, converted, lost }

// ============================================================================
// HIVE ADAPTER FOR LEADMODEL
// ============================================================================
// This adapter teaches Hive how to convert LeadModel objects to/from binary.
// Hive stores data in binary format for speed and efficiency.
// 
// Key Concepts:
// - TypeId: Unique identifier (1) for this adapter - NEVER change this!
// - Write: Converts LeadModel → Binary (Serialization)
// - Read: Converts Binary → LeadModel (Deserialization)
// 
// For a detailed explanation, see: HIVE_ADAPTER_GUIDE.md
// ============================================================================

class LeadModelAdapter extends TypeAdapter<LeadModel> {
  // TypeId uniquely identifies this adapter to Hive (must be 0-223)
  // IMPORTANT: Never change this after storing data, or Hive can't read it!
  @override
  final int typeId = 1;

  // ============================================================================
  // READ METHOD (Deserialization: Binary → LeadModel)
  // ============================================================================
  // This method is called when Hive reads a LeadModel from storage.
  // It reconstructs the Dart object from binary data.
  @override
  LeadModel read(BinaryReader reader) {
    // Step 1: Read how many fields were stored
    final numOfFields = reader.readByte();
    
    // Step 2: Create a map to store field_index → value
    // Using a map makes this version-tolerant (can handle missing fields)
    final fields = <int, dynamic>{};
    
    // Step 3: Read all fields and store them in the map
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    
    // Step 4: Reconstruct the LeadModel from stored values
    return LeadModel(
      id: fields[0] as int,                    // Field 0: id (int)
      name: fields[1] as String,               // Field 1: name (String)
      phone: fields[2] as String,              // Field 2: phone (String)
      email: fields[6] as String?,             // Field 6: email (nullable String)
      notes: fields[3] as String?,             // Field 3: notes (nullable String)
      
      // Field 4: status - Convert stored integer back to enum
      // LeadStatus.values is [newLead, contacted, converted, lost]
      // If stored value is 2, this gives LeadStatus.converted
      status: LeadStatus.values[fields[4] as int],
      
      // Field 5: createdAt - Convert milliseconds back to DateTime
      createdAt: DateTime.fromMillisecondsSinceEpoch(fields[5] as int),
    );
  }

  // ============================================================================
  // WRITE METHOD (Serialization: LeadModel → Binary)
  // ============================================================================
  // This method is called when Hive saves a LeadModel to storage.
  // It converts the Dart object into binary format.
  @override
  void write(BinaryWriter writer, LeadModel obj) {
    writer
      // Step 1: Write the number of fields (7 fields total)
      ..writeByte(7)
      
      // Step 2: Write each field with its index and value
      // Pattern: writeByte(index) then write(value)
      
      // Field 0: id
      ..writeByte(0)
      ..write(obj.id)
      
      // Field 1: name
      ..writeByte(1)
      ..write(obj.name)
      
      // Field 2: phone
      ..writeByte(2)
      ..write(obj.phone)
      
      // Field 3: notes (can be null)
      ..writeByte(3)
      ..write(obj.notes)
      
      // Field 4: status - Convert enum to integer
      // .index gives: newLead=0, contacted=1, converted=2, lost=3
      ..writeByte(4)
      ..write(obj.status.index)
      
      // Field 5: createdAt - Convert DateTime to milliseconds (int)
      // This is necessary because Hive doesn't natively support DateTime
      ..writeByte(5)
      ..write(obj.createdAt.millisecondsSinceEpoch)
      
      // Field 6: email (can be null)
      ..writeByte(6)
      ..write(obj.email);
  }
  
  // ============================================================================
  // NOTES FOR LEARNERS:
  // ============================================================================
  // 1. Field indices (0, 1, 2, etc.) should NEVER be changed after deployment
  // 2. To add new fields: use the next available index (7, 8, etc.)
  // 3. The field order in write() doesn't have to match read() because we use indices
  // 4. The map approach in read() makes the adapter version-tolerant
  // 5. For enums: use .index to write, and EnumName.values[index] to read
  // 6. For DateTime: use .millisecondsSinceEpoch to write, and 
  //    DateTime.fromMillisecondsSinceEpoch() to read
  // ============================================================================
}
