import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../favorites/presentation/providers/favorites_providers.dart';
import '../../../reviews/domain/models/product_review.dart';
import '../../../reviews/presentation/providers/review_providers.dart';
import '../providers/catalog_providers.dart';

class ProductPage extends ConsumerWidget {
  final int productId;

  const ProductPage({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productByIdProvider(productId));
    final compareIds = ref.watch(compareProductsProvider);
    final reviewsAsync = ref.watch(productReviewsProvider(productId));

    final authState = ref.watch(authControllerProvider);
    final currentUser = authState.asData?.value?.user;
    final isAuthLoading = authState.isLoading;

    return productAsync.when(
      data: (product) {
        final isInCompare = compareIds.contains(product.id);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${product.brand.name} • ${product.category.name}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 900;

                  final imageBlock = ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: product.imageUrl == null
                          ? Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.image, size: 56),
                              ),
                            )
                          : Image.network(
                              product.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Icon(Icons.broken_image, size: 56),
                                  ),
                                );
                              },
                            ),
                    ),
                  );

                  final infoBlock = Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${product.price.toStringAsFixed(0)} ₽',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 12),
                          Text('Модель: ${product.model}'),
                          const SizedBox(height: 8),
                          Text('Гарантия: ${product.warrantyPeriod ?? '—'}'),
                          const SizedBox(height: 8),
                          Text(
                            'Рейтинг: ${product.averageRating?.toStringAsFixed(1) ?? '—'}',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.inStock
                                ? 'На складе: ${product.stockQuantity} шт.'
                                : 'Нет в наличии',
                          ),
                          const SizedBox(height: 16),
                          if (product.description != null)
                            Text(product.description!),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  ref
                                      .read(compareProductsProvider.notifier)
                                      .toggle(product.id);
                                },
                                icon: const Icon(Icons.compare_arrows),
                                label: Text(
                                  isInCompare
                                      ? 'Убрать из сравнения'
                                      : 'Добавить к сравнению',
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  try {
                                    await ref
                                        .read(favoritesControllerProvider.notifier)
                                        .addFavorite(product.id);

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Товар добавлен в избранное',
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
                                icon: const Icon(Icons.favorite_border),
                                label: const Text('В избранное'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  try {
                                    await ref
                                        .read(cartControllerProvider.notifier)
                                        .addToCart(
                                          productId: product.id,
                                          quantity: 1,
                                        );

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Товар добавлен в корзину',
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
                                icon: const Icon(Icons.shopping_cart_outlined),
                                label: const Text('В корзину'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: imageBlock),
                        const SizedBox(width: 24),
                        Expanded(flex: 6, child: infoBlock),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      imageBlock,
                      const SizedBox(height: 24),
                      infoBlock,
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Характеристики',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ...product.characteristics.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  item.name,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  item.value,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _ReviewsSection(
                productId: product.id,
                reviewsAsync: reviewsAsync,
                currentUserId: currentUser?.userId,
                isAuthLoading: isAuthLoading,
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Text('Ошибка загрузки товара: $error'),
      ),
    );
  }
}

class _ReviewsSection extends ConsumerWidget {
  final int productId;
  final AsyncValue<List<ProductReview>> reviewsAsync;
  final int? currentUserId;
  final bool isAuthLoading;

  const _ReviewsSection({
    required this.productId,
    required this.reviewsAsync,
    required this.currentUserId,
    required this.isAuthLoading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return reviewsAsync.when(
      data: (reviews) {
        ProductReview? currentUserReview;
        if (currentUserId != null) {
          for (final review in reviews) {
            if (review.userId == currentUserId) {
              currentUserReview = review;
              break;
            }
          }
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Отзывы и оценки',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Здесь можно посмотреть мнения покупателей и оставить свой отзыв о товаре.',
                ),
                const SizedBox(height: 16),
                if (isAuthLoading)
                  Card(
                    color: Colors.grey.shade100,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Проверяем авторизацию...'),
                        ],
                      ),
                    ),
                  ),
                if (!isAuthLoading && currentUserId == null)
                  Card(
                    color: Colors.grey.shade100,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Чтобы оставить отзыв, сначала войдите в аккаунт.',
                      ),
                    ),
                  ),
                if (!isAuthLoading &&
                    currentUserId != null &&
                    currentUserReview == null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ElevatedButton.icon(
                      onPressed: () => _showReviewDialog(
                        context,
                        ref,
                        productId: productId,
                      ),
                      icon: const Icon(Icons.rate_review_outlined),
                      label: const Text('Оставить отзыв'),
                    ),
                  ),
                if (!isAuthLoading &&
                    currentUserId != null &&
                    currentUserReview != null)
                  Builder(
                    builder: (context) {
                      final review = currentUserReview!;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _showReviewDialog(
                                context,
                                ref,
                                productId: productId,
                                review: review,
                              ),
                              icon: const Icon(Icons.edit),
                              label: const Text('Изменить мой отзыв'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () async {
                                try {
                                  await ref
                                      .read(reviewControllerProvider.notifier)
                                      .deleteReview(
                                        productId: productId,
                                        reviewId: review.id,
                                      );

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
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Удалить мой отзыв'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                if (reviews.isEmpty)
                  const Text('Пока нет отзывов на этот товар')
                else
                  ...reviews.map(
                    (review) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        color: review.userId == currentUserId
                            ? Colors.grey.shade100
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.userName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => Icon(
                                    index < review.rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 20,
                                    color: Colors.amber.shade700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(review.comment ?? 'Без комментария'),
                              const SizedBox(height: 8),
                              Text(
                                review.reviewDate ?? '—',
                                style: Theme.of(context).textTheme.bodySmall,
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
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Ошибка загрузки отзывов: $error'),
        ),
      ),
    );
  }

  Future<void> _showReviewDialog(
    BuildContext context,
    WidgetRef ref, {
    required int productId,
    ProductReview? review,
  }) async {
    int selectedRating = review?.rating ?? 5;
    final commentController = TextEditingController(text: review?.comment ?? '');

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(review == null ? 'Оставить отзыв' : 'Изменить отзыв'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: selectedRating,
                      decoration: const InputDecoration(labelText: 'Оценка'),
                      items: List.generate(
                        5,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('${index + 1}'),
                        ),
                      ),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          selectedRating = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: commentController,
                      minLines: 3,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Комментарий',
                      ),
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
                      if (review == null) {
                        await ref
                            .read(reviewControllerProvider.notifier)
                            .createReview(
                              productId: productId,
                              rating: selectedRating,
                              comment: commentController.text.trim(),
                            );
                      } else {
                        await ref
                            .read(reviewControllerProvider.notifier)
                            .updateReview(
                              productId: productId,
                              reviewId: review.id,
                              rating: selectedRating,
                              comment: commentController.text.trim(),
                            );
                      }

                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              review == null
                                  ? 'Отзыв добавлен'
                                  : 'Отзыв обновлён',
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