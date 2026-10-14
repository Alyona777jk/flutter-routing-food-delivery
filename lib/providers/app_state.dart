import 'package:flutter/foundation.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  // Тестові дані ресторанів
  final List<Restaurant> restaurants = [
    const Restaurant(
      id: 'r1',
      name: 'Піца Манія',
      rating: 4.8,
      distance: 1.2,
      menu: [
        Dish(
          id: 'd1',
          name: 'Маргарита',
          price: 180.0,
          description: 'Класична піца з томатами та моцарелою',
        ),
        Dish(
          id: 'd2',
          name: 'Пепероні',
          price: 220.0,
          description: 'Гостра піца з ковбасками пепероні',
        ),
      ],
    ),
    const Restaurant(
      id: 'r2',
      name: 'Суші Майстер',
      rating: 4.5,
      distance: 3.5,
      menu: [
        Dish(
          id: 'd3',
          name: 'Філадельфія',
          price: 290.0,
          description: 'Лосось, вершковий сир, авокадо',
        ),
        Dish(
          id: 'd4',
          name: 'Каліфорнія',
          price: 260.0,
          description: 'Краб, огірок, тобіко',
        ),
      ],
    ),
    const Restaurant(
      id: 'r3',
      name: 'Бургер Лаб',
      rating: 4.9,
      distance: 0.8,
      menu: [
        Dish(
          id: 'd5',
          name: 'Чизбургер XL',
          price: 195.0,
          description: 'Соковита яловичина, сир чедер, соус',
        ),
      ],
    ),
  ];

  // Кошик
  final List<CartItem> _cart = [];
  List<CartItem> get cart => List.unmodifiable(_cart);

  void addToCart(Dish dish, String restaurantId) {
    final index = _cart.indexWhere((item) => item.dish.id == dish.id);
    if (index >= 0) {
      _cart[index].quantity++;
    } else {
      _cart.add(CartItem(dish: dish, restaurantId: restaurantId));
    }
    notifyListeners();
  }

  void removeFromCart(String dishId) {
    _cart.removeWhere((item) => item.dish.id == dishId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  double get cartTotal =>
      _cart.fold(0, (sum, item) => sum + (item.dish.price * item.quantity));

  // Замовлення
  final List<Order> _orders = [
    Order(
      id: 'ord-101',
      restaurantName: 'Піца Манія',
      totalAmount: 400.0,
      address: 'вул. Хрещатик, 1',
      status: 'Completed',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
  List<Order> get orders => List.unmodifiable(_orders);

  void addOrder(String address, String comment) {
    if (_cart.isEmpty) return;
    final firstItem = _cart.first;
    final restaurant = restaurants.firstWhere(
      (r) => r.id == firstItem.restaurantId,
      orElse: () => restaurants.first,
    );

    _orders.insert(
      0,
      Order(
        id: 'ord-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        restaurantName: restaurant.name,
        totalAmount: cartTotal,
        address: address,
        status: 'Active',
        date: DateTime.now(),
      ),
    );
    clearCart();
  }
}
