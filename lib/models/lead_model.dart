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

//leadModel adapter
class LeadModelAdapter extends TypeAdapter<LeadModel> {
  @override
  final int typeId = 1;

  @override
  LeadModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return LeadModel(
      id: fields[0] as int,
      name: fields[1] as String,
      phone: fields[2] as String,
      email: fields[6] as String?,
      notes: fields[3] as String?,
      status: LeadStatus.values[fields[4] as int],
      createdAt: DateTime.fromMillisecondsSinceEpoch(fields[5] as int),
    );
  }

  @override
  void write(BinaryWriter writer, LeadModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.status.index)
      ..writeByte(5)
      ..write(obj.createdAt.millisecondsSinceEpoch)
      ..writeByte(6)
      ..write(obj.email);
  }
}
