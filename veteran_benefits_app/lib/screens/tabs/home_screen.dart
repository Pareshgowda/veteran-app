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
                Row(
                  children: [
                    Icon(Icons.rocket_launch_rounded,
                         color: AppTheme.primaryOliveGreen, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryOliveGreen,
            AppTheme.primaryOliveGreen.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryOliveGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.waving_hand_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Welcome back,',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                displayName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isPremium
                          ? AppTheme.accentGold
                          : Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isPremium)
                          const Icon(Icons.workspace_premium_rounded,
                                     size: 18, color: Colors.white),
                        if (isPremium) const SizedBox(width: 6),
                        Text(
                          isPremium ? 'PREMIUM MEMBER' : 'FREE TIER',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!isPremium) ...[
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const UpgradeDialog(),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentGold.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.upgrade_rounded,
                                   size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Upgrade to unlock all features',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, WidgetRef ref, bool isPremium) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildQuickActionCard(
          context,
          'Calculate\nDisability',
          'Estimate your rating',
          Icons.calculate_rounded,
          () {
            ref.read(selectedTabProvider.notifier).state = 3; // Claims tab
          },
        ),
        _buildQuickActionCard(
          context,
          'State\nBenefits',
          'Find local benefits',
          Icons.location_city_rounded,
          () {
            ref.read(selectedTabProvider.notifier).state = 2; // State tab
          },
        ),
        _buildQuickActionCard(
          context,
          'Browse\nConditions',
          'Secondary conditions',
          Icons.medical_information_rounded,
          () {
            ref.read(selectedTabProvider.notifier).state = 1; // Conditions tab
          },
        ),
        if (!isPremium)
          _buildQuickActionCard(
            context,
            'Go\nPremium',
            'Unlock all features',
            Icons.workspace_premium_rounded,
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isGold
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.accentGold.withOpacity(0.1),
                  AppTheme.accentGold.withOpacity(0.05),
                ],
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isGold
                ? AppTheme.accentGold.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isGold
              ? BorderSide(color: AppTheme.accentGold.withOpacity(0.3), width: 1.5)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isGold
                        ? AppTheme.accentGold.withOpacity(0.15)
                        : AppTheme.primaryOliveGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: isGold ? AppTheme.accentGold : AppTheme.primaryOliveGreen,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isGold ? AppTheme.accentGold : Colors.black87,
                        height: 1.2,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          height: 1.2,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
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
          children: [
            Icon(Icons.bookmark_rounded,
                 color: AppTheme.accentGold, size: 24),
            const SizedBox(width: 8),
            Text(
              isPremium
                  ? 'My Conditions (${savedConditions.length} saved)'
                  : 'My Conditions (${savedConditions.length}/3 saved)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: savedConditions.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: Colors.grey.shade200,
              ),
              itemBuilder: (context, index) {
                final conditionId = savedConditions[index];
                final conditionAsync = ref.watch(conditionByIdProvider(conditionId));

                return conditionAsync.when(
                  loading: () => const ListTile(
                    leading: Icon(Icons.bookmark_rounded,
                                  color: AppTheme.accentGold),
                    title: Text('Loading...'),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  error: (error, stack) => ListTile(
                    leading: const Icon(Icons.bookmark_rounded,
                                        color: AppTheme.accentGold),
                    title: Text(conditionId),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  data: (condition) {
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.bookmark_rounded,
                                         color: AppTheme.accentGold, size: 20),
                      ),
                      title: Text(
                        condition?.name ?? conditionId,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                                         color: AppTheme.errorRed),
                        onPressed: () async {
                          await ref
                              .read(authControllerProvider)
                              .removeSavedCondition(conditionId);
                        },
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    );
                  },
                );
              },
            ),
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
        Row(
          children: [
            Icon(Icons.tips_and_updates_rounded,
                 color: AppTheme.primaryOliveGreen, size: 24),
            const SizedBox(width: 8),
            Text(
              'Helpful Tips',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade50,
                Colors.blue.shade100.withOpacity(0.5),
              ],
            ),
            border: Border.all(
              color: Colors.blue.shade200,
              width: 1,
            ),
          ),
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.lightbulb_rounded,
                                         color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Did you know?',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tips[DateTime.now().day % tips.length],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue.shade900,
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
