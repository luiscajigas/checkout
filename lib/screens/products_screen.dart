import 'package:flutter/material.dart';
import 'package:shop_app/models/products.dart';
import 'package:shop_app/theme.dart';
import 'package:shop_app/screens/payment_data_screen.dart';
import 'package:shop_app/screens/orders_history_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final List<Product> _products = [
    Product(          
      id: '1',
      name: 'camiseta negra',
      description: "camiseta negra para hombre",
      price: 80.00,
      color: AppColors.primary,
      imageAsset: 'assets/images/camiseta.jpg',
    ),
    Product(
      id: '2',
      name: 'Hoodie rojo',
      description: 'hoddie rojo unisex',
      price: 350.00,
      color: const Color(0xFF7C3AED),
      imageAsset: 'assets/images/hoddie.jpg',
    ),
    Product(
      id: '3',
      name: 'gorra azul',
      description: 'Accessorios de una sola talla',
      price: 150.00,
      color: const Color(0xFF0EA5E9),
      imageAsset: 'assets/images/gorra.jpg',
        ),
  ];

  List<Product> get _selected => _products.where((p) => p.selected).toList();
  double get _total => _selected.fold(0, (sum, p) => sum + p.price);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _products.length,
                itemBuilder: (_, i) => _ProductCard(
                  product: _products[i],
                  onTap: () => setState(
                      () => _products[i].selected = !_products[i].selected),
                ),
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Discover',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            Text('Select your products',
                style: TextStyle(fontSize: 14, color: AppColors.textGrey)),
          ]),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrdersHistoryScreen()),
            ),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Icon(Icons.receipt_long_outlined,
                  color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final hasSelection = _selected.isNotEmpty;
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Total',
                style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
            Text('\$${_total.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
          ]),
          GestureDetector(
            onTap: hasSelection
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentDataScreen(
                          selectedProducts: _selected,
                          total: _total,
                        ),
                      ),
                    )
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: hasSelection ? AppColors.primary : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text('Continue',
                  style: TextStyle(
                      color: hasSelection ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Product Card ─────────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: product.selected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: product.selected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(children: [
          // Imagen del producto — pon tus imágenes en assets/images/product_1.png etc.
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: product.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                product.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.image_outlined,
                  color: product.color.withValues(alpha: 0.4),
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text(product.description,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textGrey)),
                const SizedBox(height: 8),
                Text('\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: product.color)),
              ],
            ),
          ),
          // Checkbox
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color:
                  product.selected ? AppColors.primary : Colors.grey.shade100,
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    product.selected ? AppColors.primary : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: product.selected
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
        ]),
      ),
    );
  }
}
