---
name: migration-helper
description: Scaffold a complete feature layer (model, repository, controller) for PetSphere
user-invocable: true
disable-model-invocation: false
---

# Migration Helper for PetSphere

Scaffold a complete feature layer across model, repository, and controller in one go, following PetSphere's layered architecture.

## Usage

```
/migration-helper FeatureName "Feature description" --table-name=table_name
```

## Examples

```
/migration-helper PetNutrition "Track pet nutrition and dietary info" --table-name=pet_nutrition
/migration-helper ActivityLog "Log pet daily activities" --table-name=activity_logs
/migration-helper CareReminder "Schedule care reminders for pets" --table-name=care_reminders
```

## Parameters

- **FeatureName** (required): PascalCase feature name (e.g., `PetNutrition`, `ActivityLog`)
- **Description** (required): One-line description
- `--table-name`: Supabase table name (snake_case, defaults to feature name in snake_case)
- `--with-images`: Include image upload/storage helpers
- `--with-timestamps`: Include created_at/updated_at timestamps
- `--with-users`: Include user_id relationship

## Generated Files

Creates three files in your project:

### 1. Model (`lib/models/{feature_name}_model.dart`)
```dart
class PetNutritionModel {
  final String id;
  final String userId;
  final String petId;
  final String foodName;
  final int caloriesPerServing;
  final DateTime? createdAt;

  PetNutritionModel({
    required this.id,
    required this.userId,
    required this.petId,
    required this.foodName,
    required this.caloriesPerServing,
    this.createdAt,
  });

  PetNutritionModel copyWith({...}) => ...;

  factory PetNutritionModel.fromJson(Map<String, dynamic> json) => ...;

  Map<String, dynamic> toJson() => ...;
}
```

### 2. Repository (`lib/repositories/{feature_name}_repository.dart`)
```dart
class PetNutritionRepository {
  Future<List<PetNutritionModel>> fetchPetNutrition(String petId) async { ... }
  
  Future<PetNutritionModel> createNutritionRecord(PetNutritionModel model) async { ... }
  
  Future<void> deleteNutritionRecord(String id) async { ... }
}
```

### 3. Controller (`lib/controllers/{feature_name}_controller.dart`)
```dart
class PetNutritionState {
  final List<PetNutritionModel> records;
  final bool isLoading;
  final String? error;

  PetNutritionState({
    this.records = const [],
    this.isLoading = false,
    this.error,
  });

  PetNutritionState copyWith({...}) => ...;
}

class PetNutritionNotifier extends Notifier<PetNutritionState> {
  @override
  PetNutritionState build() { ... }

  Future<void> loadRecords(String petId) async { ... }
  
  Future<void> addRecord(PetNutritionModel model) async { ... }
}

final petNutritionProvider = NotifierProvider<PetNutritionNotifier, PetNutritionState>(...);
```

## Included Patterns

✅ **Immutable models** with `copyWith()`, `fromJson()`, `toJson()`  
✅ **Repository CRUD methods** with error handling  
✅ **Riverpod Notifier** with state management and loading/error states  
✅ **Null safety** throughout  
✅ **Type safety** (no dynamic types)  
✅ **Timestamps** (optional via flag)  
✅ **Image upload helpers** (optional via flag)  
✅ **TODO comments** for integration points  

## Next Steps After Generation

1. **Add to routing** (if you need a new screen)
   - Create `lib/views/{feature_name}_screen.dart`
   - Add route to `lib/utils/routes.dart`

2. **Write tests**
   - Create `test/controllers/{feature_name}_controller_test.dart`
   - Create `test/repositories/{feature_name}_repository_test.dart`

3. **Create Supabase table**
   - Schema must match the model fields
   - Add RLS policies for data access

4. **Link from other features**
   - Import the provider in other controllers
   - Call `ref.read(featureProvider.notifier).loadData()` as needed

## Tips

- Use this for every new database table/feature
- Generated code is production-ready; only update with your custom logic
- Tests are easier to write after running this (mock structure is scaffolded)
- Always commit the generated files together: model + repo + controller
