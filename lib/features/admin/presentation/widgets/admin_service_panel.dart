import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/admin_backup_item.dart';
import '../providers/admin_providers.dart';

class AdminServicePanel extends ConsumerWidget {
  const AdminServicePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupsAsync = ref.watch(adminBackupsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final bytes = await ref
                          .read(adminRepositoryProvider)
                          .exportOrdersCsv();

                      final blob = html.Blob([bytes], 'text/csv');
                      final url = html.Url.createObjectUrlFromBlob(blob);
                      // ignore: unused_local_variable
                      final anchor = html.AnchorElement(href: url)
                        ..setAttribute(
                          'download',
                          'orders_export_${DateTime.now().millisecondsSinceEpoch}.csv',
                        )
                        ..click();

                      html.Url.revokeObjectUrl(url);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('CSV экспорт подготовлен'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Экспорт CSV'),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await ref
                          .read(adminControllerProvider.notifier)
                          .createBackup();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Резервная копия создана'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Создать backup'),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await ref
                          .read(adminControllerProvider.notifier)
                          .restoreBackup();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('База восстановлена из последней копии'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.restore),
                  label: const Text('Восстановить последнюю'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        backupsAsync.when(
          data: (backups) => _BackupList(backups: backups),
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Ошибка списка резервных копий: $error'),
            ),
          ),
        ),
      ],
    );
  }
}

class _BackupList extends ConsumerWidget {
  final List<AdminBackupItem> backups;

  const _BackupList({
    required this.backups,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Резервные копии',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (backups.isEmpty)
              const Text('Резервных копий пока нет')
            else
              ...backups.map(
                (backup) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    color: Colors.grey.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            backup.fileName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text('Дата: ${backup.modifiedAt ?? '—'}'),
                          const SizedBox(height: 4),
                          Text('Размер: ${backup.sizeBytes} байт'),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () async {
                              try {
                                await ref
                                    .read(adminControllerProvider.notifier)
                                    .restoreBackup(filePath: backup.filePath);

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Восстановлено из ${backup.fileName}',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              }
                            },
                            child: const Text('Восстановить из этой копии'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}