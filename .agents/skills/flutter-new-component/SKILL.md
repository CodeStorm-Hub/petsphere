---
name: flutter-new-component
description: Scaffold a new reusable Flutter component following PetSphere patterns
user-invocable: true
disable-model-invocation: false
---

# Flutter New Component Generator

Generate a new reusable Flutter widget component following PetSphere's established patterns.

## Usage

```
/flutter-new-component ComponentName "Component description" [--stateful] [--consumer]
```

## Examples

```
/flutter-new-component PetCard "Displays a pet profile card"
/flutter-new-component HealthMetricGraph "Shows health trend chart" --stateful
/flutter-new-component CareBadgeList "Lists earned care badges" --consumer
```

## Parameters

- **ComponentName** (required): PascalCase name for the widget (e.g., `PetCard`, `HealthMetricGraph`)
- **Description** (required): One-line description of what the component does
- `--stateful`: Create a `StatefulWidget` instead of `StatelessWidget`
- `--consumer`: Create a `ConsumerWidget` that can watch Riverpod state

## Generated Pattern

All components follow the PetSphere convention of private `_WidgetName` classes:

### StatelessWidget (default)
```dart
class _PetCard extends StatelessWidget {
  const _PetCard({
    super.key,
    required this.pet,
    this.onTap,
  });

  final PetModel pet;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pet.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              // TODO: Add widget content
            ],
          ),
        ),
      ),
    );
  }
}
```

### StatefulWidget
Includes `State<_WidgetName>` class with `initState()` and `dispose()` stubs.

### ConsumerWidget
For Riverpod integration:
```dart
class _CareBadgeList extends ConsumerWidget {
  const _CareBadgeList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badges = ref.watch(careBadgesProvider);
    // TODO: Build UI with state
    return const SizedBox();
  }
}
```

## Output

Places the generated file in `lib/views/components/{component_name}.dart` with:
- Proper imports
- Constructor with required/optional parameters
- Immutable const constructor
- Theme integration
- Null safety applied
- TODO comments for implementation

## Tips

- Use `--consumer` if the component needs to watch Riverpod providers
- Use `--stateful` only if you need local state (prefer Riverpod for app state)
- Follow the naming: `_WidgetName` (private) and file `widget_name.dart` (snake_case)
- Components should be under 200 lines; extract sub-components if larger
