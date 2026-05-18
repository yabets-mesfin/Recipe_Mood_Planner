// services/recipe_service.dart
// Handles all HTTP calls to DummyJSON /recipes endpoint

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class RecipeService {
  static const String _baseUrl = 'https://dummyjson.com';
  static const int _limit = 30;

  /// Fetch a paginated list of recipes
  Future<List<Recipe>> fetchRecipes({int skip = 0}) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/recipes?limit=$_limit&skip=$skip',
      );
      final response = await http.get(uri).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final recipes = (data['recipes'] as List)
            .map((json) => Recipe.fromJson(json as Map<String, dynamic>))
            .toList();
        return recipes;
      } else {
        throw Exception('Failed to load recipes (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Search recipes by query
  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/recipes/search?q=${Uri.encodeComponent(query)}',
      );
      final response = await http.get(uri).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final recipes = (data['recipes'] as List)
            .map((json) => Recipe.fromJson(json as Map<String, dynamic>))
            .toList();
        return recipes;
      } else {
        throw Exception('Search failed (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
