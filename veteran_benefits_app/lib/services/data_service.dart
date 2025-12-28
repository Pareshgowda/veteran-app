import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/condition_model.dart';
import '../models/state_benefit_model.dart';

class DataService {
  // Cache for loaded data
  List<ConditionModel>? _conditions;
  Map<String, List<StateBenefitModel>>? _stateBenefits;

  // Load conditions from JSON
  Future<List<ConditionModel>> loadConditions() async {
    if (_conditions != null) {
      return _conditions!;
    }

    try {
      final String response =
          await rootBundle.loadString('assets/data/secondary_conditions.json');
      final List<dynamic> data = json.decode(response);

      _conditions = data.map((json) => ConditionModel.fromJson(json)).toList();
      return _conditions!;
    } catch (e) {
      throw 'Failed to load conditions data: $e';
    }
  }

  // Load state benefits from JSON
  Future<Map<String, List<StateBenefitModel>>> loadStateBenefits() async {
    if (_stateBenefits != null) {
      return _stateBenefits!;
    }

    try {
      final String response =
          await rootBundle.loadString('assets/data/state_benefits.json');
      final Map<String, dynamic> data = json.decode(response);

      _stateBenefits = {};
      data.forEach((state, benefits) {
        _stateBenefits![state] = (benefits as List)
            .map((json) => StateBenefitModel.fromJson(json))
            .toList();
      });

      return _stateBenefits!;
    } catch (e) {
      throw 'Failed to load state benefits data: $e';
    }
  }

  // Get condition by ID
  Future<ConditionModel?> getConditionById(String id) async {
    final conditions = await loadConditions();
    try {
      return conditions.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get conditions by IDs
  Future<List<ConditionModel>> getConditionsByIds(List<String> ids) async {
    final conditions = await loadConditions();
    return conditions.where((c) => ids.contains(c.id)).toList();
  }

  // Get benefits for a specific state
  Future<List<StateBenefitModel>> getBenefitsForState(String state) async {
    final allBenefits = await loadStateBenefits();
    return allBenefits[state] ?? [];
  }

  // Get list of all states
  Future<List<String>> getAvailableStates() async {
    final allBenefits = await loadStateBenefits();
    final states = allBenefits.keys.toList();
    states.sort();
    return states;
  }

  // Search conditions
  Future<List<ConditionModel>> searchConditions(String query) async {
    final conditions = await loadConditions();
    if (query.isEmpty) return conditions;

    final lowercaseQuery = query.toLowerCase();
    return conditions
        .where((c) =>
            c.name.toLowerCase().contains(lowercaseQuery) ||
            c.shortDescription.toLowerCase().contains(lowercaseQuery) ||
            c.category.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  // Filter conditions by category
  Future<List<ConditionModel>> filterConditionsByCategory(
      String category) async {
    final conditions = await loadConditions();
    if (category == 'All') return conditions;

    return conditions.where((c) => c.category == category).toList();
  }

  // Get secondary conditions for a condition
  Future<List<ConditionModel>> getSecondaryConditions(String conditionId) async {
    final condition = await getConditionById(conditionId);
    if (condition == null) return [];

    return getConditionsByIds(condition.secondaryConditions);
  }

  // Clear cache (useful for testing or forcing reload)
  void clearCache() {
    _conditions = null;
    _stateBenefits = null;
  }
}
