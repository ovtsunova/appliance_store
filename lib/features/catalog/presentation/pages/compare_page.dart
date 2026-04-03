import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/product.dart';
import '../providers/catalog_providers.dart';

class ComparePage extends ConsumerWidget {
  const ComparePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(catalogProductsProvider);
    final compareIds = ref.watch(compareProductsProvider);

    return productsAsync.when(
      data: (products) {
        final selected = products
            .where((product) => compareIds.contains(product.id))
            .toList();

        if (selected.length < 2) {
          return Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.compare_arrows, size: 56),
                      const SizedBox(height: 16),
                      Text(
                        'Сравнение товаров',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Добавь минимум два товара из каталога, чтобы увидеть сравнение.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final characteristicNames = _collectCharacteristicNames(selected);

        return ListView(
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 12,
              spacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Сравнение товаров',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(compareProductsProvider.notifier).clear();
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Очистить'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              'Выбранные товары',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            ...selected.map(
              (product) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProductSummaryCard(
                  product: product,
                  onRemove: () {
                    ref.read(compareProductsProvider.notifier).toggle(product.id);
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Основные параметры',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            _ComparisonMetricCard(
              title: 'Бренд',
              products: selected,
              valueBuilder: (product) => product.brand.name,
            ),
            _ComparisonMetricCard(
              title: 'Категория',
              products: selected,
              valueBuilder: (product) => product.category.name,
            ),
            _ComparisonMetricCard(
              title: 'Модель',
              products: selected,
              valueBuilder: (product) => product.model,
            ),
            _ComparisonMetricCard(
              title: 'Цена',
              products: selected,
              valueBuilder: (product) =>
                  '${product.price.toStringAsFixed(0)} ₽',
            ),
            _ComparisonMetricCard(
              title: 'Гарантия',
              products: selected,
              valueBuilder: (product) => product.warrantyPeriod ?? '—',
            ),
            _ComparisonMetricCard(
              title: 'Рейтинг',
              products: selected,
              valueBuilder: (product) =>
                  product.averageRating?.toStringAsFixed(1) ?? '—',
            ),
            _ComparisonMetricCard(
              title: 'Наличие',
              products: selected,
              valueBuilder: (product) =>
                  product.inStock ? 'Да (${product.stockQuantity})' : 'Нет',
            ),

            const SizedBox(height: 12),

            Text(
              'Характеристики',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            if (characteristicNames.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('У выбранных товаров нет характеристик для сравнения.'),
                ),
              )
            else
              ...characteristicNames.map(
                (name) => _ComparisonMetricCard(
                  title: name,
                  products: selected,
                  valueBuilder: (product) => _characteristicValue(product, name),
                ),
              ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, _) => Center(
        child: Text('Ошибка загрузки сравнения: $error'),
      ),
    );
  }

  static List<String> _collectCharacteristicNames(List<Product> products) {
    final names = <String>{};

    for (final product in products) {
      for (final item in product.characteristics) {
        names.add(item.name);
      }
    }

    final result = names.toList()..sort();
    return result;
  }

  static String _characteristicValue(Product product, String name) {
    for (final item in product.characteristics) {
      if (item.name == name) {
        return item.value;
      }
    }
    return '—';
  }
}

class _ProductSummaryCard extends StatelessWidget {
  final Product product;
  final VoidCallback onRemove;

  const _ProductSummaryCard({
    required this.product,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Image.network(
                    product.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image),
                      );
                    },
                  ),
                ),
              )
            else
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image),
              ),
            const SizedBox(height: 16),
            Text(
              product.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Бренд: ${product.brand.name}'),
            const SizedBox(height: 4),
            Text('Категория: ${product.category.name}'),
            const SizedBox(height: 4),
            Text('Модель: ${product.model}'),
            const SizedBox(height: 8),
            Text(
              '${product.price.toStringAsFixed(0)} ₽',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRemove,
              child: const Text('Убрать из сравнения'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonMetricCard extends StatelessWidget {
  final String title;
  final List<Product> products;
  final String Function(Product product) valueBuilder;

  const _ComparisonMetricCard({
    required this.title,
    required this.products,
    required this.valueBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...List.generate(products.length, (index) {
              final product = products[index];
              final isLast = index == products.length - 1;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    valueBuilder(product),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (!isLast) const Divider(height: 20),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}