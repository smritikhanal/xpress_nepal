import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_model.dart';

/// Local Data Source - Handles direct Hive operations
class NoteLocalDataSource {
  static const String _boxName = 'notes_test_box';
  Box<NoteModel>? _box;

  /// Initialize the data source and open the Hive box
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(NoteModelAdapter());
    }
    _box = await Hive.openBox<NoteModel>(_boxName);
  }

  /// Get the box instance
  Box<NoteModel> get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception(
        'NoteLocalDataSource not initialized. Call init() first.',
      );
    }
    return _box!;
  }

  /// Get all notes from Hive
  List<NoteModel> getAllNotes() {
    return box.values.toList();
  }

  /// Get a note by ID
  NoteModel? getNoteById(String id) {
    return box.get(id);
  }

  /// Save a note to Hive
  Future<void> saveNote(NoteModel note) async {
    await box.put(note.id, note);
  }

  /// Delete a note from Hive
  Future<void> deleteNote(String id) async {
    await box.delete(id);
  }

  /// Delete all notes
  Future<void> deleteAllNotes() async {
    await box.clear();
  }

  /// Get notes count
  int getNotesCount() {
    return box.length;
  }

  /// Close the box
  Future<void> close() async {
    await _box?.close();
  }
}
