// screens/add_edit_journal_screen.dart
// Form to add a new journal entry or edit an existing one

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/journal_provider.dart';
import '../models/recipe.dart';
import '../models/journal_entry.dart';
import '../widgets/app_theme.dart';

class AddEditJournalScreen extends StatefulWidget {
  /// Pass [recipe] when creating a new entry from Home screen
  final Recipe? recipe;
  /// Pass [existingEntry] when editing from Journal screen
  final JournalEntry? existingEntry;

  const AddEditJournalScreen({
    super.key,
    this.recipe,
    this.existingEntry,
  }) : assert(recipe != null || existingEntry != null,
            'Must provide either recipe or existingEntry');

  @override
  State<AddEditJournalScreen> createState() => _AddEditJournalScreenState();
}

class _AddEditJournalScreenState extends State<AddEditJournalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();

  MoodTag _selectedMood = MoodTag.happy;
  double _rating = 3.0;
  bool _isSaving = false;

  bool get _isEditing => widget.existingEntry != null;

  // Computed recipe info from either source
  String get _recipeName =>
      widget.recipe?.name ?? widget.existingEntry!.recipeName;
  String get _recipeImage =>
      widget.recipe?.image ?? widget.existingEntry!.recipeImage;
  String get _cuisine =>
      widget.recipe?.cuisine ?? widget.existingEntry!.cuisine;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _noteController.text = widget.existingEntry!.note;
      _selectedMood = widget.existingEntry!.mood;
      _rating = widget.existingEntry!.rating;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<JournalProvider>();
    bool success;

    if (_isEditing) {
      // Update existing entry
      final updated = widget.existingEntry!.copyWith(
        mood: _selectedMood,
        note: _noteController.text.trim(),
        rating: _rating,
      );
      success = await provider.updateEntry(updated);
    } else {
      // Create new entry
      final entry = JournalEntry(
        id: 0,
        recipeName: _recipeName,
        recipeImage: _recipeImage,
        cuisine: _cuisine,
        mood: _selectedMood,
        note: _noteController.text.trim(),
        rating: _rating,
        userId: 1,
        createdAt: DateTime.now(),
      );
      success = await provider.addEntry(entry);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? (_isEditing ? '✅ Entry updated!' : '🎉 Added to journal!')
                : '❌ ${provider.errorMessage}',
          ),
          backgroundColor:
              success ? AppTheme.bgCardLight : AppTheme.moodEnergy,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      if (success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Entry' : 'Add to Journal',
          style: GoogleFonts.playfairDisplay(
            color: AppTheme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe preview card
              _buildRecipePreview(),
              const SizedBox(height: 28),
              // Mood selector
              _sectionLabel('How does this make you feel?'),
              const SizedBox(height: 12),
              _buildMoodSelector(),
              const SizedBox(height: 24),
              // Rating
              _sectionLabel('Your Rating'),
              const SizedBox(height: 12),
              _buildRatingInput(),
              const SizedBox(height: 24),
              // Note
              _sectionLabel('Journal Note'),
              const SizedBox(height: 12),
              _buildNoteInput(),
              const SizedBox(height: 32),
              // Save button
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipePreview() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: _recipeImage,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 90,
                height: 90,
                color: AppTheme.bgCardLight,
              ),
              errorWidget: (_, __, ___) => Container(
                width: 90,
                height: 90,
                color: AppTheme.bgCardLight,
                child: const Icon(Icons.restaurant,
                    color: AppTheme.textSecondary),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _recipeName,
                      style: GoogleFonts.playfairDisplay(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.public,
                            size: 13, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          _cuisine,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: MoodTag.values.map((mood) {
        final isSelected = _selectedMood == mood;
        final color = _moodColor(mood);

        return GestureDetector(
          onTap: () => setState(() => _selectedMood = mood),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? color : color.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(mood.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  mood.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRatingInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          RatingBar.builder(
            initialRating: _rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemSize: 40,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4),
            itemBuilder: (_, __) => const Icon(
              Icons.star_rounded,
              color: AppTheme.moodHappy,
            ),
            unratedColor: AppTheme.bgCardLight,
            onRatingUpdate: (rating) => setState(() => _rating = rating),
          ),
          const SizedBox(height: 8),
          Text(
            _ratingLabel(_rating.round()),
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteInput() {
    return TextFormField(
      controller: _noteController,
      maxLines: 5,
      maxLength: 300,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 15,
        height: 1.6,
      ),
      decoration: const InputDecoration(
        hintText: 'Write how this recipe made you feel, memories it brings, or how it tasted...',
        alignLabelWithHint: true,
        counterStyle: TextStyle(color: AppTheme.textSecondary),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return 'Please add a note';
        }
        return null;
      },
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _save,
        child: _isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(_isEditing ? 'Update Entry' : 'Save to Journal'),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        color: AppTheme.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Not my thing 😕';
      case 2:
        return 'It was okay 😐';
      case 3:
        return 'Pretty good 😊';
      case 4:
        return 'Really loved it! 😍';
      case 5:
        return 'Absolute perfection! 🤩';
      default:
        return '';
    }
  }

  Color _moodColor(MoodTag mood) {
    switch (mood) {
      case MoodTag.happy:
        return AppTheme.moodHappy;
      case MoodTag.sad:
        return AppTheme.moodSad;
      case MoodTag.energy:
        return AppTheme.moodEnergy;
      case MoodTag.comfort:
        return AppTheme.moodComfort;
    }
  }
}
