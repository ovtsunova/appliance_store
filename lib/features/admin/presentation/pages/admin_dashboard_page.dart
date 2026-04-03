import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../catalog/domain/models/brand.dart';
import '../../../catalog/domain/models/category.dart';
import '../../../catalog/domain/models/product.dart';
import '../../domain/models/admin_models.dart';
import '../../domain/models/admin_product_characteristic_item.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_service_panel.dart';

class AdminDashboardPage extends ConsumerWidget {
  final String section;

  const AdminDashboardPage({
    super.key,
    required this.section,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (section) {
      'products' => const _AdminProductsSection(),
      'orders' => const _AdminOrdersSection(),
      'users' => const _AdminUsersSection(),
      'reviews' => const _AdminReviewsSection(),
      'stats' => const _AdminStatsSection(),
      'audit' => const _AdminAuditSection(),
      _ => const Center(child: Text('Неизвестный раздел админки')),
    };
  }
}

class _EditableCharacteristic {
  int? id;
  String name;
  String value;

  _EditableCharacteristic({
    this.id,
    required this.name,
    required this.value,
  });

  factory _EditableCharacteristic.fromAdmin(
    AdminProductCharacteristicItem item,
  ) {
    return _EditableCharacteristic(
      id: item.id,
      name: item.name,
      value: item.value,
    );
  }
}

class _AdminProductsSection extends ConsumerStatefulWidget {
  const _AdminProductsSection();

  @override
  ConsumerState<_AdminProductsSection> createState() =>
      _AdminProductsSectionState();
}

class _AdminProductsSectionState extends ConsumerState<_AdminProductsSection> {
  int _tableIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(
          'Таблицы товаров',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ChoiceChip(
              label: const Text('Товары'),
              selected: _tableIndex == 0,
              onSelected: (_) => setState(() => _tableIndex = 0),
            ),
            ChoiceChip(
              label: const Text('Категории'),
              selected: _tableIndex == 1,
              onSelected: (_) => setState(() => _tableIndex = 1),
            ),
            ChoiceChip(
              label: const Text('Бренды'),
              selected: _tableIndex == 2,
              onSelected: (_) => setState(() => _tableIndex = 2),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_tableIndex == 0) const _ProductsTableSection(),
        if (_tableIndex == 1) const _CategoriesTableSection(),
        if (_tableIndex == 2) const _BrandsTableSection(),
      ],
    );
  }
}

class _ProductsTableSection extends ConsumerWidget {
  const _ProductsTableSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(adminProductsProvider);

    return productsAsync.when(
      data: (products) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: () => _showProductDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Добавить товар'),
          ),
          const SizedBox(height: 16),
          ...products.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Бренд: ${item.brand}'),
                      const SizedBox(height: 4),
                      Text('Категория: ${item.category}'),
                      const SizedBox(height: 4),
                      Text('Модель: ${item.model}'),
                      const SizedBox(height: 4),
                      Text('Цена: ${item.price.toStringAsFixed(0)} ₽'),
                      const SizedBox(height: 4),
                      Text('Остаток: ${item.stockQuantity}'),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          OutlinedButton(
                            onPressed: () async {
                              final product = await ref
                                  .read(adminRepositoryProvider)
                                  .getProductDetails(item.id);

                              final characteristics = await ref
                                  .read(adminRepositoryProvider)
                                  .getProductCharacteristics(item.id);

                              if (!context.mounted) return;

                              await _showProductDialog(
                                context,
                                ref,
                                product: product,
                                initialCharacteristics: characteristics,
                              );
                            },
                            child: const Text('Изменить'),
                          ),
                          OutlinedButton(
                            onPressed: () async {
                              try {
                                await ref
                                    .read(adminControllerProvider.notifier)
                                    .deleteProduct(item.id);

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Товар удалён'),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Ошибка загрузки товаров: $error'),
    );
  }

