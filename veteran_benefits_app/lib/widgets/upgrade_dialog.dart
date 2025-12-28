import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class UpgradeDialog extends StatelessWidget {
  const UpgradeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Premium Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star,
                size: 40,
                color: AppTheme.accentGold,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Unlock Premium Features',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.accentGold,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Features List
            _buildFeature(context, 'BDD Form Builder'),
            _buildFeature(context, 'Statement Builder'),
            _buildFeature(context, 'Evidence Organizer'),
            _buildFeature(context, 'C&P Exam Prep'),
            _buildFeature(context, 'Unlimited saved conditions'),
            _buildFeature(context, 'Advanced calculator features'),
            _buildFeature(context, 'No ads'),
            _buildFeature(context, 'Offline access'),
            const SizedBox(height: 24),

            // Pricing
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '\$4.99/month',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.accentGold,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const Text('or'),
                  const SizedBox(height: 4),
                  Text(
                    '\$19.99 one-time',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.accentGold,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Upgrade Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Payment integration coming soon! For testing, your tier will remain "free"',
                      ),
                      backgroundColor: AppTheme.primaryOliveGreen,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGold,
                ),
                child: const Text('Upgrade Now'),
              ),
            ),
            const SizedBox(height: 12),

            // Maybe Later Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Maybe Later'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(BuildContext context, String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: AppTheme.successGreen,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
