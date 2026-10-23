import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/product_image_widget.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _selectedSize = 'S';
  final Set<String> _selectedToppings = {};
  int _quantity = 1;

  final Map<String, double> _sizeOptions = {
    'S': 0,
    'M': 5000,
    'L': 10000,
  };

  final Map<String, double> _toppingOptions = {
    'Trân châu': 8000,
    'Kem cheese': 10000,
    'Thạch cà phê': 7000,
  };

  double get _currentPrice {
    double price = widget.product.price + (_sizeOptions[_selectedSize] ?? 0);
    for (var topping in _selectedToppings) {
      price += _toppingOptions[topping] ?? 0;
    }
    return price * _quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.product.name,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh sản phẩm lớn
            Container(
              height: 280,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: ProductImageWidget(
                  imageUrl: widget.product.imageUrl,
                  width: double.infinity,
                  height: 280,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên sản phẩm
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Mô tả
                  if (widget.product.description.isNotEmpty)
                    Text(
                      widget.product.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textGrey,
                        height: 1.4,
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Giá cơ bản
                  Text(
                    formatCurrency(widget.product.price),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Chọn Size
                  const Text(
                    'Chọn size',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0E7DD),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: _sizeOptions.entries.map((entry) {
                        final size = entry.key;
                        final extra = entry.value;
                        final isSelected = _selectedSize == size;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedSize = size),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    size,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isSelected ? Colors.white : AppColors.textDark,
                                    ),
                                  ),
                                  if (extra > 0)
                                    Text(
                                      '+${formatCurrency(extra)}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isSelected ? Colors.white70 : AppColors.textGrey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Chọn Topping
                  const Text(
                    'Chọn topping (tùy chọn)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: _toppingOptions.entries.map((entry) {
                      final topping = entry.key;
                      final extra = entry.value;
                      final isChecked = _selectedToppings.contains(topping);
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isChecked) {
                                _selectedToppings.remove(topping);
                              } else {
                                _selectedToppings.add(topping);
                              }
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isChecked ? AppColors.primary : AppColors.border,
                                width: isChecked ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Checkbox(
                                  value: isChecked,
                                  activeColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        _selectedToppings.add(topping);
                                      } else {
                                        _selectedToppings.remove(topping);
                                      }
                                    });
                                  },
                                ),
                                Text(
                                  topping,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '+${formatCurrency(extra)}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Số lượng
                  const Text(
                    'Số lượng',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0E7DD),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 20),
                              onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '$_quantity',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 20),
                              onPressed: () => setState(() => _quantity++),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Nút Thêm vào giỏ
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        elevation: 3,
                      ),
                      onPressed: () {
                        context.read<CartProvider>().addToCart(
                              widget.product,
                              size: _selectedSize,
                              toppings: _selectedToppings.toList(),
                              quantity: _quantity,
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã thêm "${widget.product.name}" vào giỏ hàng!'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: Text(
                        'Thêm vào giỏ • ${formatCurrency(_currentPrice)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
