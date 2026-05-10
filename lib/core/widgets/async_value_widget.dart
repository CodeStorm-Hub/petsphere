import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef AsyncValueBuilder<T> = Widget Function(T data);
typedef AsyncValueLoadingBuilder = Widget Function();
typedef AsyncValueErrorBuilder = Widget Function(Object error, StackTrace stackTrace);

class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
  });

  final AsyncValue<T> value;
  final AsyncValueBuilder<T> data;
  final AsyncValueLoadingBuilder? loading;
  final AsyncValueErrorBuilder? error;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      error: (e, st) {
        if (error != null) return error!(e, st);
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(e.toString(), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
      loading: () {
        if (loading != null) return loading!();
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
