import 'package:flutter/material.dart';
import '../data/models/note_item.dart';
import '../data/repositories/user_data_repository.dart';

class NotesProvider extends ChangeNotifier {
  final UserDataRepository _repository = UserDataRepository();
  List<NoteItem> _notes = [];
  bool _isLoading = false;

  List<NoteItem> get notes => _notes;
  int get count => _notes.length;
  bool get isLoading => _isLoading;

  NotesProvider() {
    loadNotes();
  }

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();
    _notes = await _repository.getNotes();
    _isLoading = false;
    notifyListeners();
  }

  String? getNoteText(String bookCode, int chapter, int verse) {
    try {
      final n = _notes.firstWhere(
        (n) => n.bookCode == bookCode && n.chapter == chapter && n.verse == verse,
      );
      return n.noteText;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveNote({
    required String bookCode,
    String? bookName,
    required int chapter,
    required int verse,
    String? verseText,
    required String noteText,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final item = NoteItem(
      bookCode: bookCode,
      bookName: bookName,
      chapter: chapter,
      verse: verse,
      verseText: verseText,
      noteText: noteText,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.saveNote(item);
    _notes.removeWhere(
      (n) => n.bookCode == bookCode && n.chapter == chapter && n.verse == verse,
    );
    _notes.insert(0, item);
    notifyListeners();
  }

  Future<void> deleteNote(String bookCode, int chapter, int verse) async {
    await _repository.deleteNote(bookCode, chapter, verse);
    _notes.removeWhere(
      (n) => n.bookCode == bookCode && n.chapter == chapter && n.verse == verse,
    );
    notifyListeners();
  }
}
