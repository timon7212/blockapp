import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_exceptions.dart';

/// A generic widget that maps [AsyncValue<T>] → loading / error / data.
class AsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function()? loading;
  final Widget Function(Object error, StackTrace? stack)? error;

  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => loading?.call() ?? const AppLoadingWidget(),
      error: (e, st) =>
          error?.call(e, st) ?? AppErrorWidget(error: e, stackTrace: st),
    );
  }
}

/// A sliver version.
class SliverAsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;

  const SliverAsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () =>
          const SliverToBoxAdapter(child: AppLoadingWidget()),
      error: (e, st) =>
          SliverToBoxAdapter(child: AppErrorWidget(error: e, stackTrace: st)),
    );
  }
}

/// ── Shared Loading widget ──
class AppLoadingWidget extends StatelessWidget {
  const AppLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}

/// ── Shared Error widget ──
class AppErrorWidget extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    required this.error,
    this.stackTrace,
    this.onRetry,
  });

  String _errorMessage(Object error) {
    if (error is ApiException) return error.message;
    return 'Something went wrong. Please try again.';
  }

  IconData _errorIcon(Object error) {
    if (error is NetworkException) return Icons.wifi_off_rounded;
    if (error is TimeoutException) return Icons.timer_off_rounded;
    if (error is UnauthorizedException) return Icons.lock_rounded;
    return Icons.error_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _errorIcon(error),
              size: 56,
              color: theme.colorScheme.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage(error),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton.tonal(
                onPressed: onRetry,
                child: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ── Empty state widget ──
class AppEmptyWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;

  const AppEmptyWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
