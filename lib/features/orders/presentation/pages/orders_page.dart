import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/order_summary.dart';
import '../providers/order_providers.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return ordersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return const Center(
            child: Text('У вас пока нет заказов'),
          );
        }

        return ListView(
          children: orders
              .map((order) => _OrderCard(order: order))
              .toList(growable: false),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Ошибка загрузки заказов: $error'),
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final OrderSummary order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Заказ #${order.id}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text('Дата: ${order.orderDate ?? '—'}'),
            const SizedBox(height: 4),
            Text('Статус: ${order.status}'),
            const SizedBox(height: 4),
            Text('Доставка: ${order.deliveryType}'),
            const SizedBox(height: 4),
            Text('Оплата: ${order.paymentType}'),
            const SizedBox(height: 4),
            Text(
              'Сумма: ${order.totalAmount.toStringAsFixed(0)} ₽',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if ((order.orderComment ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Комментарий: ${order.orderComment}'),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton(
                  onPressed: () => context.go('/order-details/${order.id}'),
                  child: const Text('Подробнее'),
                ),
                if (order.canBeCancelled)
                  OutlinedButton(
                    onPressed: () async {
                      try {
                        await ref
                            .read(orderControllerProvider.notifier)
                            .cancelOrder(order.id);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Заказ отменён'),
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
                    child: const Text('Отменить'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}