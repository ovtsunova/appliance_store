import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_shell.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/catalog/presentation/pages/catalog_page.dart';
import '../../features/catalog/presentation/pages/compare_page.dart';
import '../../features/catalog/presentation/pages/product_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/orders/presentation/pages/order_details_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);
  final currentUser = authState.asData?.value?.user;
  final roleValue = currentUser?.role.toApiValue();

  String homeForRole() {
    if (roleValue == 'Администратор') return '/admin/products';
    return '/catalog';
  }

  return GoRouter(
    initialLocation: '/catalog',
    redirect: (context, state) {
      if (authState.isLoading) {
        return null;
      }

      final location = state.matchedLocation;

      final isGuest = currentUser == null;
      final isAdmin = roleValue == 'Администратор';
      final isCustomer = roleValue == 'Покупатель';

      final isAuthPage = location == '/login' ||
          location == '/register' ||
          location == '/forgot-password';

      final isPublicPage = location == '/catalog' ||
          location == '/compare' ||
          location.startsWith('/product/');

      final isCustomerPage = location == '/favorites' ||
          location == '/cart' ||
          location == '/orders' ||
          location.startsWith('/order-details/') ||
          location == '/profile';

      final isAdminPage = location == '/admin' || location.startsWith('/admin/');

      if (isGuest) {
        if (isCustomerPage || isAdminPage) {
          return '/login';
        }
        return null;
      }

      if (isAdmin) {
        if (isAuthPage || isCustomerPage || isPublicPage) {
          return '/admin/products';
        }
        return null;
      }

      if (isCustomer) {
        if (isAuthPage) {
          return '/catalog';
        }

        if (isAdminPage) {
          return '/catalog';
        }

        return null;
      }

      if (!isGuest && isAuthPage) {
        return homeForRole();
      }

      if (!isGuest && (isPublicPage || isCustomerPage || isAdminPage)) {
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/catalog',
            builder: (context, state) => const CatalogPage(),
          ),
          GoRoute(
            path: '/product/:id',
            builder: (context, state) {
              final rawId = state.pathParameters['id']!;
              final productId = int.parse(rawId);
              return ProductPage(productId: productId);
            },
          ),
          GoRoute(
            path: '/compare',
            builder: (context, state) => const ComparePage(),
          ),
          GoRoute(
            path: '/favorites',
            builder: (context, state) => const FavoritesPage(),
          ),
          GoRoute(
            path: '/cart',
            builder: (context, state) => const CartPage(),
          ),
          GoRoute(
            path: '/orders',
            builder: (context, state) => const OrdersPage(),
          ),
          GoRoute(
            path: '/order-details/:id',
            builder: (context, state) {
              final rawId = state.pathParameters['id']!;
              final orderId = int.parse(rawId);
              return OrderDetailsPage(orderId: orderId);
            },
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/admin',
            builder: (context, state) =>
                const AdminDashboardPage(section: 'products'),
          ),
          GoRoute(
            path: '/admin/products',
            builder: (context, state) =>
                const AdminDashboardPage(section: 'products'),
          ),
          GoRoute(
            path: '/admin/orders',
            builder: (context, state) =>
                const AdminDashboardPage(section: 'orders'),
          ),
          GoRoute(
            path: '/admin/users',
            builder: (context, state) =>
                const AdminDashboardPage(section: 'users'),
          ),
          GoRoute(
            path: '/admin/reviews',
            builder: (context, state) =>
                const AdminDashboardPage(section: 'reviews'),
          ),
          GoRoute(
            path: '/admin/stats',
            builder: (context, state) =>
                const AdminDashboardPage(section: 'stats'),
          ),
          GoRoute(
            path: '/admin/audit',
            builder: (context, state) =>
                const AdminDashboardPage(section: 'audit'),
          ),
        ],
      ),
    ],
  );
});