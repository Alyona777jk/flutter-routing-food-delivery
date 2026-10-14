import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'providers/app_state.dart';
import 'screens/screens.dart';

GoRouter createRouter(AppState appState) {
  return GoRouter(
    initialLocation: '/restaurants',
    refreshListenable: appState,
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = appState.isLoggedIn;
      final isCartEmpty = appState.cart.isEmpty;
      final goingToCheckout = state.matchedLocation == '/checkout';

      if (goingToCheckout) {
        if (isCartEmpty) {
          return '/restaurants';
        }
        if (!isLoggedIn) {
          final fromLoc = Uri.encodeComponent(state.uri.toString());
          return '/login?from=$fromLoc';
        }
      }
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.restaurant),
                  label: 'Ресторани',
                ),
                NavigationDestination(
                  icon: Icon(Icons.shopping_cart),
                  label: 'Кошик',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long),
                  label: 'Замовлення',
                ),
              ],
            ),
          );
        },
        branches: [
          // Вкладка 1: Ресторани
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/restaurants',
                builder: (context, state) {
                  final sort = state.uri.queryParameters['sort'] ?? 'rating';
                  return RestaurantsScreen(sort: sort);
                },
                routes: [
                  GoRoute(
                    path: ':restaurantId',
                    builder: (context, state) {
                      final rId = state.pathParameters['restaurantId']!;
                      return RestaurantDetailScreen(restaurantId: rId);
                    },
                    routes: [
                      GoRoute(
                        path: 'dish/:dishId',
                        builder: (context, state) {
                          final rId = state.pathParameters['restaurantId']!;
                          final dId = state.pathParameters['dishId']!;
                          return DishScreen(
                            restaurantId: rId,
                            dishId: dId,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Вкладка 2: Кошик
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) {
                  final address = state.uri.queryParameters['address'];
                  return CartScreen(address: address);
                },
              ),
            ],
          ),
          // Вкладка 3: Замовлення
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                builder: (context, state) => const OrdersScreen(),
              ),
            ],
          ),
        ],
      ),
      // Маршрути поза вкладинками (Fullscreen)
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final from = state.uri.queryParameters['from'];
          return LoginScreen(from: from);
        },
      ),
      GoRoute(
        path: '/select-address',
        builder: (context, state) => const SelectAddressScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) {
          final address = state.uri.queryParameters['address'] ?? '';
          return CheckoutScreen(address: address);
        },
      ),
    ],
  );
}
