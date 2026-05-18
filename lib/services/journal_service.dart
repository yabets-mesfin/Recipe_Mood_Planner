// services/journal_service.dart
// Handles all CRUD operations via DummyJSON /posts endpoint

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/journal_entry.dart';

class JournalService {
  static const String _baseUrl = 'https://dummyjson.com';

  /// Fetch journal entries (posts) for userId 1
  Future<List<JournalEntry>> fetchJournalEntries() async {
    try {
      final uri = Uri.parse('$_baseUrl/posts?limit=50&skip=0');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final posts = (data['posts'] as List)
            .map((json) =>
                JournalEntry.fromPostJson(json as Map<String, dynamic>))
            .toList();
        // Only show entries that have our custom format (image URL in body)
        return posts
            .where((e) =>
                e.recipeImage.isNotEmpty &&
                e.recipeImage.startsWith('https'))
            .toList();
      } else {
        throw Exception('Failed to load journal (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Create a new journal entry (POST)
  Future<JournalEntry> createEntry(JournalEntry entry) async {
    try {
      final uri = Uri.parse('$_baseUrl/posts/add');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(entry.toPostJson()),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return JournalEntry.fromPostJson(data);
      } else {
        throw Exception('Failed to create entry (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Update an existing journal entry (PUT)
  Future<JournalEntry> updateEntry(JournalEntry entry) async {
    try {
      final uri = Uri.parse('$_baseUrl/posts/${entry.id}');
      final response = await http
          .put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(entry.toPostJson()),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return JournalEntry.fromPostJson(data);
      } else {
        throw Exception('Failed to update entry (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Delete a journal entry (DELETE)
  Future<bool> deleteEntry(int id) async {
    try {
      final uri = Uri.parse('$_baseUrl/posts/$id');
      final response = await http.delete(uri).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete entry (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
