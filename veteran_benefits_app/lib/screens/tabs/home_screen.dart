import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../utils/app_theme.dart';
import '../main_scaffold.dart';
import '../../widgets/upgrade_dialog.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final savedConditions = ref.watch(savedConditionsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundBeige,
      appBar: AppBar(
        title: const Text('Vet Health Connect'),
      ),
      body: userData.when(
        data: (user) {
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                _buildWelcomeCard(context, user.displayName, isPremium),
                const SizedBox(height: 24),

                // Quick Actions Grid
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _buildQuickActionsGrid(context, ref, isPremium),
                const SizedBox(height: 24),

                // Saved Conditions Section
                if (savedConditions.isNotEmpty) ...[
                  _buildSavedConditionsSection(
                    context,
                    ref,
                    savedConditions,
                    isPremium,
                  ),
                  const SizedBox(height: 24),
                ],

                // Tips Section
                _buildTipsSection(context),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, String displayName, bool isPremium) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $displayName!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPremium ? AppTheme.accentGold : AppTheme.grayText,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPremium)
                        const Icon(Icons.star, size: 16, color: Colors.white),
                      if (isPremium) const SizedBox(width: 4),
                      Text(
                        isPremium ? 'PREMIUM' : 'FREE TIER',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isPremium) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const UpgradeDialog(),
                  );
                },
                icon: const Icon(Icons.upgrade, size: 16),
                label: const Text('Upgrade to unlock all features'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, WidgetRef ref, bool isPremium) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildQuickActionCard(
          context,
          'Calculate Disability',
          'Estimate your VA rating',
          Icons.calculate,
          () {
            ref.read(selectedTabProvider.notifier).state = 3; // Claims tab
          },
        ),
        _buildQuickActionCard(
          context,
          'Find State Benefits',
          'Discover local benefits',
          Icons.map,
          () {
            ref.read(selectedTabProvider.notifier).state = 2; // State tab
          },
        ),
        _buildQuickActionCard(
          context,
          'Browse Conditions',
          'Secondary conditions',
          Icons.medical_information,
          () {
            ref.read(selectedTabProvider.notifier).state = 1; // Conditions tab
          },
        ),
        if (!isPremium)
          _buildQuickActionCard(
            context,
            'Upgrade to Premium',
            'Unlock all tools',
            Icons.star,
            () {
              showDialog(
                context: context,
                builder: (context) => const UpgradeDialog(),
              );
            },
            isGold: true,
          ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isGold = false,
  }) {
    return Card(
      elevation: isGold ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isGold
            ? const BorderSide(color: AppTheme.accentGold, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: isGold ? AppTheme.accentGold : AppTheme.primaryOliveGreen,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isGold ? AppTheme.accentGold : null,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavedConditionsSection(
    BuildContext context,
    WidgetRef ref,
    List<String> savedConditions,
    bool isPremium,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isPremium
                  ? 'My Conditions (${savedConditions.length} saved)'
                  : 'My Conditions (${savedConditions.length}/3 saved)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: savedConditions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final conditionId = savedConditions[index];
              final conditionAsync = ref.watch(conditionByIdProvider(conditionId));

              return conditionAsync.when(
                loading: () => const ListTile(
                  leading: Icon(Icons.bookmark, color: AppTheme.primaryOliveGreen),
                  title: Text('Loading...'),
                ),
                error: (error, stack) => ListTile(
                  leading: const Icon(Icons.bookmark, color: AppTheme.primaryOliveGreen),
                  title: Text(conditionId),
                ),
                data: (condition) {
                  return ListTile(
                    leading: const Icon(Icons.bookmark, color: AppTheme.primaryOliveGreen),
                    title: Text(condition?.name ?? conditionId),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
                      onPressed: () async {
                        await ref
                            .read(authControllerProvider)
                            .removeSavedCondition(conditionId);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSection(BuildContext context) {
    final tips = [
      'File your BDD claim 180-90 days before discharge',
      'Secondary conditions can increase your rating',
      'Keep copies of all medical evidence',
      'Get a Nexus letter from your doctor',
      'Document everything - symptoms, treatments, impacts',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Helpful Tips',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Did you know?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.blue.shade900,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  tips[DateTime.now().day % tips.length],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue.shade900,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
