import '../entities/note_entity.dart';

/// Repository Interface - Defines the contract for data operations
abstract class NoteRepository {
  /// Get all notes
  Future<List<NoteEntity>> getAllNotes();

  /// Get a note by ID
  Future<NoteEntity?> getNoteById(String id);

  /// Create a new note
  Future<NoteEntity> createNote(String title, String content);

  /// Update an existing note
  Future<NoteEntity> updateNote(NoteEntity note);

  /// Delete a note by ID
  Future<bool> deleteNote(String id);

  /// Delete all notes
  Future<void> deleteAllNotes();

  /// Get notes count
  Future<int> getNotesCount();
}
