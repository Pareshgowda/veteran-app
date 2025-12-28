import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/condition_model.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/upgrade_dialog.dart';

class ConditionDetailScreen extends ConsumerWidget {
  final String conditionId;

  const ConditionDetailScreen({
    super.key,
    required this.conditionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conditionAsync = ref.watch(conditionByIdProvider(conditionId));
    final isPremium = ref.watch(isPremiumProvider);
    final savedConditions = ref.watch(savedConditionsProvider);
    final canSave = ref.watch(canSaveConditionProvider);

    return conditionAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: $error')),
      ),
      data: (condition) {
        if (condition == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: const Center(child: Text('Condition not found')),
          );
        }

        final isSaved = savedConditions.contains(conditionId);
        final ratingColor = _getRatingColor(condition.ratingRange);

        return Scaffold(
          backgroundColor: AppTheme.backgroundBeige,
          appBar: AppBar(
            title: Text(condition.name),
            actions: [
              IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? AppTheme.accentGold : Colors.white,
                ),
                onPressed: () async {
                  if (isSaved) {
                    await ref
                        .read(authControllerProvider)
                        .removeSavedCondition(conditionId);
                  } else {
                    if (!canSave && !isPremium) {
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
                                  builder: (context) => const UpgradeDialog(),
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
                    } else {
                      await ref
                          .read(authControllerProvider)
                          .addSavedCondition(conditionId);
                    }
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                _buildHeaderCard(context, condition, ratingColor),
                const SizedBox(height: 16),

                // Description
                _buildDescriptionCard(context, condition),
                const SizedBox(height: 16),

                // Evidence Needed
                _buildEvidenceNeededCard(context, condition),
                const SizedBox(height: 16),

                // Secondary Conditions
                if (condition.secondaryConditions.isNotEmpty) ...[
                  _buildSecondaryConditionsCard(context, ref, condition),
                  const SizedBox(height: 16),
                ],

                // Premium Sections
                _buildPremiumSection(
                  context,
                  'Nexus Letter Template',
                  Icons.article,
                  'Get a sample nexus letter template to provide to your doctor',
                  isPremium,
                  () => _showNexusTemplate(context, condition),
                ),
                const SizedBox(height: 12),

                _buildPremiumSection(
                  context,
                  'DBQ Information',
                  Icons.description,
                  'Disability Benefits Questionnaire guidance and tips',
                  isPremium,
                  () => _showDBQInfo(context, condition),
                ),
                const SizedBox(height: 12),

                _buildPremiumSection(
                  context,
                  'Personal Statement Template',
                  Icons.edit_document,
                  'Template for writing a powerful personal statement',
                  isPremium,
                  () => _showStatementTemplate(context, condition),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    ConditionModel condition,
    Color ratingColor,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              condition.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(
                    condition.category,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: AppTheme.primaryOliveGreen.withOpacity(0.1),
                  labelStyle: const TextStyle(
                    color: AppTheme.primaryOliveGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Chip(
                  label: Text(
                    condition.ratingRange,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  backgroundColor: ratingColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context, ConditionModel condition) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.primaryOliveGreen),
                const SizedBox(width: 8),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              condition.fullDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenceNeededCard(
      BuildContext context, ConditionModel condition) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.checklist, color: AppTheme.primaryOliveGreen),
                const SizedBox(width: 8),
                Text(
                  'Evidence Needed',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...condition.evidenceNeeded.map((evidence) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 20,
                      color: AppTheme.successGreen,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        evidence,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryConditionsCard(
    BuildContext context,
    WidgetRef ref,
    ConditionModel condition,
  ) {
    final secondaryAsync =
        ref.watch(secondaryConditionsProvider(condition.id));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.link, color: AppTheme.primaryOliveGreen),
                const SizedBox(width: 8),
                Text(
                  'Common Secondary Conditions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            secondaryAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error loading: $error'),
              data: (secondaryConditions) {
                if (secondaryConditions.isEmpty) {
                  return const Text('No secondary conditions listed');
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: secondaryConditions.map((secondary) {
                    return ActionChip(
                      label: Text(secondary.name),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ConditionDetailScreen(conditionId: secondary.id),
                          ),
                        );
                      },
                      backgroundColor: AppTheme.backgroundBeige,
                      side: BorderSide(color: AppTheme.primaryOliveGreen),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumSection(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    bool isPremium,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: isPremium
            ? onTap
            : () {
                showDialog(
                  context: context,
                  builder: (context) => const UpgradeDialog(),
                );
              },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPremium
                      ? AppTheme.accentGold.withOpacity(0.1)
                      : AppTheme.grayText.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isPremium ? AppTheme.accentGold : AppTheme.grayText,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        if (!isPremium) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.lock,
                            size: 16,
                            color: AppTheme.accentGold,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.grayText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNexusTemplate(BuildContext context, ConditionModel condition) {
    final template = '''
NEXUS LETTER TEMPLATE - ${condition.name}

Date: [Current Date]

To Whom It May Concern:

I am writing this letter to establish a medical nexus between the veteran's current diagnosis of ${condition.name} and their military service.

PATIENT INFORMATION:
Name: [Veteran Name]
Date of Birth: [DOB]
Service Dates: [Service Period]

DIAGNOSIS:
The veteran has been diagnosed with ${condition.name}. This condition is characterized by ${condition.shortDescription}.

MEDICAL OPINION:
Based on my examination and review of the veteran's medical history and service records, it is my professional medical opinion that the veteran's ${condition.name} is at least as likely as not (50% or greater probability) related to their military service.

RATIONALE:
${condition.fullDescription}

The veteran's military service likely contributed to or caused this condition due to [specific service-related factors such as combat exposure, occupational hazards, training incidents, etc.].

CONCLUSION:
It is my expert medical opinion, to a reasonable degree of medical certainty, that the veteran's ${condition.name} is related to their military service.

Sincerely,

[Physician Name]
[Medical License Number]
[Specialty]
[Contact Information]

---
NOTE: This is a template. Have your doctor customize it with specific details about your case, medical findings, and service connection rationale.
''';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Column(
            children: [
              AppBar(
                title: const Text('Nexus Letter Template'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: template));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Template copied to clipboard!'),
                          backgroundColor: AppTheme.successGreen,
                        ),
                      );
                    },
                    tooltip: 'Copy to clipboard',
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: SelectableText(
                    template,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDBQInfo(BuildContext context, ConditionModel condition) {
    final dbqInfo = '''
DBQ (Disability Benefits Questionnaire) - ${condition.name}

WHAT IS A DBQ?
A DBQ is a standardized medical form that helps document your condition for VA disability claims. It's completed by a medical professional and provides detailed information about your diagnosis, symptoms, and functional limitations.

KEY INFORMATION FOR ${condition.name}:

1. DIAGNOSIS REQUIREMENTS:
   • Must be diagnosed by a qualified medical professional
   • Diagnosis should reference current medical standards (DSM-5 for mental health, ICD-10 codes)
   • Include date of diagnosis

2. SEVERITY ASSESSMENT:
   Rating: ${condition.ratingRange}

   The examiner will assess:
   • Frequency and duration of symptoms
   • Impact on daily activities and work
   • Treatment history and response
   • Functional limitations

3. OCCUPATIONAL AND SOCIAL IMPAIRMENT:
   The DBQ will evaluate how ${condition.name} affects:
   • Ability to work
   • Social relationships
   • Daily living activities
   • Self-care abilities

4. REQUIRED EVIDENCE:
${condition.evidenceNeeded.map((e) => '   • $e').join('\n')}

5. TIPS FOR YOUR DBQ EXAM:
   ✓ Be honest about your worst days, not just good days
   ✓ Bring all medical records and treatment history
   ✓ Describe specific examples of how symptoms impact your life
   ✓ Mention all medications and side effects
   ✓ Discuss any flare-ups or episodes
   ✓ Have family member provide supporting statement

6. COMMON MISTAKES TO AVOID:
   ✗ Minimizing symptoms
   ✗ Not mentioning all symptoms
   ✗ Failing to describe functional impact
   ✗ Not providing complete treatment history

NEXT STEPS:
1. Schedule DBQ exam with qualified provider
2. Gather all medical evidence beforehand
3. Prepare examples of how condition affects daily life
4. Bring buddy statements if applicable
5. Follow up to ensure DBQ is submitted to VA

Remember: The DBQ is a critical piece of evidence. Take it seriously and ensure your provider understands the full extent of your condition.
''';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Column(
            children: [
              AppBar(
                title: const Text('DBQ Information'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: dbqInfo));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Information copied to clipboard!'),
                          backgroundColor: AppTheme.successGreen,
                        ),
                      );
                    },
                    tooltip: 'Copy to clipboard',
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: SelectableText(
                    dbqInfo,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatementTemplate(BuildContext context, ConditionModel condition) {
    final template = '''
PERSONAL STATEMENT FOR VA CLAIM - ${condition.name}

Veteran Name: [Your Name]
Claim Number: [Your Claim Number]
Date: [Current Date]

INTRODUCTION:
I am writing this statement in support of my claim for service connection for ${condition.name}. I am providing this personal account to help the VA understand how my military service caused or aggravated this condition.

MY MILITARY SERVICE:
Branch: [Branch of Service]
Service Dates: [Start Date - End Date]
MOS/Rating: [Your MOS/Rating]
Duty Stations: [List duty stations]

HOW MY CONDITION BEGAN IN SERVICE:
[Describe when and how the condition started during service. Be specific about:
- Timeline of when symptoms first appeared
- What you were doing when it started
- Any incidents or events that triggered it
- How it progressed during service]

CURRENT SYMPTOMS:
I currently experience the following symptoms related to ${condition.name}:

${condition.fullDescription}

On a daily basis, I experience:
• [Describe daily symptoms]
• [Frequency and intensity]
• [When symptoms are worst]

IMPACT ON MY DAILY LIFE:

WORK:
[Describe how the condition affects your ability to work. Include:
- Tasks you can no longer perform
- Accommodations you need
- Days missed due to symptoms
- Career limitations]

FAMILY AND RELATIONSHIPS:
[Describe impact on family life:
- Activities you can no longer do with family
- How relationships are affected
- Support you need from family members]

DAILY ACTIVITIES:
[Describe limitations in:
- Self-care (bathing, dressing, etc.)
- Household chores
- Hobbies and recreation
- Social activities]

MEDICAL TREATMENT:
I have sought treatment for this condition from:
• [List all healthcare providers]
• [Medications tried]
• [Therapies attempted]
• [Results of treatment]

EVIDENCE SUPPORTING MY CLAIM:
I am submitting the following evidence with my claim:
${condition.evidenceNeeded.map((e) => '• $e').join('\n')}

BUDDY STATEMENTS:
[List people who can provide supporting statements about your condition and its effects]

CONCLUSION:
${condition.name} has significantly impacted my life since my military service. This condition is directly related to my time in service and continues to affect my daily functioning. I respectfully request that the VA grant service connection for this condition.

I certify that the statements made in this document are true and correct to the best of my knowledge.

Signature: _______________________
Date: ___________________________

---
INSTRUCTIONS FOR USE:
1. Fill in all bracketed [information] with your specific details
2. Be honest and detailed about your symptoms
3. Use specific examples rather than general statements
4. Have someone review it before submitting
5. Keep a copy for your records
6. Submit with all supporting evidence
''';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Column(
            children: [
              AppBar(
                title: const Text('Personal Statement Template'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: template));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Template copied to clipboard!'),
                          backgroundColor: AppTheme.successGreen,
                        ),
                      );
                    },
                    tooltip: 'Copy to clipboard',
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: SelectableText(
                    template,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRatingColor(String ratingRange) {
    if (ratingRange.contains('70') || ratingRange.contains('100')) {
      return AppTheme.ratingDarkGreen;
    } else if (ratingRange.contains('40') || ratingRange.contains('60')) {
      return AppTheme.ratingLightGreen;
    }
    return AppTheme.ratingOrange;
  }
}
