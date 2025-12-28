import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/app_theme.dart';
import '../../providers/data_provider.dart';
import '../../models/state_benefit_model.dart';

// Provider for selected state
final selectedStateProvider = StateProvider<String?>((ref) => null);

// Provider for search query
final benefitsSearchProvider = StateProvider<String>((ref) => '');

// Provider for selected category filter
final benefitsCategoryProvider = StateProvider<String>((ref) => 'All');

class StateBenefitsScreen extends ConsumerStatefulWidget {
  const StateBenefitsScreen({super.key});

  @override
  ConsumerState<StateBenefitsScreen> createState() =>
      _StateBenefitsScreenState();
}

class _StateBenefitsScreenState extends ConsumerState<StateBenefitsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedState = ref.watch(selectedStateProvider);
    final searchQuery = ref.watch(benefitsSearchProvider);
    final selectedCategory = ref.watch(benefitsCategoryProvider);
    final availableStatesAsync = ref.watch(availableStatesProvider);
    final benefitsAsync = ref.watch(benefitsForStateProvider(selectedState));

    return availableStatesAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppTheme.backgroundBeige,
        appBar: AppBar(title: const Text('State Benefits')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppTheme.backgroundBeige,
        appBar: AppBar(title: const Text('State Benefits')),
        body: Center(child: Text('Error loading states: $error')),
      ),
      data: (availableStates) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundBeige,
          appBar: AppBar(
            title: const Text('State Benefits'),
          ),
          body: Column(
            children: [
              // State Selector
              Container(
                color: AppTheme.cardWhite,
                padding: const EdgeInsets.all(16),
                child: _buildStateSelector(context, ref, selectedState, availableStates),
              ),

              if (selectedState != null) ...[
                benefitsAsync.when(
                  loading: () => const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => Expanded(
                    child: Center(child: Text('Error loading benefits: $error')),
                  ),
                  data: (allBenefits) {
                    // Filter benefits
                    var filteredBenefits = allBenefits.where((benefit) {
                      final matchesSearch = searchQuery.isEmpty ||
                          benefit.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                          benefit.fullDescription.toLowerCase().contains(searchQuery.toLowerCase());
                      final matchesCategory = selectedCategory == 'All' ||
                          benefit.category == selectedCategory;

                      return matchesSearch && matchesCategory;
                    }).toList();

                    return Expanded(
                      child: Column(
                        children: [
            // Search Bar
            Container(
              color: AppTheme.cardWhite,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search benefits (property tax, hunting...)',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(benefitsSearchProvider.notifier).state =
                                '';
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  ref.read(benefitsSearchProvider.notifier).state = value;
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
                  'Tax Benefits',
                  'Education',
                  'Healthcare',
                  'Employment',
                  'Housing',
                  'Recreation',
                ].map((category) {
                  final isSelected = selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        ref.read(benefitsCategoryProvider.notifier).state =
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

            // Benefits List
            Expanded(
              child: filteredBenefits.isEmpty
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
                            'No benefits found',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppTheme.grayText,
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredBenefits.length,
                      itemBuilder: (context, index) {
                        return _buildBenefitCard(
                          context,
                          filteredBenefits[index],
                        );
                      },
                    ),
            ),
                        ],
                      ),
                    );
                  },
                ),
              ] else
                _buildEmptyState(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStateSelector(
    BuildContext context,
    WidgetRef ref,
    String? selectedState,
    List<String> availableStates,
  ) {

    return DropdownButtonFormField<String>(
      value: selectedState,
      decoration: const InputDecoration(
        labelText: 'Select Your State',
        prefixIcon: Icon(Icons.location_on),
      ),
      hint: const Text('Choose a state'),
      items: availableStates.map((state) {
        return DropdownMenuItem(
          value: state,
          child: Text(state),
        );
      }).toList(),
      onChanged: (value) {
        ref.read(selectedStateProvider.notifier).state = value;
        // Reset filters when state changes
        ref.read(benefitsSearchProvider.notifier).state = '';
        ref.read(benefitsCategoryProvider.notifier).state = 'All';
        _searchController.clear();
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 100,
              color: AppTheme.grayText.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Select a state to view benefits',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.grayText,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Discover veteran benefits available in your state',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.grayText,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitCard(BuildContext context, StateBenefitModel benefit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          title: Text(
            benefit.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(
                      benefit.category,
                      style: const TextStyle(fontSize: 11),
                    ),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  if (benefit.residenceRequired)
                    const Chip(
                      label: Text(
                        'Resident Only',
                        style: TextStyle(fontSize: 11, color: Colors.white),
                      ),
                      backgroundColor: AppTheme.buttonBlue,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            ],
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    benefit.fullDescription,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Eligibility:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...(benefit.eligibility.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle,
                              size: 16, color: AppTheme.successGreen),
                          const SizedBox(width: 8),
                          Expanded(child: Text(item)),
                        ],
                      ),
                    );
                  })),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.savings,
                            color: AppTheme.successGreen),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Value:',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                benefit.value,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'How to Apply:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(benefit.howToApply),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
