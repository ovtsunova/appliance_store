import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/brand.dart';
import '../../domain/models/category.dart';
import '../../domain/models/product.dart';
import '../providers/catalog_providers.dart';

enum CatalogSort {
  popular,
  priceAsc,
  priceDesc,
  nameAsc,
}

class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({super.key});

  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
  String _search = '';
  int? _selectedCategoryId;
  int? _selectedBrandId;
  CatalogSort _sort = CatalogSort.popular;

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(catalogProductsProvider);

    return productsAsync.when(
      data: (products) {
        final categories = _extractCategories(products);
        final brands = _extractBrands(products);
        final filteredProducts = _applyFilters(products);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Каталог товаров',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Поиск, фильтрация, сортировка и переход в карточку товара.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Поиск по названию, модели, бренду',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _search = value.trim();
                });
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<int?>(
                    initialValue: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Категория',
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Все категории'),
                      ),
                      ...categories.map(
                        (category) => DropdownMenuItem<int?>(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<int?>(
                    initialValue: _selectedBrandId,
                    decoration: const InputDecoration(
                      labelText: 'Бренд',
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Все бренды'),
                      ),
                      ...brands.map(
                        (brand) => DropdownMenuItem<int?>(
                          value: brand.id,
                          child: Text(brand.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedBrandId = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<CatalogSort>(
                    initialValue: _sort,
                    decoration: const InputDecoration(
                      labelText: 'Сортировка',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: CatalogSort.popular,
                        child: Text('По популярности'),
                      ),
                      DropdownMenuItem(
                        value: CatalogSort.priceAsc,
                        child: Text('Сначала дешевле'),
                      ),
                      DropdownMenuItem(
                        value: CatalogSort.priceDesc,
                        child: Text('Сначала дороже'),
                      ),
                      DropdownMenuItem(
                        value: CatalogSort.nameAsc,
                        child: Text('По названию'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _sort = value;
                      });
                    },
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    ref.invalidate(catalogProductsProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Обновить'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _search = '';
                      _selectedCategoryId = null;
                      _selectedBrandId = null;
                      _sort = CatalogSort.popular;
                    });
                  },
                  icon: const Icon(Icons.filter_alt_off),
                  label: const Text('Сбросить'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Найдено товаров: ${filteredProducts.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredProducts.isEmpty
                  ? const Center(
                      child: Text('По заданным фильтрам ничего не найдено'),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;

                        int crossAxisCount = 1;
                        if (width >= 1400) {
                          crossAxisCount = 4;
                        } else if (width >= 1000) {
                          crossAxisCount = 3;
                        } else if (width >= 700) {
                          crossAxisCount = 2;
                        }

                        return GridView.builder(
                          itemCount: filteredProducts.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.72,
                          ),
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return _ProductCard(product: product);
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Text('Ошибка загрузки каталога: $error'),
      ),
    );
  }

  List<Category> _extractCategories(List<Product> products) {
    final map = <int, Category>{};
    for (final product in products) {
      map[product.category.id] = product.category;
    }
    return map.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<Brand> _extractBrands(List<Product> products) {
    final map = <int, Brand>{};
    for (final product in products) {
      map[product.brand.id] = product.brand;
    }
    return map.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<Product> _applyFilters(List<Product> products) {
    final normalizedSearch = _search.toLowerCase();

    final filtered = products.where((product) {
      final matchesSearch = normalizedSearch.isEmpty ||
          product.name.toLowerCase().contains(normalizedSearch) ||
          product.model.toLowerCase().contains(normalizedSearch) ||
          product.brand.name.toLowerCase().contains(normalizedSearch);

      final matchesCategory = _selectedCategoryId == null ||
          product.category.id == _selectedCategoryId;

      final matchesBrand =
          _selectedBrandId == null || product.brand.id == _selectedBrandId;

      return matchesSearch && matchesCategory && matchesBrand;
    }).toList();

    switch (_sort) {
      case CatalogSort.popular:
        filtered.sort(
          (a, b) => (b.averageRating ?? 0).compareTo(a.averageRating ?? 0),
        );
        break;
      case CatalogSort.priceAsc:
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case CatalogSort.priceDesc:
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case CatalogSort.nameAsc:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return filtered;
  }
}

class _ProductCard extends ConsumerWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compareIds = ref.watch(compareProductsProvider);
    final isInCompare = compareIds.contains(product.id);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: product.imageUrl == null
                    ? Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 42),
                        ),
                      )
                    : Image.network(
                        product.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 42),
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              product.brand.name,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Модель: ${product.model}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 18,
                  color: Colors.amber.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  '${product.averageRating ?? '-'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                Chip(
                  label: Text(product.inStock ? 'В наличии' : 'Нет в наличии'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${product.price.toStringAsFixed(0)} ₽',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/product/${product.id}'),
                    child: const Text('Подробнее'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(compareProductsProvider.notifier).toggle(
                            product.id,
                          );
                    },
                    child: Text(isInCompare ? 'Убрать' : 'Сравнить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}