  Future<void> _showProductDialog(
    BuildContext context,
    WidgetRef ref, {
    Product? product,
    List<AdminProductCharacteristicItem>? initialCharacteristics,
  }) async {
    final brands = await ref.read(adminBrandsProvider.future);
    final categories = await ref.read(adminCategoriesProvider.future);

    if (!context.mounted) return;

    final isEdit = product != null;

    final nameController = TextEditingController(text: product?.name ?? '');
    final descriptionController =
        TextEditingController(text: product?.description ?? '');
    final modelController = TextEditingController(text: product?.model ?? '');
    final priceController = TextEditingController(
      text: product != null ? product.price.toStringAsFixed(0) : '',
    );
    final stockController = TextEditingController(
      text: product != null ? product.stockQuantity.toString() : '',
    );
    final imageUrlController =
        TextEditingController(text: product?.imageUrl ?? '');
    final warrantyController =
        TextEditingController(text: product?.warrantyPeriod ?? '');

    int selectedBrandId = product?.brand.id ?? brands.first.id;
    int selectedCategoryId = product?.category.id ?? categories.first.id;

    final characteristics = (initialCharacteristics ?? [])
        .map(_EditableCharacteristic.fromAdmin)
        .toList();

    final initialIds =
        (initialCharacteristics ?? []).map((e) => e.id).toSet();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEdit ? 'Изменить товар' : 'Добавить товар'),
              content: SizedBox(
                width: 620,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Наименование',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Описание',
                        ),
                        minLines: 2,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: modelController,
                        decoration: const InputDecoration(
                          labelText: 'Модель',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Цена',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: stockController,
                        decoration: const InputDecoration(
                          labelText: 'Количество на складе',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'URL изображения',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: warrantyController,
                        decoration: const InputDecoration(
                          labelText: 'Гарантия',
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: selectedBrandId,
                        decoration: const InputDecoration(labelText: 'Бренд'),
                        items: brands
                            .map(
                              (brand) => DropdownMenuItem(
                                value: brand.id,
                                child: Text(brand.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => selectedBrandId = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: selectedCategoryId,
                        decoration:
                            const InputDecoration(labelText: 'Категория'),
                        items: categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category.id,
                                child: Text(category.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => selectedCategoryId = value);
                        },
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Характеристики',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              characteristics.add(
                                _EditableCharacteristic(
                                  name: '',
                                  value: '',
                                ),
                              );
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Добавить характеристику'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (characteristics.isEmpty)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Характеристик пока нет'),
                        )
                      else
                        ...List.generate(characteristics.length, (index) {
                          final item = characteristics[index];
                          final nameFieldController =
                              TextEditingController(text: item.name);
                          final valueFieldController =
                              TextEditingController(text: item.value);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              color: Colors.grey.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: nameFieldController,
                                      decoration: const InputDecoration(
                                        labelText: 'Название характеристики',
                                      ),
                                      onChanged: (value) {
                                        item.name = value;
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: valueFieldController,
                                      decoration: const InputDecoration(
                                        labelText: 'Значение характеристики',
                                      ),
                                      onChanged: (value) {
                                        item.value = value;
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            characteristics.removeAt(index);
                                          });
                                        },
                                        child: const Text('Удалить'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
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
                      final cleanedCharacteristics = characteristics
                          .where(
                            (item) =>
                                item.name.trim().isNotEmpty &&
                                item.value.trim().isNotEmpty,
                          )
                          .toList();

                      int targetProductId;

                      if (isEdit) {
                        await ref
                            .read(adminControllerProvider.notifier)
                            .updateProduct(
                              productId: product.id,
                              productName: nameController.text.trim(),
                              description: descriptionController.text.trim(),
                              model: modelController.text.trim(),
                              price: int.parse(priceController.text.trim()),
                              stockQuantity:
                                  int.parse(stockController.text.trim()),
                              imageUrl: imageUrlController.text.trim(),
                              warrantyPeriod: warrantyController.text.trim(),
                              brandId: selectedBrandId,
                              categoryId: selectedCategoryId,
                            );

                        targetProductId = product.id;
                      } else {
                        targetProductId = await ref
                            .read(adminControllerProvider.notifier)
                            .createProduct(
                              productName: nameController.text.trim(),
                              description: descriptionController.text.trim(),
                              model: modelController.text.trim(),
                              price: int.parse(priceController.text.trim()),
                              stockQuantity:
                                  int.parse(stockController.text.trim()),
                              imageUrl: imageUrlController.text.trim(),
                              warrantyPeriod: warrantyController.text.trim(),
                              brandId: selectedBrandId,
                              categoryId: selectedCategoryId,
                            );
                      }

                      final currentIds = cleanedCharacteristics
                          .where((item) => item.id != null)
                          .map((item) => item.id!)
                          .toSet();

                      if (isEdit) {
                        final deletedIds = initialIds.difference(currentIds);
                        for (final deletedId in deletedIds) {
                          await ref
                              .read(adminControllerProvider.notifier)
                              .deleteProductCharacteristic(
                                productId: targetProductId,
                                characteristicId: deletedId,
                              );
                        }
                      }

                      for (final item in cleanedCharacteristics) {
                        if (item.id == null) {
                          await ref
                              .read(adminControllerProvider.notifier)
                              .createProductCharacteristic(
                                productId: targetProductId,
                                name: item.name.trim(),
                                value: item.value.trim(),
                              );
                        } else {
                          await ref
                              .read(adminControllerProvider.notifier)
                              .updateProductCharacteristic(
                                productId: targetProductId,
                                characteristicId: item.id!,
                                name: item.name.trim(),
                                value: item.value.trim(),
                              );
                        }
                      }

                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEdit
                                  ? 'Товар и характеристики обновлены'
                                  : 'Товар и характеристики добавлены',
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
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _CategoriesTableSection extends ConsumerWidget {
  const _CategoriesTableSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(adminCategoriesProvider);

    return categoriesAsync.when(
      data: (categories) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: () =>
                _showCategoryDialog(context, ref, categories: categories),
            icon: const Icon(Icons.add),
            label: const Text('Добавить категорию'),
          ),
          const SizedBox(height: 16),
          ...categories.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Описание: ${item.description ?? '—'}'),
                      const SizedBox(height: 4),
                      Text(
                        'Родительская категория: ${item.parentCategoryId?.toString() ?? '—'}',
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          OutlinedButton(
                            onPressed: () => _showCategoryDialog(
                              context,
                              ref,
                              categories: categories,
                              category: item,
                            ),
                            child: const Text('Изменить'),
                          ),
                          OutlinedButton(
                            onPressed: () async {
                              try {
                                await ref
                                    .read(adminControllerProvider.notifier)
                                    .deleteCategory(item.id);

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Категория удалена'),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Ошибка загрузки категорий: $error'),
    );
  }

  Future<void> _showCategoryDialog(
    BuildContext context,
    WidgetRef ref, {
    required List<Category> categories,
    Category? category,
  }) async {
    final isEdit = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    final descriptionController =
        TextEditingController(text: category?.description ?? '');
    int? selectedParentId = category?.parentCategoryId;

    final availableParents = categories
        .where((item) => category == null || item.id != category.id)
        .toList();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEdit ? 'Изменить категорию' : 'Добавить категорию'),
              content: SizedBox(
                width: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(labelText: 'Наименование'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Описание'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int?>(
                      value: selectedParentId,
                      decoration: const InputDecoration(
                        labelText: 'Родительская категория',
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Без родительской категории'),
                        ),
                        ...availableParents.map(
                          (item) => DropdownMenuItem<int?>(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => selectedParentId = value);
                      },
                    ),
                  ],
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
                      if (isEdit) {
                        await ref
                            .read(adminControllerProvider.notifier)
                            .updateCategory(
                              categoryId: category.id,
                              name: nameController.text.trim(),
                              description: descriptionController.text.trim(),
                              parentCategoryId: selectedParentId,
                            );
                      } else {
                        await ref
                            .read(adminControllerProvider.notifier)
                            .createCategory(
                              name: nameController.text.trim(),
                              description: descriptionController.text.trim(),
                              parentCategoryId: selectedParentId,
                            );
                      }

                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEdit
                                  ? 'Категория обновлена'
                                  : 'Категория добавлена',
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
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _BrandsTableSection extends ConsumerWidget {
  const _BrandsTableSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandsAsync = ref.watch(adminBrandsProvider);

    return brandsAsync.when(
      data: (brands) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: () => _showBrandDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Добавить бренд'),
          ),
          const SizedBox(height: 16),
          ...brands.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Страна: ${item.countryOfOrigin}'),
                      const SizedBox(height: 4),
                      Text('Контакты: ${item.contactInfo ?? '—'}'),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          OutlinedButton(
                            onPressed: () => _showBrandDialog(
                              context,
                              ref,
                              brand: item,
                            ),
                            child: const Text('Изменить'),
                          ),
                          OutlinedButton(
                            onPressed: () async {
                              try {
                                await ref
                                    .read(adminControllerProvider.notifier)
                                    .deleteBrand(item.id);

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Бренд удалён'),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Ошибка загрузки брендов: $error'),
    );
  }

  Future<void> _showBrandDialog(
    BuildContext context,
    WidgetRef ref, {
    Brand? brand,
  }) async {
    final isEdit = brand != null;
    final nameController = TextEditingController(text: brand?.name ?? '');
    final countryController =
        TextEditingController(text: brand?.countryOfOrigin ?? '');
    final contactController =
        TextEditingController(text: brand?.contactInfo ?? '');

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEdit ? 'Изменить бренд' : 'Добавить бренд'),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Наименование'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: countryController,
                  decoration: const InputDecoration(labelText: 'Страна'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contactController,
                  decoration: const InputDecoration(labelText: 'Контакты'),
                ),
              ],
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
                  if (isEdit) {
                    await ref.read(adminControllerProvider.notifier).updateBrand(
                          brandId: brand.id,
                          name: nameController.text.trim(),
                          countryOfOrigin: countryController.text.trim(),
                          contactInfo: contactController.text.trim(),
                        );
                  } else {
                    await ref.read(adminControllerProvider.notifier).createBrand(
                          name: nameController.text.trim(),
                          countryOfOrigin: countryController.text.trim(),
                          contactInfo: contactController.text.trim(),
                        );
                  }

                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEdit ? 'Бренд обновлён' : 'Бренд добавлен',
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
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }
}

class _AdminOrdersSection extends ConsumerWidget {
  const _AdminOrdersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrdersProvider);
    final statusesAsync = ref.watch(adminOrderStatusesProvider);

    return ordersAsync.when(
      data: (orders) => ListView(
        children: [
          Text(
            'Заказы',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          ...orders.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Заказ #${order.id}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Покупатель: ${order.customer}'),
                      const SizedBox(height: 4),
                      Text('Дата: ${order.orderDate ?? '—'}'),
                      const SizedBox(height: 4),
                      Text('Статус: ${order.status}'),
                      const SizedBox(height: 4),
                      Text('Доставка: ${order.deliveryType}'),
                      const SizedBox(height: 4),
                      Text('Оплата: ${order.paymentType}'),
                      const SizedBox(height: 4),
                      Text('Адрес: ${order.deliveryAddress}'),
                      const SizedBox(height: 8),
                      Text(
                        'Сумма: ${order.totalAmount.toStringAsFixed(0)} ₽',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      statusesAsync.when(
                        data: (statuses) => OutlinedButton(
                          onPressed: () => _showChangeStatusDialog(
                            context,
                            ref,
                            order.id,
                            statuses,
                          ),
                          child: const Text('Изменить статус'),
                        ),
                        loading: () => const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Ошибка загрузки заказов: $error'),
    );
  }

  Future<void> _showChangeStatusDialog(
    BuildContext context,
    WidgetRef ref,
    int orderId,
    List<AdminOrderStatusOption> statuses,
  ) async {
    int selectedStatusId = statuses.first.id;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Изменить статус заказа #$orderId'),
              content: DropdownButtonFormField<int>(
                value: selectedStatusId,
                items: statuses
                    .map(
                      (status) => DropdownMenuItem(
                        value: status.id,
                        child: Text(status.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    selectedStatusId = value;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await ref
                          .read(adminControllerProvider.notifier)
                          .changeOrderStatus(
                            orderId: orderId,
                            statusId: selectedStatusId,
                          );

                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Статус заказа изменён'),
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
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AdminUsersSection extends ConsumerWidget {
  const _AdminUsersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);
    final rolesAsync = ref.watch(adminRolesProvider);

    return usersAsync.when(
      data: (users) => ListView(
        children: [
          Text(
            'Пользователи',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          ...users.map(
            (user) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Email: ${user.email}'),
                      const SizedBox(height: 4),
                      Text('Роль: ${user.role}'),
                      const SizedBox(height: 4),
                      Text(
                        'Статус: ${user.isBlocked ? 'Заблокирован' : 'Активен'}',
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          rolesAsync.when(
                            data: (roles) => OutlinedButton(
                              onPressed: () => _showChangeRoleDialog(
                                context,
                                ref,
                                user.userId,
                                roles,
                              ),
                              child: const Text('Сменить роль'),
                            ),
                            loading: () => const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                          OutlinedButton(
                            onPressed: () async {
                              try {
                                if (user.isBlocked) {
                                  await ref
                                      .read(adminControllerProvider.notifier)
                                      .unblockUser(user.userId);
                                } else {
                                  await ref
                                      .read(adminControllerProvider.notifier)
                                      .blockUser(user.userId);
                                }

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        user.isBlocked
                                            ? 'Пользователь разблокирован'
                                            : 'Пользователь заблокирован',
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
                            child: Text(
                              user.isBlocked
                                  ? 'Разблокировать'
                                  : 'Заблокировать',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Ошибка загрузки пользователей: $error'),
    );
  }

  Future<void> _showChangeRoleDialog(
    BuildContext context,
    WidgetRef ref,
    int userId,
    List<AdminRoleOption> roles,
  ) async {
    int selectedRoleId = roles.first.id;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Сменить роль пользователя #$userId'),
              content: DropdownButtonFormField<int>(
                value: selectedRoleId,
                items: roles
                    .map(
                      (role) => DropdownMenuItem(
                        value: role.id,
                        child: Text(role.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    selectedRoleId = value;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await ref
                          .read(adminControllerProvider.notifier)
                          .changeUserRole(
                            userId: userId,
                            roleId: selectedRoleId,
                          );

                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Роль пользователя изменена'),
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
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AdminReviewsSection extends ConsumerWidget {
  const _AdminReviewsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(adminReviewsProvider);

    return reviewsAsync.when(
      data: (reviews) => ListView(
        children: [
          Text(
            'Отзывы',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          ...reviews.map(
            (review) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.productName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Автор: ${review.authorName}'),
                      const SizedBox(height: 4),
                      Text('Оценка: ${review.rating}'),
                      const SizedBox(height: 4),
                      Text('Дата: ${review.reviewDate ?? '—'}'),
                      const SizedBox(height: 8),
                      Text(review.comment ?? 'Без комментария'),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          OutlinedButton(
                            onPressed: () async {
                              try {
                                await ref
                                    .read(adminControllerProvider.notifier)
                                    .deleteReview(review.reviewId);

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Отзыв удалён'),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Ошибка загрузки отзывов: $error'),
    );
  }
}

class _AdminStatsSection extends ConsumerWidget {
  const _AdminStatsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomeAsync = ref.watch(adminIncomeStatsProvider);
    final topProductsAsync = ref.watch(adminTopProductsStatsProvider);
    final topUsersAsync = ref.watch(adminTopUsersStatsProvider);

    return ListView(
      children: [
        Text(
          'Статистика',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        incomeAsync.when(
          data: (stats) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Доход за 30 дней: ${stats.income.toStringAsFixed(0)} ₽',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Ошибка: $error'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        topProductsAsync.when(
          data: (items) => _VerticalBarChartCard(
            title: 'Топ товаров',
            items: items,
          ),
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Ошибка: $error'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        topUsersAsync.when(
          data: (items) => _HorizontalBarChartCard(
            title: 'Топ покупателей',
            items: items,
          ),
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Ошибка: $error'),
            ),
          ),
        ),
      ],
    );
  }
}

class _VerticalBarChartCard extends StatelessWidget {
  final String title;
  final List<AdminTopProductItem> items;

  const _VerticalBarChartCard({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = items.isEmpty
        ? 1.0
        : items
            .map((e) => e.totalSold.toDouble())
            .reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: items.map((item) {
                  final ratio = maxValue == 0 ? 0.0 : item.totalSold / maxValue;

                  return Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: SizedBox(
                      width: 90,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('${item.totalSold}'),
                          const SizedBox(height: 8),
                          Container(
                            width: 40,
                            height: 180 * ratio.clamp(0.0, 1.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.productName,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalBarChartCard extends StatelessWidget {
  final String title;
  final List<AdminTopUserItem> items;

  const _HorizontalBarChartCard({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = items.isEmpty
        ? 1.0
        : items.map((e) => e.totalSpent).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...items.map(
              (item) {
                final ratio = maxValue == 0 ? 0.0 : item.totalSpent / maxValue;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.fullName),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: ratio.clamp(0.0, 1.0),
                                minHeight: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 90,
                            child: Text(
                              '${item.totalSpent.toStringAsFixed(0)} ₽',
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminAuditSection extends ConsumerWidget {
  const _AdminAuditSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditAsync = ref.watch(adminAuditLogProvider);

    return auditAsync.when(
      data: (logs) => ListView(
        children: [
          Text(
            'Журнал аудита',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          const AdminServicePanel(),
          const SizedBox(height: 20),
          ...logs.map(
            (log) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${log.actionName} • ${log.entityName}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('ID сущности: ${log.entityId}'),
                      const SizedBox(height: 4),
                      Text('Аккаунт: ${log.accountEmail ?? '—'}'),
                      const SizedBox(height: 4),
                      Text('Дата: ${log.actionDate ?? '—'}'),
                      if ((log.oldValue ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Старое значение: ${log.oldValue}'),
                      ],
                      if ((log.newValue ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Новое значение: ${log.newValue}'),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Ошибка загрузки аудита: $error'),
    );
  }
}