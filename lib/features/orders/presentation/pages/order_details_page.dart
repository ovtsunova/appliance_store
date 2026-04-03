import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/order_providers.dart';

class OrderDetailsPage extends ConsumerWidget {
  final int orderId;

  const OrderDetailsPage({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(orderDetailsProvider(orderId));

    return detailsAsync.when(
      data: (order) {
        return ListView(
          children: [
            Text(
              'Заказ #${order.id}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Общая информация',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text('Дата: ${order.orderDate ?? '—'}'),
                    const SizedBox(height: 4),
                    Text('Статус: ${order.status}'),
                    const SizedBox(height: 4),
                    Text('Оплата: ${order.paymentType}'),
                    const SizedBox(height: 4),
                    Text(
                      'Доставка: ${order.delivery.type} (${order.delivery.cost.toStringAsFixed(0)} ₽)',
                    ),
                    const SizedBox(height: 4),
                    Text('Срок доставки: ${order.delivery.estimatedTime}'),
                    const SizedBox(height: 4),
                    Text('Адрес: ${order.address.fullAddress}'),
                    const SizedBox(height: 8),
                    Text(
                      'Итого: ${order.totalAmount.toStringAsFixed(0)} ₽',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if ((order.orderComment ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Комментарий: ${order.orderComment}'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Товары',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...order.items.map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text('Модель: ${item.product.model}'),
                      const SizedBox(height: 4),
                      Text('Бренд: ${item.product.brandName}'),
                      const SizedBox(height: 4),
                      Text('Количество: ${item.quantity}'),
                      const SizedBox(height: 4),
                      Text(
                        'Цена: ${item.price.toStringAsFixed(0)} ₽',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Сумма: ${item.itemTotal.toStringAsFixed(0)} ₽',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'История статусов',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...order.history.map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(item.status),
                  subtitle: Text(item.date ?? '—'),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Ошибка загрузки деталей заказа: $error'),
      ),
    );
  }
}