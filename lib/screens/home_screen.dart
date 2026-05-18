// screens/home_screen.dart
// Recipe Explorer - browse, search, favorite, add to journal

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/recipe_provider.dart';
import '../providers/journal_provider.dart';
import '../models/journal_entry.dart';
import '../models/recipe.dart';
import '../widgets/common_widgets.dart';
import '../widgets/app_theme.dart';
import 'add_edit_journal_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    // Fetch recipes on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().fetchRecipes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await context.read<RecipeProvider>().fetchRecipes(refresh: true);
  }

  void _onAddToJournal(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditJournalScreen(recipe: recipe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_showSearch) _buildSearchBar(),
            const SizedBox(height: 8),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recipe Explorer',
                  style: GoogleFonts.playfairDisplay(
                    color: AppTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Discover & journal your food moods',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  context.read<RecipeProvider>().clearSearch();
                }
              });
            },
            icon: Icon(
              _showSearch ? Icons.search_off : Icons.search,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search recipes or cuisines...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    context.read<RecipeProvider>().clearSearch();
                    setState(() {});
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {});
          if (value.length > 2) {
            context.read<RecipeProvider>().searchRecipes(value);
          } else if (value.isEmpty) {
            context.read<RecipeProvider>().clearSearch();
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<RecipeProvider>(
      builder: (context, provider, _) {
        switch (provider.status) {
          case RecipeStatus.loading:
            return _buildShimmerList();
          case RecipeStatus.error:
            return ErrorStateWidget(
              message: provider.errorMessage,
              onRetry: _refresh,
            );
          case RecipeStatus.success:
          case RecipeStatus.idle:
            if (provider.recipes.isEmpty) {
              return EmptyStateWidget(
                emoji: '🍽️',
                title: 'No Recipes Found',
                subtitle: provider.searchQuery.isNotEmpty
                    ? 'Try a different search term'
                    : 'Pull down to refresh',
                actionLabel: provider.searchQuery.isNotEmpty
                    ? 'Clear Search'
                    : null,
                onAction: () {
                  _searchController.clear();
                  provider.clearSearch();
                  setState(() => _showSearch = false);
                },
              );
            }
            return _buildRecipeList(provider);
        }
      },
    );
  }

  Widget _buildRecipeList(RecipeProvider provider) {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppTheme.primary,
      backgroundColor: AppTheme.bgCard,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: provider.recipes.length,
        itemBuilder: (context, index) {
          final recipe = provider.recipes[index];
          return RecipeCard(
            recipe: recipe,
            isFavorite: provider.isFavorite(recipe.id),
            onFavorite: () => provider.toggleFavorite(recipe.id),
            onAddToJournal: () => _onAddToJournal(recipe),
          );
        },
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: 4,
      itemBuilder: (_, __) => const RecipeShimmerCard(),
    );
  }
}
