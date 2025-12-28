import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/upgrade_dialog.dart';

// Providers for calculator state
final disabilityRatingProvider = StateProvider<double>((ref) => 0);
final spouseCountProvider = StateProvider<int>((ref) => 0);
final childrenCountProvider = StateProvider<int>((ref) => 0);
final parentsCountProvider = StateProvider<int>((ref) => 0);

class ClaimsScreen extends ConsumerWidget {
  const ClaimsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disabilityRating = ref.watch(disabilityRatingProvider);
    final spouseCount = ref.watch(spouseCountProvider);
    final childrenCount = ref.watch(childrenCountProvider);
    final parentsCount = ref.watch(parentsCountProvider);
    final isPremium = ref.watch(isPremiumProvider);

    final monthlyPayment = _calculateMonthlyPayment(
      disabilityRating.toInt(),
      spouseCount,
      childrenCount,
      parentsCount,
    );

    Color ratingColor = AppTheme.grayText;
    if (disabilityRating >= 70) {
      ratingColor = AppTheme.ratingDarkGreen;
    } else if (disabilityRating >= 40) {
      ratingColor = AppTheme.ratingLightGreen;
    } else if (disabilityRating >= 10) {
      ratingColor = AppTheme.ratingOrange;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundBeige,
      appBar: AppBar(
        title: const Text('Claims & Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // VA Disability Calculator
            _buildCalculatorCard(
              context,
              ref,
              disabilityRating,
              spouseCount,
              childrenCount,
              parentsCount,
              monthlyPayment,
              ratingColor,
              isPremium,
            ),
            const SizedBox(height: 24),

            // Claim Resources
            Text(
              'Claim Resources',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildResourcesList(context),
            const SizedBox(height: 24),

            // Premium Tools
            Text(
              'Premium Tools',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildPremiumTools(context, isPremium),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorCard(
    BuildContext context,
    WidgetRef ref,
    double disabilityRating,
    int spouseCount,
    int childrenCount,
    int parentsCount,
    double monthlyPayment,
    Color ratingColor,
    bool isPremium,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Disability Calculator',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Calculate Your Monthly Payment',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.grayText,
                  ),
            ),
            const SizedBox(height: 24),

            // Disability Rating Slider
            Text(
              'Disability Rating: ${disabilityRating.toInt()}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ratingColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Slider(
              value: disabilityRating,
              min: 0,
              max: 100,
              divisions: 10,
              activeColor: ratingColor,
              onChanged: (value) {
                ref.read(disabilityRatingProvider.notifier).state = value;
              },
            ),
            const SizedBox(height: 16),

            // Spouse Counter
            _buildCounter(
              context,
              ref,
              'Spouse',
              spouseCount,
              spouseCountProvider,
              maxValue: 1,
            ),
            const SizedBox(height: 12),

            // Children Counter
            _buildCounter(
              context,
              ref,
              'Children',
              childrenCount,
              childrenCountProvider,
            ),
            const SizedBox(height: 12),

            // Parents Counter
            _buildCounter(
              context,
              ref,
              'Parents',
              parentsCount,
              parentsCountProvider,
              maxValue: 2,
            ),
            const SizedBox(height: 24),

            // Monthly Payment Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryOliveGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryOliveGreen,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '\$${monthlyPayment.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppTheme.primaryOliveGreen,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'per month',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.grayText,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '2025 COLA rates (approximate)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.grayText,
                    fontStyle: FontStyle.italic,
                  ),
              textAlign: TextAlign.center,
            ),
            if (!isPremium) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const UpgradeDialog(),
                    );
                  },
                  icon: const Icon(Icons.lock_outline),
                  label: const Text('Save Calculation (Premium)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentGold,
                    side: const BorderSide(color: AppTheme.accentGold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCounter(
    BuildContext context,
    WidgetRef ref,
    String label,
    int value,
    StateProvider<int> provider, {
    int maxValue = 10,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          onPressed: value > 0
              ? () => ref.read(provider.notifier).state = value - 1
              : null,
          icon: const Icon(Icons.remove_circle_outline),
          color: AppTheme.primaryOliveGreen,
        ),
        Container(
          width: 40,
          alignment: Alignment.center,
          child: Text(
            value.toString(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        IconButton(
          onPressed: value < maxValue
              ? () => ref.read(provider.notifier).state = value + 1
              : null,
          icon: const Icon(Icons.add_circle_outline),
          color: AppTheme.primaryOliveGreen,
        ),
      ],
    );
  }

  Widget _buildResourcesList(BuildContext context) {
    final resources = [
      {
        'title': 'BDD Timeline Guide',
        'icon': Icons.timeline,
        'description': 'Learn the Benefits Delivery at Discharge timeline',
      },
      {
        'title': 'Claim Process Overview',
        'icon': Icons.info_outline,
        'description': 'Step-by-step guide to filing a VA claim',
      },
      {
        'title': 'Find a VSO',
        'icon': Icons.search,
        'description': 'Locate a Veteran Service Officer near you',
      },
    ];

    return Card(
      child: Column(
        children: resources.map((resource) {
          return ListTile(
            leading: Icon(
              resource['icon'] as IconData,
              color: AppTheme.primaryOliveGreen,
            ),
            title: Text(resource['title'] as String),
            subtitle: Text(resource['description'] as String),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${resource['title']} - Coming soon!'),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPremiumTools(BuildContext context, bool isPremium) {
    final tools = [
      {
        'title': 'BDD Form Builder',
        'icon': Icons.description,
        'description': 'Generate your VA forms step-by-step',
      },
      {
        'title': 'Statement Builder',
        'icon': Icons.article,
        'description': 'Create powerful personal statements',
      },
      {
        'title': 'Evidence Organizer',
        'icon': Icons.checklist,
        'description': 'Track required evidence',
      },
      {
        'title': 'C&P Exam Prep',
        'icon': Icons.medical_information,
        'description': 'Prepare for your exam',
      },
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: tools.map((tool) {
        return Card(
          child: InkWell(
            onTap: () {
              if (!isPremium) {
                showDialog(
                  context: context,
                  builder: (context) => const UpgradeDialog(),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${tool['title']} - Coming soon!'),
                  ),
                );
              }
            },
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tool['icon'] as IconData,
                        size: 40,
                        color: isPremium
                            ? AppTheme.primaryOliveGreen
                            : AppTheme.grayText,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tool['title'] as String,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tool['description'] as String,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!isPremium)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      Icons.lock,
                      color: AppTheme.accentGold,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  double _calculateMonthlyPayment(
    int rating,
    int spouse,
    int children,
    int parents,
  ) {
    // Simplified 2025 VA compensation rates (approximate)
    final baseRates = {
      0: 0.0,
      10: 171.23,
      20: 338.49,
      30: 524.31,
      40: 755.28,
      50: 1075.16,
      60: 1361.88,
      70: 1716.28,
      80: 1995.01,
      90: 2241.91,
      100: 3737.85,
    };

    double base = baseRates[rating] ?? 0.0;

    // Add for dependents (simplified)
    if (rating >= 30) {
      if (spouse > 0) base += 150;
      base += children * 75;
      if (rating >= 30) base += parents * 120;
    }

    return base;
  }
}
