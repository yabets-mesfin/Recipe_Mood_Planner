// providers/recipe_provider.dart
// Manages recipe state: loading, error, search, favorites

import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';

enum RecipeStatus { idle, loading, success, error }

class RecipeProvider extends ChangeNotifier {
  final RecipeService _service = RecipeService();

  List<Recipe> _allRecipes = [];
  List<Recipe> _filteredRecipes = [];
  Set<int> _favoriteIds = {};
  RecipeStatus _status = RecipeStatus.idle;
  String _errorMessage = '';
  String _searchQuery = '';
  bool _isSearching = false;

  // Getters
  List<Recipe> get recipes => _filteredRecipes;
  RecipeStatus get status => _status;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;
  Set<int> get favoriteIds => _favoriteIds;

  bool isFavorite(int id) => _favoriteIds.contains(id);

  /// Fetch recipes from API
  Future<void> fetchRecipes({bool refresh = false}) async {
    if (_status == RecipeStatus.loading) return;

    _status = RecipeStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final recipes = await _service.fetchRecipes();
      _allRecipes = recipes;
      _applyFilter();
      _status = RecipeStatus.success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _status = RecipeStatus.error;
    }

    notifyListeners();
  }

  /// Search recipes by name
  Future<void> searchRecipes(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      _isSearching = false;
      _filteredRecipes = List.from(_allRecipes);
      notifyListeners();
      return;
    }

    _isSearching = true;
    _status = RecipeStatus.loading;
    notifyListeners();

    try {
      final results = await _service.searchRecipes(query);
      _filteredRecipes = results;
      _status = RecipeStatus.success;
    } catch (e) {
      // Fallback to local filter
      _filteredRecipes = _allRecipes
          .where((r) =>
              r.name.toLowerCase().contains(query.toLowerCase()) ||
              r.cuisine.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _status = RecipeStatus.success;
    }

    notifyListeners();
  }

  /// Clear search and show all recipes
  void clearSearch() {
    _searchQuery = '';
    _isSearching = false;
    _filteredRecipes = List.from(_allRecipes);
    notifyListeners();
  }

  /// Toggle favorite status
  void toggleFavorite(int id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredRecipes = List.from(_allRecipes);
    } else {
      _filteredRecipes = _allRecipes
          .where((r) =>
              r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              r.cuisine.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }
}
