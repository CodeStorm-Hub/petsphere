import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'petfolio_widgets.dart';

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
    this.onRetry,
  });

  final AsyncValue<T> value;
  final AsyncValueBuilder<T> data;
  final AsyncValueLoadingBuilder? loading;
  final AsyncValueErrorBuilder? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      error: (e, st) {
        if (error != null) return error!(e, st);
        return PetfolioEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Oops! Something went wrong',
          message: e.toString(),
          buttonText: onRetry != null ? 'Retry' : null,
          onButtonPressed: onRetry,
          buttonIcon: Icons.refresh_rounded,
        );
      },
      loading: () {
        if (loading != null) return loading!();
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
