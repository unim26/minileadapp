import 'package:hive/hive.dart';
import '../models/lead_model.dart';

//storage exception
class StorageException implements Exception {
  final String message;
  StorageException(this.message);
  @override
  String toString() => 'StorageException: $message';
}

//lead storage
class LeadStorage {
  static const String boxName = 'leads_box';

  final Box _box;

  LeadStorage._(this._box);

  //init method
  static Future<LeadStorage> init() async {
    try {
      final box = await Hive.openBox(boxName);
      return LeadStorage._(box);
    } catch (e) {
      throw StorageException('Failed to open storage: $e');
    }
  }

  //get all lead function
  List<LeadModel> getAllLeads() {
    try {
      return _box.values.cast<LeadModel>().toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw StorageException('Failed to read leads: $e');
    }
  }

  //add lead function
  Future<void> addLead(LeadModel lead) async {
    try {

      await _box.put(lead.id.toString(), lead);
    } catch (e) {
      throw StorageException('Failed to add lead: $e');
    }
  }

  //update lead function
  Future<void> updateLead(LeadModel lead) async {
    try {
      await _box.put(lead.id.toString(), lead);
    } catch (e) {
      throw StorageException('Failed to update lead: $e');
    }
  }

  //delete lead function
  Future<void> deleteLead(int id) async {
    try {
      await _box.delete(id.toString());
    } catch (e) {
      throw StorageException('Failed to delete lead: $e');
    }
  }

  //get lead function
  LeadModel? getLead(int id) {
    try {
      return _box.get(id.toString()) as LeadModel?;
    } catch (e) {
      throw StorageException('Failed to get lead: $e');
    }
  }


}
