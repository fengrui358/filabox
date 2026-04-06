import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';

Future<void> markUsedUp(BuildContext context, WidgetRef ref, String itemId) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('确认标记用完'),
      content: const Text('确定要将此耗材标记为已用完吗？此操作不可撤销。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
          child: const Text('确认用完'),
        ),
      ],
    ),
  );
  if (confirm == true && context.mounted) {
    await ref.read(repositoryServiceProvider).markUsedUp(itemId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已标记用完')),
      );
    }
  }
}

Future<void> startDrying(BuildContext context, WidgetRef ref, String itemId) async {
  await ref.read(repositoryServiceProvider).startDrying(itemId);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('开始烘干')),
    );
  }
}

Future<void> endDrying(BuildContext context, WidgetRef ref, String itemId) async {
  await ref.read(repositoryServiceProvider).endDrying(itemId);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('结束烘干')),
    );
  }
}
