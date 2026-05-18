// providers/journal_provider.dart
// Manages journal entries with full CRUD, mood filter, loading, error states

import 'package:flutter/foundation.dart';
import '../models/journal_entry.dart';
import '../services/journal_service.dart';

enum JournalStatus { idle, loading, success, error }

class JournalProvider extends ChangeNotifier {
  final JournalService _service = JournalService();

  List<JournalEntry> _entries = [];
  List<JournalEntry> _filteredEntries = [];
  JournalStatus _status = JournalStatus.idle;
  String _errorMessage = '';
  MoodTag? _activeMoodFilter;

  // Getters
  List<JournalEntry> get entries => _filteredEntries;
  List<JournalEntry> get allEntries => _entries;
  JournalStatus get status => _status;
  String get errorMessage => _errorMessage;
  MoodTag? get activeMoodFilter => _activeMoodFilter;
  bool get hasEntries => _entries.isNotEmpty;

  /// Fetch all journal entries
  Future<void> fetchEntries() async {
    if (_status == JournalStatus.loading) return;

    _status = JournalStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final entries = await _service.fetchJournalEntries();
      _entries = entries;
      _applyFilter();
      _status = JournalStatus.success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _status = JournalStatus.error;
    }

    notifyListeners();
  }

  /// Add new entry
  Future<bool> addEntry(JournalEntry entry) async {
    try {
      final newEntry = await _service.createEntry(entry);
      // DummyJSON returns the created post; we keep a local copy since
      // it won't actually persist server-side (demo API)
      final localEntry = entry.copyWith();
      // Use the returned ID from API when available
      final entryWithId = JournalEntry(
        id: newEntry.id > 0 ? newEntry.id : DateTime.now().millisecondsSinceEpoch,
        recipeName: entry.recipeName,
        recipeImage: entry.recipeImage,
        cuisine: entry.cuisine,
        mood: entry.mood,
        note: entry.note,
        rating: entry.rating,
        userId: entry.userId,
        createdAt: entry.createdAt,
      );
      _entries.insert(0, entryWithId);
      _applyFilter();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Update existing entry
  Future<bool> updateEntry(JournalEntry updatedEntry) async {
    try {
      await _service.updateEntry(updatedEntry);
      final index = _entries.indexWhere((e) => e.id == updatedEntry.id);
      if (index != -1) {
        _entries[index] = updatedEntry;
        _applyFilter();
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Delete an entry
  Future<bool> deleteEntry(int id) async {
    try {
      await _service.deleteEntry(id);
      _entries.removeWhere((e) => e.id == id);
      _applyFilter();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Filter entries by mood
  void filterByMood(MoodTag? mood) {
    _activeMoodFilter = mood;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_activeMoodFilter == null) {
      _filteredEntries = List.from(_entries);
    } else {
      _filteredEntries =
          _entries.where((e) => e.mood == _activeMoodFilter).toList();
    }
  }

  /// Get count by mood
  int countByMood(MoodTag mood) =>
      _entries.where((e) => e.mood == mood).length;
}
