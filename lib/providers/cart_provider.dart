import 'package:flutter/material.dart';
import '../models/product_model.dart';

class CartItem {
  final String id;
  final Product product;
  final String size; // 'S', 'M', 'L'
  final List<String> toppings;
  int quantity;

  CartItem({
    required this.id,
    required this.product,
    this.size = 'S',
    this.toppings = const [],
    this.quantity = 1,
  });

  double get unitPrice {
    double price = product.price;
    if (size == 'M') price += 5000;
    if (size == 'L') price += 10000;

    for (var topping in toppings) {
      if (topping == 'Trân châu') price += 8000;
      if (topping == 'Kem cheese') price += 10000;
      if (topping == 'Thạch cà phê') price += 7000;
    }
    return price;
  }

  double get totalPrice => unitPrice * quantity;
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  String _discountCode = '';
  double _discountAmount = 0.0;

  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get discountAmount => _discountAmount;
  double get total => (subtotal - _discountAmount) > 0 ? (subtotal - _discountAmount) : 0.0;
  String get discountCode => _discountCode;

  void addToCart(Product product, {String size = 'S', List<String> toppings = const [], int quantity = 1}) {
    final itemId = '${product.id}_${size}_${toppings.join("_")}';
    final existingIndex = _items.indexWhere((item) => item.id == itemId);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(
        id: itemId,
        product: product,
        size: size,
        toppings: toppings,
        quantity: quantity,
      ));
    }
    _recalculateDiscount();
    notifyListeners();
  }

  void updateQuantity(String id, int delta) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      final newQty = _items[index].quantity + delta;
      if (newQty > 0) {
        _items[index].quantity = newQty;
      } else {
        _items.removeAt(index);
      }
      _recalculateDiscount();
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _recalculateDiscount();
    notifyListeners();
  }

  bool applyCoupon(String code) {
    final trimmed = code.trim().toUpperCase();
    if (trimmed == 'COFFEE10') {
      _discountCode = trimmed;
      _discountAmount = 10000;
      notifyListeners();
      return true;
    } else if (trimmed == 'SALE20') {
      _discountCode = trimmed;
      _discountAmount = 20000;
      notifyListeners();
      return true;
    } else {
      _discountCode = '';
      _discountAmount = 0.0;
      notifyListeners();
      return false;
    }
  }

  void _recalculateDiscount() {
    if (_items.isEmpty) {
      _discountAmount = 0.0;
      _discountCode = '';
    }
  }

  void clearCart() {
    _items.clear();
    _discountAmount = 0.0;
    _discountCode = '';
    notifyListeners();
  }
}
