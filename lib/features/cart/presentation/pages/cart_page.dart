import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../orders/presentation/providers/order_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../providers/cart_providers.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);

    return cartAsync.when(
      data: (cart) {
        if (cart.items.isEmpty) {
          return const Center(
            child: Text('Корзина пуста'),
          );
        }

        return ListView(
          children: [
            ...cart.items.map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 110,
                        height: 110,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: item.product.imageUrl == null
                              ? Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image),
                                )
                              : Image.network(
                                  item.product.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.broken_image),
                                    );
                                  },
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text('Модель: ${item.product.model}'),
                            const SizedBox(height: 4),
                            Text('Бренд: ${item.product.brandName}'),
                            const SizedBox(height: 8),
                            Text(
                              '${item.product.price.toStringAsFixed(0)} ₽',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                OutlinedButton(
                                  onPressed: item.quantity > 1
                                      ? () async {
                                          try {
                                            await ref
                                                .read(cartControllerProvider.notifier)
                                                .updateCartItem(
                                                  itemId: item.cartItemId,
                                                  quantity: item.quantity - 1,
                                                );
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(e.toString()),
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      : null,
                                  child: const Text('-'),
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                OutlinedButton(
                                  onPressed: () async {
                                    try {
                                      await ref
                                          .read(cartControllerProvider.notifier)
                                          .updateCartItem(
                                            itemId: item.cartItemId,
                                            quantity: item.quantity + 1,
                                          );
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(e.toString()),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text('+'),
                                ),
                                OutlinedButton(
                                  onPressed: () async {
                                    try {
                                      await ref
                                          .read(cartControllerProvider.notifier)
                                          .removeCartItem(item.cartItemId);

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Товар удалён из корзины'),
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
                                  child: const Text('Удалить'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Сумма по позиции: ${item.itemTotal.toStringAsFixed(0)} ₽',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Итого: ${cart.totalAmount.toStringAsFixed(0)} ₽',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _showCheckoutDialog(context, ref),
                      child: const Text('Оформить заказ'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Ошибка загрузки корзины: $error'),
      ),
    );
  }

  Future<void> _showCheckoutDialog(BuildContext context, WidgetRef ref) async {
    final profile = await ref.read(profileProvider.future);
    final deliveryTypes = await ref.read(deliveryTypesProvider.future);
    final paymentTypes = await ref.read(paymentTypesProvider.future);

    if (!context.mounted) return;

    if (profile.addresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сначала добавьте адрес в профиле'),
        ),
      );
      return;
    }

    int selectedAddressId = profile.addresses.first.id!;
    int selectedDeliveryId = deliveryTypes.first.id;
    int selectedPaymentId = paymentTypes.first.id;
    final commentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Оформление заказа'),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      DropdownButtonFormField<int>(
                        initialValue: selectedAddressId,
                        decoration: const InputDecoration(
                          labelText: 'Адрес доставки',
                        ),
                        items: profile.addresses
                            .map(
                              (address) => DropdownMenuItem(
                                value: address.id!,
                                child: Text(
                                  '${address.city}, ${address.street}, ${address.house}',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            selectedAddressId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: selectedDeliveryId,
                        decoration: const InputDecoration(
                          labelText: 'Способ доставки',
                        ),
                        items: deliveryTypes
                            .map(
                              (type) => DropdownMenuItem(
                                value: type.id,
                                child: Text(
                                  '${type.typeName} (${type.cost.toStringAsFixed(0)} ₽)',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            selectedDeliveryId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: selectedPaymentId,
                        decoration: const InputDecoration(
                          labelText: 'Способ оплаты',
                        ),
                        items: paymentTypes
                            .map(
                              (type) => DropdownMenuItem(
                                value: type.id,
                                child: Text(type.typeName),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            selectedPaymentId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: commentController,
                        decoration: const InputDecoration(
                          labelText: 'Комментарий к заказу',
                        ),
                        minLines: 2,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await ref.read(orderControllerProvider.notifier).createOrder(
                            addressId: selectedAddressId,
                            deliveryTypeId: selectedDeliveryId,
                            paymentTypeId: selectedPaymentId,
                            orderComment: commentController.text.trim(),
                          );

                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Заказ успешно оформлен'),
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
                  child: const Text('Подтвердить'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}