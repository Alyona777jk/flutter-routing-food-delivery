class Restaurant {
  final String id;
  final String name;
  final double rating;
  final double distance; // в км
  final List<Dish> menu;

  const Restaurant({
    required this.id,
    required this.name,
    required this.rating,
    required this.distance,
    required this.menu,
  });
}

class Dish {
  final String id;
  final String name;
  final double price;
  final String description;

  const Dish({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
  });
}

class CartItem {
  final Dish dish;
  final String restaurantId;
  int quantity;

  CartItem({
    required this.dish,
    required this.restaurantId,
    this.quantity = 1,
  });
}

class Order {
  final String id;
  final String restaurantName;
  final double totalAmount;
  final String address;
  final String status; // "Active" або "Completed"
  final DateTime date;

  const Order({
    required this.id,
    required this.restaurantName,
    required this.totalAmount,
    required this.address,
    required this.status,
    required this.date,
  });
}
