import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';

class _ShellDestination {
  final String route;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _ShellDestination({
    required this.route,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.toString();

    final authState = ref.watch(authControllerProvider);
    final currentUser = authState.asData?.value?.user;
    final isLoadingAuth = authState.isLoading;

    if (isLoadingAuth) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final roleValue = currentUser?.role.toApiValue();
    final isGuest = currentUser == null;
    final isAdmin = roleValue == 'Администратор';
    final isCustomer = roleValue == 'Покупатель';

    final destinations = isGuest
        ? _guestDestinations
        : isAdmin
            ? _adminDestinations
            : isCustomer
                ? _customerDestinations
                : _guestDestinations;

    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 270,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  right: BorderSide(
                    color: Colors.black.withValues(alpha: 0.08),
                  ),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.storefront,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Appliance Store',
                            style: Theme.of(context).textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: NavigationRail(
                      selectedIndex: _indexFromPath(currentPath, destinations),
                      onDestinationSelected: (index) {
                        context.go(destinations[index].route);
                      },
                      extended: true,
                      minExtendedWidth: 270,
                      backgroundColor: Colors.transparent,
                      indicatorColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.12),
                      destinations: destinations
                          .map(
                            (item) => NavigationRailDestination(
                              icon: Icon(item.icon),
                              selectedIcon: Icon(item.selectedIcon),
                              label: Text(item.label),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: isGuest
                          ? ElevatedButton.icon(
                              onPressed: () => context.go('/login'),
                              icon: const Icon(Icons.login),
                              label: const Text('Войти'),
                            )
                          : OutlinedButton.icon(
                              onPressed: () async {
                                try {
                                  await ref
                                      .read(authControllerProvider.notifier)
                                      .logout();

                                  if (context.mounted) {
                                    context.go('/login');
                                  }
                                } catch (_) {
                                  if (context.mounted) {
                                    context.go('/login');
                                  }
                                }
                              },
                              icon: const Icon(Icons.logout),
                              label: const Text('Выйти'),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SizedBox.expand(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _indexFromPath(String path, List<_ShellDestination> destinations) {
    for (int i = 0; i < destinations.length; i++) {
      if (path.startsWith(destinations[i].route)) {
        return i;
      }
    }
    return 0;
  }

  static const List<_ShellDestination> _guestDestinations = [
    _ShellDestination(
      route: '/catalog',
      icon: Icons.storefront_outlined,
      selectedIcon: Icons.storefront,
      label: 'Каталог',
    ),
    _ShellDestination(
      route: '/compare',
      icon: Icons.compare_arrows_outlined,
      selectedIcon: Icons.compare_arrows,
      label: 'Сравнение',
    ),
  ];

  static const List<_ShellDestination> _customerDestinations = [
    _ShellDestination(
      route: '/catalog',
      icon: Icons.storefront_outlined,
      selectedIcon: Icons.storefront,
      label: 'Каталог',
    ),
    _ShellDestination(
      route: '/compare',
      icon: Icons.compare_arrows_outlined,
      selectedIcon: Icons.compare_arrows,
      label: 'Сравнение',
    ),
    _ShellDestination(
      route: '/favorites',
      icon: Icons.favorite_border,
      selectedIcon: Icons.favorite,
      label: 'Избранное',
    ),
    _ShellDestination(
      route: '/cart',
      icon: Icons.shopping_cart_outlined,
      selectedIcon: Icons.shopping_cart,
      label: 'Корзина',
    ),
    _ShellDestination(
      route: '/orders',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      label: 'Заказы',
    ),
    _ShellDestination(
      route: '/profile',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Профиль',
    ),
  ];

  static const List<_ShellDestination> _adminDestinations = [
    _ShellDestination(
      route: '/admin/products',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      label: 'Товары',
    ),
    _ShellDestination(
      route: '/admin/orders',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      label: 'Заказы',
    ),
    _ShellDestination(
      route: '/admin/users',
      icon: Icons.group_outlined,
      selectedIcon: Icons.group,
      label: 'Пользователи',
    ),
    _ShellDestination(
      route: '/admin/reviews',
      icon: Icons.rate_review_outlined,
      selectedIcon: Icons.rate_review,
      label: 'Отзывы',
    ),
    _ShellDestination(
      route: '/admin/stats',
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
      label: 'Статистика',
    ),
    _ShellDestination(
      route: '/admin/audit',
      icon: Icons.history_outlined,
      selectedIcon: Icons.history,
      label: 'Аудит',
    ),
  ];
}