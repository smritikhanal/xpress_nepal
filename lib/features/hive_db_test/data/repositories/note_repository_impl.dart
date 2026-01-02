import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/note_local_datasource.dart';
import '../models/note_model.dart';

/// Repository Implementation - Implements the domain repository interface
class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDataSource _localDataSource;

  NoteRepositoryImpl(this._localDataSource);

  @override
  Future<List<NoteEntity>> getAllNotes() async {
    final models = _localDataSource.getAllNotes();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<NoteEntity?> getNoteById(String id) async {
    final model = _localDataSource.getNoteById(id);
    return model?.toEntity();
  }

  @override
  Future<NoteEntity> createNote(String title, String content) async {
    final now = DateTime.now();
    final id = '${now.millisecondsSinceEpoch}';

    final note = NoteModel(
      id: id,
      title: title,
      content: content,
      createdAt: now,
    );

    await _localDataSource.saveNote(note);
    return note.toEntity();
  }

  @override
  Future<NoteEntity> updateNote(NoteEntity note) async {
    final updatedModel = NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      updatedAt: DateTime.now(),
    );

    await _localDataSource.saveNote(updatedModel);
    return updatedModel.toEntity();
  }

  @override
  Future<bool> deleteNote(String id) async {
    try {
      await _localDataSource.deleteNote(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> deleteAllNotes() async {
    await _localDataSource.deleteAllNotes();
  }

  @override
  Future<int> getNotesCount() async {
    return _localDataSource.getNotesCount();
  }
}
