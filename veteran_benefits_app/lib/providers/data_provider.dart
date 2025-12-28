import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/condition_model.dart';
import '../models/state_benefit_model.dart';
import '../services/data_service.dart';

// Data Service Provider
final dataServiceProvider = Provider<DataService>((ref) {
  return DataService();
});

// Conditions Provider - Loads all conditions from JSON
final conditionsProvider = FutureProvider<List<ConditionModel>>((ref) async {
  final dataService = ref.watch(dataServiceProvider);
  return await dataService.loadConditions();
});

// State Benefits Provider - Loads all state benefits from JSON
final stateBenefitsProvider =
    FutureProvider<Map<String, List<StateBenefitModel>>>((ref) async {
  final dataService = ref.watch(dataServiceProvider);
  return await dataService.loadStateBenefits();
});

// Available States Provider
final availableStatesProvider = FutureProvider<List<String>>((ref) async {
  final dataService = ref.watch(dataServiceProvider);
  return await dataService.getAvailableStates();
});

// Benefits for Selected State Provider
final benefitsForStateProvider = FutureProvider.family<List<StateBenefitModel>, String?>(
  (ref, state) async {
    if (state == null) return [];
    final dataService = ref.watch(dataServiceProvider);
    return await dataService.getBenefitsForState(state);
  },
);

// Single Condition Provider
final conditionByIdProvider = FutureProvider.family<ConditionModel?, String>(
  (ref, id) async {
    final dataService = ref.watch(dataServiceProvider);
    return await dataService.getConditionById(id);
  },
);

// Conditions by IDs Provider (for saved conditions)
final conditionsByIdsProvider = FutureProvider.family<List<ConditionModel>, List<String>>(
  (ref, ids) async {
    final dataService = ref.watch(dataServiceProvider);
    return await dataService.getConditionsByIds(ids);
  },
);

// Secondary Conditions Provider
final secondaryConditionsProvider = FutureProvider.family<List<ConditionModel>, String>(
  (ref, conditionId) async {
    final dataService = ref.watch(dataServiceProvider);
    return await dataService.getSecondaryConditions(conditionId);
  },
);
