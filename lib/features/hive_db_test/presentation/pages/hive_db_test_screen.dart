import 'package:flutter/material.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import '../../data/datasources/note_local_datasource.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/note_repository.dart';

class HiveDbTestScreen extends StatefulWidget {
  const HiveDbTestScreen({Key? key}) : super(key: key);

  @override
  State<HiveDbTestScreen> createState() => _HiveDbTestScreenState();
}

class _HiveDbTestScreenState extends State<HiveDbTestScreen> {
  late NoteLocalDataSource _dataSource;
  late NoteRepository _repository;

  List<NoteEntity> _notes = [];
  bool _isLoading = true;
  String _statusMessage = '';

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Initializing Hive...';
    });

    try {
      _dataSource = NoteLocalDataSource();
      await _dataSource.init();
      _repository = NoteRepositoryImpl(_dataSource);

      await _loadNotes();

      setState(() {
        _statusMessage = 'Hive initialized successfully!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNotes() async {
    final notes = await _repository.getAllNotes();
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _addNote() async {
    if (_titleController.text.isEmpty) {
      _showSnackBar('Please enter a title');
      return;
    }

    setState(() => _statusMessage = 'Adding note...');

    try {
      await _repository.createNote(
        _titleController.text,
        _contentController.text,
      );

      _titleController.clear();
      _contentController.clear();

      await _loadNotes();
      _showSnackBar('Note added successfully!');
      setState(() => _statusMessage = 'Note added! Total: ${_notes.length}');
    } catch (e) {
      _showSnackBar('Error adding note: $e');
    }
  }

  Future<void> _deleteNote(String id) async {
    setState(() => _statusMessage = 'Deleting note...');

    try {
      await _repository.deleteNote(id);
      await _loadNotes();
      _showSnackBar('Note deleted!');
      setState(() => _statusMessage = 'Note deleted! Total: ${_notes.length}');
    } catch (e) {
      _showSnackBar('Error deleting note: $e');
    }
  }

  Future<void> _deleteAllNotes() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete All Notes'),
        content: const Text('Are you sure you want to delete all notes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _statusMessage = 'Deleting all notes...');

      try {
        await _repository.deleteAllNotes();
        await _loadNotes();
        _showSnackBar('All notes deleted!');
        setState(() => _statusMessage = 'All notes cleared!');
      } catch (e) {
        _showSnackBar('Error: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showEditDialog(NoteEntity note) {
    final editTitleController = TextEditingController(text: note.title);
    final editContentController = TextEditingController(text: note.content);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editTitleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: editContentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedNote = note.copyWith(
                title: editTitleController.text,
                content: editContentController.text,
              );
              await _repository.updateNote(updatedNote);
              await _loadNotes();
              Navigator.pop(ctx);
              _showSnackBar('Note updated!');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hive DB Test'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _notes.isNotEmpty ? _deleteAllNotes : null,
            tooltip: 'Delete All',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotes,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Status Bar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: AppColors.primaryLight,
                  child: Row(
                    children: [
                      Icon(
                        Icons.storage_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _statusMessage,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_notes.length} notes',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Add Note Form
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Add New Note',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          hintText: 'Enter note title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.title),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          labelText: 'Content',
                          hintText: 'Enter note content',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.note),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _addNote,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Add Note',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Notes List Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.list_alt_rounded,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Saved Notes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Notes List
                Expanded(
                  child: _notes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.note_add_outlined,
                                size: 64,
                                color: AppColors.textHint,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No notes yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Add your first note above!',
                                style: TextStyle(color: AppColors.textHint),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _notes.length,
                          itemBuilder: (context, index) {
                            final note = _notes[index];
                            return _buildNoteCard(note);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildNoteCard(NoteEntity note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          note.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.content.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                note.content,
                style: const TextStyle(color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(
                  _formatDate(note.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
                if (note.updatedAt != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.edit, size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(
                    'Edited ${_formatDate(note.updatedAt!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_rounded, color: AppColors.primary),
              onPressed: () => _showEditDialog(note),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: Colors.red),
              onPressed: () => _deleteNote(note.id),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
