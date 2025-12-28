import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/condition_model.dart';
import '../../widgets/upgrade_dialog.dart';
import '../condition_detail_screen.dart';

// Provider for search query
final conditionsSearchProvider = StateProvider<String>((ref) => '');

// Provider for selected category filter
final conditionsCategoryProvider = StateProvider<String>((ref) => 'All');

// Provider for show saved only toggle
final showSavedOnlyProvider = StateProvider<bool>((ref) => false);

class ConditionsScreen extends ConsumerStatefulWidget {
  const ConditionsScreen({super.key});

  @override
  ConsumerState<ConditionsScreen> createState() => _ConditionsScreenState();
}

class _ConditionsScreenState extends ConsumerState<ConditionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(conditionsSearchProvider);
    final selectedCategory = ref.watch(conditionsCategoryProvider);
    final showSavedOnly = ref.watch(showSavedOnlyProvider);
    final savedConditions = ref.watch(savedConditionsProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final canSave = ref.watch(canSaveConditionProvider);
    final conditionsAsync = ref.watch(conditionsProvider);

    return conditionsAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppTheme.backgroundBeige,
        appBar: AppBar(title: const Text('Secondary Conditions')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppTheme.backgroundBeige,
        appBar: AppBar(title: const Text('Secondary Conditions')),
        body: Center(child: Text('Error loading conditions: $error')),
      ),
      data: (allConditions) {
        // Filter conditions
        var filteredConditions = allConditions.where((condition) {
          final matchesSearch = searchQuery.isEmpty ||
              condition.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              condition.shortDescription.toLowerCase().contains(searchQuery.toLowerCase());
          final matchesCategory = selectedCategory == 'All' ||
              condition.category == selectedCategory;
          final matchesSaved = !showSavedOnly ||
              savedConditions.contains(condition.id);

          return matchesSearch && matchesCategory && matchesSaved;
        }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundBeige,
      appBar: AppBar(
        title: const Text('Secondary Conditions'),
        actions: [
          IconButton(
            icon: Icon(
              showSavedOnly ? Icons.bookmark : Icons.bookmark_border,
              color: showSavedOnly ? AppTheme.accentGold : null,
            ),
            onPressed: () {
              ref.read(showSavedOnlyProvider.notifier).state = !showSavedOnly;
            },
            tooltip: showSavedOnly ? 'Show All' : 'Show Saved Only',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: AppTheme.cardWhite,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search conditions (PTSD, Diabetes, ...)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(conditionsSearchProvider.notifier).state = '';
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                ref.read(conditionsSearchProvider.notifier).state = value;
              },
            ),
          ),

          // Category Filter Chips
          Container(
            height: 50,
            color: AppTheme.cardWhite,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                'All',
                'Mental Health',
                'Musculoskeletal',
                'Neurological',
                'Cardiovascular',
                'Respiratory',
              ].map((category) {
                final isSelected = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      ref.read(conditionsCategoryProvider.notifier).state =
                          category;
                    },
                    selectedColor: AppTheme.primaryOliveGreen,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(height: 1),

          // Conditions List
          Expanded(
            child: filteredConditions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppTheme.grayText,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          showSavedOnly
                              ? 'No saved conditions yet'
                              : 'No conditions found',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.grayText,
                                  ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredConditions.length,
                    itemBuilder: (context, index) {
                      final condition = filteredConditions[index];
                      final isSaved =
                          savedConditions.contains(condition.id);

                      return _buildConditionCard(
                        context,
                        ref,
                        condition,
                        isSaved,
                        canSave,
                        isPremium,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildConditionCard(
    BuildContext context,
    WidgetRef ref,
    ConditionModel condition,
    bool isSaved,
    bool canSave,
    bool isPremium,
  ) {
    final ratingRange = condition.ratingRange;
    Color ratingColor = AppTheme.ratingOrange;
    if (ratingRange.contains('70') || ratingRange.contains('100')) {
      ratingColor = AppTheme.ratingDarkGreen;
    } else if (ratingRange.contains('40') || ratingRange.contains('60')) {
      ratingColor = AppTheme.ratingLightGreen;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ConditionDetailScreen(conditionId: condition.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          condition.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(
                              label: Text(
                                condition.category,
                                style: const TextStyle(fontSize: 11),
                              ),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            Chip(
                              label: Text(
                                ratingRange,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: ratingColor,
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved
                          ? AppTheme.accentGold
                          : AppTheme.primaryOliveGreen,
                    ),
                    onPressed: () async {
                      if (isSaved) {
                        // Remove condition
                        await ref
                            .read(authControllerProvider)
                            .removeSavedCondition(condition.id);
                      } else {
                        // Check if can save
                        if (!canSave && !isPremium) {
                          // Show upgrade dialog
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Free Tier Limit Reached'),
                                content: const Text(
                                  'Free accounts can save up to 3 conditions. Upgrade to Premium for unlimited saves.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            const UpgradeDialog(),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.accentGold,
                                    ),
                                    child: const Text('Upgrade Now'),
                                  ),
                                ],
                              ),
                            );
                          }
                        } else {
                          // Add condition
                          await ref
                              .read(authControllerProvider)
                              .addSavedCondition(condition.id);
                        }
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                condition.shortDescription,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
