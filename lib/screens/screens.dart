import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';

// --- Екран Ресторанів ---
class RestaurantsScreen extends StatelessWidget {
  final String sort;

  const RestaurantsScreen({super.key, required this.sort});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    List<Restaurant> list = List.from(appState.restaurants);

    if (sort == 'rating') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (sort == 'distance') {
      list.sort((a, b) => a.distance.compareTo(b.distance));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ресторани'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              context.go('/restaurants?sort=$value');
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'rating',
                child: Text('За рейтингом'),
              ),
              const PopupMenuItem(
                value: 'distance',
                child: Text('За відстанню'),
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          final r = list[index];
          return ListTile(
            title: Text(r.name),
            subtitle: Text('★ ${r.rating} •${r.distance} км'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/restaurants/${r.id}'),
          );
        },
      ),
    );
  }
}

// --- Деталі Ресторану ---
class RestaurantDetailScreen extends StatelessWidget {
  final String restaurantId;

  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final restaurant = appState.restaurants.firstWhere(
      (r) => r.id == restaurantId,
      orElse: () => Restaurant(
        id: restaurantId,
        name: 'Ресторан',
        rating: 0,
        distance: 0,
        menu: [],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(restaurant.name)),
      body: ListView.builder(
        itemCount: restaurant.menu.length,
        itemBuilder: (context, index) {
          final dish = restaurant.menu[index];
          return ListTile(
            title: Text(dish.name),
            subtitle: Text('${dish.price} грн'),
            trailing: ElevatedButton(
              onPressed: () {
                context.read<AppState>().addToCart(dish, restaurant.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${dish.name} додано у кошик')),
                );
              },
              child: const Text('У кошик'),
            ),
            onTap: () {
              context.push('/restaurants/$restaurantId/dish/${dish.id}');
            },
          );
        },
      ),
    );
  }
}

// --- Картка Страви ---
class DishScreen extends StatelessWidget {
  final String restaurantId;
  final String dishId;

  const DishScreen({
    super.key,
    required this.restaurantId,
    required this.dishId,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final restaurant = appState.restaurants.firstWhere(
      (r) => r.id == restaurantId,
      orElse: () => const Restaurant(
        id: '',
        name: '',
        rating: 0,
        distance: 0,
        menu: [],
      ),
    );
    final dish = restaurant.menu.firstWhere(
      (d) => d.id == dishId,
      orElse: () => const Dish(
        id: '',
        name: 'Страва не знайдена',
        price: 0,
        description: '',
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(dish.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dish.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Ціна: ${dish.price} грн',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(dish.description),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<AppState>().addToCart(dish, restaurantId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${dish.name} додано в кошик')),
                  );
                },
                child: const Text('Додати у кошик'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Екран Кошика ---
class CartScreen extends StatelessWidget {
  final String? address;

  const CartScreen({super.key, this.address});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Кошик')),
      body: appState.cart.isEmpty
          ? const Center(child: Text('Кошик порожній'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: appState.cart.length,
                    itemBuilder: (context, index) {
                      final item = appState.cart[index];
                      return ListTile(
                        title: Text(item.dish.name),
                        subtitle: Text(
                          '${item.dish.price} грн x ${item.quantity}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => appState.removeFromCart(item.dish.id),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Адреса доставки:'),
                        subtitle: Text(address ?? 'Не обрано'),
                        trailing: TextButton(
                          onPressed: () async {
                            final result = await context.push<String>('/select-address');
                            if (result != null && context.mounted) {
                              context.go('/cart?address=${Uri.encodeComponent(result)}');
                            }
                          },
                          child: const Text('Обрати'),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Разом:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${appState.cartTotal} грн',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final encAddress = address != null
                                ? Uri.encodeComponent(address!)
                                : '';
                            context.push('/checkout?address=$encAddress');
                          },
                          child: const Text('Оформити замовлення'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// --- Екран вибору адреси (Повернення результату context.pop) ---
class SelectAddressScreen extends StatelessWidget {
  const SelectAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final addresses = [
      'вул. Хрещатик, 1',
      'пр. Перемоги, 25',
      'вул. Лесі Українки, 10',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Вибір адреси')),
      body: ListView.builder(
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final addr = addresses[index];
          return ListTile(
            title: Text(addr),
            onTap: () => context.pop(addr),
          );
        },
      ),
    );
  }
}

// --- Екран Оформлення Замовлення (з PopScope) ---
class CheckoutScreen extends StatefulWidget {
  final String address;

  const CheckoutScreen({super.key, required this.address});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _commentController = TextEditingController();
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(() {
      if (_commentController.text.isNotEmpty && !_isDirty) {
        setState(() => _isDirty = true);
      } else if (_commentController.text.isEmpty && _isDirty) {
        setState(() => _isDirty = false);
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<bool> _showExitDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Незбережені зміни'),
        content: const Text(
          'Ви ввели коментар. Дійсно бажаєте залишити сторінку?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Залишити'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitDialog();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Оформлення')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ListTile(
                title: const Text('Адреса'),
                subtitle: Text(
                  widget.address.isEmpty ? 'Не вказана' : widget.address,
                ),
              ),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Коментар до замовлення',
                  border: OutlineInputBorder(),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AppState>().addOrder(
                          widget.address.isEmpty
                              ? 'Без адреси'
                              : widget.address,
                          _commentController.text,
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Замовлення створено!')),
                    );
                    context.go('/orders');
                  },
                  child: const Text('Підтвердити замовлення'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Екран Замовлень з TabBar ---
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<AppState>().orders;
    final activeOrders = orders.where((o) => o.status == 'Active').toList();
    final completedOrders =
        orders.where((o) => o.status == 'Completed').toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Замовлення'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Активні'),
              Tab(text: 'Виконані'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OrdersList(orders: activeOrders),
            _OrdersList(orders: completedOrders),
          ],
        ),
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  final List<Order> orders;

  const _OrdersList({required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(child: Text('Немає замовлень'));
    }
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return ListTile(
          title: Text('${order.restaurantName} (#${order.id})'),
          subtitle: Text('${order.address} •${order.totalAmount} грн'),
          trailing: Text(order.status),
        );
      },
    );
  }
}

// --- Екран Авторизації ---
class LoginScreen extends StatelessWidget {
  final String? from;

  const LoginScreen({super.key, this.from});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вхід')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Для продовження необхідно увійти'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.read<AppState>().login();
                  if (from != null && from!.isNotEmpty) {
                    context.go(Uri.decodeComponent(from!));
                  } else {
                    context.go('/restaurants');
                  }
                },
                child: const Text('Увійти в акаунт'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ErrorBuilder екран ---
class ErrorScreen extends StatelessWidget {
  final Exception? error;

  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Помилка')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              '404 - Сторінку не знайдено',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/restaurants'),
              child: const Text('На головну'),
            ),
          ],
        ),
      ),
    );
  }
}
