import 'package:hive/hive.dart';
import '../models/lead_model.dart';

// ============================================================================
// STORAGE EXCEPTION
// ============================================================================
// Custom exception for storage-related errors
// This provides better error messages for debugging
class StorageException implements Exception {
  final String message;
  StorageException(this.message);
  @override
  String toString() => 'StorageException: $message';
}

// ============================================================================
// LEAD STORAGE SERVICE
// ============================================================================
// This class wraps a Hive box and provides a clean API for CRUD operations.
// It abstracts away the Hive-specific details from the rest of the app.
//
// Key Concepts:
// - Box: A Hive box is like a key-value store (think Map<String, dynamic>)
// - The LeadModelAdapter handles all serialization automatically
// - We use lead.id.toString() as the key for easy lookup
// ============================================================================

class LeadStorage {
  // Box name constant - must match the name used in Hive.openBox()
  static const String boxName = 'leads_box';

  // Private Hive box instance
  // This is the underlying storage container
  final Box _box;

  // Private constructor - enforces using init() factory method
  LeadStorage._(this._box);

  // ============================================================================
  // INITIALIZATION
  // ============================================================================
  // Factory method to create a LeadStorage instance
  // This pattern ensures the box is opened before creating the storage instance
  static Future<LeadStorage> init() async {
    try {
      // Open (or get if already open) the Hive box
      final box = await Hive.openBox(boxName);
      return LeadStorage._(box);
    } catch (e) {
      throw StorageException('Failed to open storage: $e');
    }
  }

  // ============================================================================
  // READ OPERATIONS
  // ============================================================================
  
  // Get all leads from storage
  // Returns: List of all LeadModel objects, sorted by creation date (newest first)
  List<LeadModel> getAllLeads() {
    try {
      // _box.values returns all values in the box
      // cast<LeadModel>() tells Dart these are LeadModel objects
      // The LeadModelAdapter automatically deserializes each object
      return _box.values.cast<LeadModel>().toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by date
    } catch (e) {
      throw StorageException('Failed to read leads: $e');
    }
  }

  // Get a single lead by ID
  // Returns: LeadModel if found, null if not found
  LeadModel? getLead(int id) {
    try {
      // Get value by key (id as string)
      // The LeadModelAdapter automatically deserializes the binary data
      return _box.get(id.toString()) as LeadModel?;
    } catch (e) {
      throw StorageException('Failed to get lead: $e');
    }
  }

  // ============================================================================
  // WRITE OPERATIONS
  // ============================================================================
  
  // Add a new lead to storage
  // The LeadModelAdapter automatically serializes the LeadModel to binary
  Future<void> addLead(LeadModel lead) async {
    try {
      // put(key, value) adds or updates the entry
      // The LeadModelAdapter.write() is called automatically here
      await _box.put(lead.id.toString(), lead);
    } catch (e) {
      throw StorageException('Failed to add lead: $e');
    }
  }

  // Update an existing lead
  // Note: In Hive, add and update use the same put() method
  // If the key exists, it updates; if not, it creates
  Future<void> updateLead(LeadModel lead) async {
    try {
      await _box.put(lead.id.toString(), lead);
    } catch (e) {
      throw StorageException('Failed to update lead: $e');
    }
  }

  // ============================================================================
  // DELETE OPERATIONS
  // ============================================================================
  
  // Delete a lead by ID
  Future<void> deleteLead(int id) async {
    try {
      // delete(key) removes the entry from the box
      await _box.delete(id.toString());
    } catch (e) {
      throw StorageException('Failed to delete lead: $e');
    }
  }

  // ============================================================================
  // HOW HIVE ADAPTER WORKS BEHIND THE SCENES:
  // ============================================================================
  // 
  // When you call: await _box.put('1', leadModel)
  // 1. Hive sees the value is a LeadModel
  // 2. Hive looks up the registered LeadModelAdapter (by typeId)
  // 3. Hive calls adapter.write(writer, leadModel)
  // 4. The adapter converts LeadModel → binary format
  // 5. Hive stores the binary data on disk
  // 
  // When you call: _box.get('1')
  // 1. Hive reads the binary data from disk
  // 2. Hive checks the typeId in the binary data
  // 3. Hive finds the matching LeadModelAdapter
  // 4. Hive calls adapter.read(reader)
  // 5. The adapter converts binary → LeadModel
  // 6. You get back your LeadModel object!
  // 
  // All of this happens automatically - you just use put() and get()!
  // ============================================================================

}
