// screens/journal_screen.dart
// Mood Journal - view, filter, edit, delete journal entries

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/journal_provider.dart';
import '../models/journal_entry.dart';
import '../widgets/common_widgets.dart';
import '../widgets/app_theme.dart';
import 'add_edit_journal_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JournalProvider>().fetchEntries();
    });
  }

  Future<void> _refresh() async {
    await context.read<JournalProvider>().fetchEntries();
  }

  void _onEdit(JournalEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditJournalScreen(existingEntry: entry),
      ),
    );
  }

  void _onDelete(JournalEntry entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Entry?',
          style: GoogleFonts.playfairDisplay(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Remove "${entry.recipeName}" from your journal?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success =
                  await context.read<JournalProvider>().deleteEntry(entry.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? '🗑️ Entry deleted' : 'Failed to delete',
                    ),
                    backgroundColor:
                        success ? AppTheme.bgCardLight : AppTheme.moodEnergy,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.moodEnergy,
            ),
            child: const Text('Delete'),
          ),
        ],
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
            const SizedBox(height: 12),
            _buildMoodStats(),
            const SizedBox(height: 12),
            _buildMoodFilter(),
            const SizedBox(height: 8),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mood Journal',
                  style: GoogleFonts.playfairDisplay(
                    color: AppTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your recipe memories & feelings',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodStats() {
    return Consumer<JournalProvider>(
      builder: (context, provider, _) {
        if (provider.allEntries.isEmpty) return const SizedBox.shrink();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: MoodTag.values.map((mood) {
              final count = provider.countByMood(mood);
              if (count == 0) return const SizedBox.shrink();
              return _statChip(mood, count);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _statChip(MoodTag mood, int count) {
    final color = _moodColor(mood);
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(mood.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodFilter() {
    return Consumer<JournalProvider>(
      builder: (context, provider, _) {
        return MoodFilterBar(
          activeFilter: provider.activeMoodFilter,
          onFilter: (mood) => provider.filterByMood(mood),
        );
      },
    );
  }

  Widget _buildBody() {
    return Consumer<JournalProvider>(
      builder: (context, provider, _) {
        switch (provider.status) {
          case JournalStatus.loading:
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          case JournalStatus.error:
            return ErrorStateWidget(
              message: provider.errorMessage,
              onRetry: _refresh,
            );
          case JournalStatus.success:
          case JournalStatus.idle:
            if (provider.entries.isEmpty) {
              return EmptyStateWidget(
                emoji: provider.activeMoodFilter != null ? '🔍' : '📔',
                title: provider.activeMoodFilter != null
                    ? 'No ${provider.activeMoodFilter!.label} Entries'
                    : 'Journal is Empty',
                subtitle: provider.activeMoodFilter != null
                    ? 'Try a different mood filter'
                    : 'Start exploring recipes and add them to your mood journal!',
                actionLabel: provider.activeMoodFilter != null
                    ? 'Clear Filter'
                    : null,
                onAction: () => provider.filterByMood(null),
              );
            }
            return _buildEntryList(provider);
        }
      },
    );
  }

  Widget _buildEntryList(JournalProvider provider) {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppTheme.primary,
      backgroundColor: AppTheme.bgCard,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: provider.entries.length,
        itemBuilder: (context, index) {
          final entry = provider.entries[index];
          return JournalCard(
            entry: entry,
            onEdit: () => _onEdit(entry),
            onDelete: () => _onDelete(entry),
          );
        },
      ),
    );
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
