import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/app_theme.dart';
import 'tabs/home_screen.dart';
import 'tabs/conditions_screen.dart';
import 'tabs/state_benefits_screen.dart';
import 'tabs/claims_screen.dart';
import 'tabs/profile_screen.dart';

// Provider to manage selected tab index
final selectedTabProvider = StateProvider<int>((ref) => 0);

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedTabProvider);

    final List<Widget> screens = [
      const HomeScreen(),
      const ConditionsScreen(),
      const StateBenefitsScreen(),
      const ClaimsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          ref.read(selectedTabProvider.notifier).state = index;
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Conditions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'State',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Claims',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
