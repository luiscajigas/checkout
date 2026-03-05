import 'package:flutter/material.dart';
import '../models/products.dart';
import '../models/order.dart';
import '../db/database_helper.dart';
import '../theme.dart';

class PaymentScreen extends StatefulWidget {
  final List<Product> selectedProducts;
  final double total;
  final String paymentMethod;
  final String cardNumber;
  final String cardHolder;

  const PaymentScreen({
    super.key,
    required this.selectedProducts,
    required this.total,
    required this.paymentMethod,
    required this.cardNumber,
    required this.cardHolder,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _promoCtrl = TextEditingController(text: 'PROMO20-08');
  bool _isLoading = false;
  bool _paid = false;
  late List<Product> _items;
  late double _total;

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _items = widget.selectedProducts;
    _total = _calcTotal();
  }

  double _calcTotal() =>
      _items.fold(0, (sum, p) => sum + (p.price * p.quantity));

  String get _maskedCard {
    final raw = widget.cardNumber.replaceAll(' ', '');
    final last = raw.length >= 2 ? raw.substring(raw.length - 2) : raw;
    return 'Master Card ending **$last';
  }

  Future<void> _pay() async {
    setState(() => _isLoading = true);
    try {
      final order = Order(
        products: _items.map((p) => '${p.name} x${p.quantity}').join(', '),
        total: _total,
        paymentMethod: widget.paymentMethod,
        cardNumber: widget.cardNumber,
        cardHolder: widget.cardHolder,
        promoCode: _promoCtrl.text.trim(),
        createdAt: DateTime.now().toIso8601String(),
      );
      await DatabaseHelper.instance.insertOrder(order);
      setState(() {
        _isLoading = false;
        _paid = true;
      });
      _showSuccessDialog();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Payment Successful!',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            const SizedBox(height: 10),
            Text(
              'Your order has been saved.\nTotal: \$${widget.total.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('Back to Shop',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPromoCard(),
                    const SizedBox(height: 28),
                    _buildPaymentInfo(),
                    const SizedBox(height: 24),
                    _buildPromoCodeField(),
                    const SizedBox(height: 24),
                    _buildOrderSummary(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildPayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 20, color: AppColors.textDark),
          ),
          const Expanded(
            child: Center(
              child: Text('Payment',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark)),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildPromoCard() {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A6CF7), Color(0xFF7B93FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -20,
            child: Text('5',
                style: TextStyle(
                    fontSize: 170,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.07))),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/brand_logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.verified,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('\$50 off',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                const Text('On your first order',
                    style: TextStyle(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 4),
                const Text('* Promo code valid for orders over \$150.',
                    style: TextStyle(fontSize: 11, color: Colors.white54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Payment information',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text('Edit',
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(children: [
          _mastercardLogo(),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Card holder',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
            Text(_maskedCard,
                style:
                    const TextStyle(fontSize: 12, color: AppColors.textGrey)),
          ]),
        ]),
      ),
    ]);
  }

  Widget _buildPromoCodeField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Use promo code',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark)),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: TextField(
          controller: _promoCtrl,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
              letterSpacing: 1.2),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    ]);
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(children: [
        ..._items.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(p.name,
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.textGrey)),
                  ),
                  Row(children: [
                    _qtyButton(
                        icon: Icons.remove,
                        onTap: () {
                          if (p.quantity > 1) {
                            setState(() {
                              p.quantity--;
                              _total = _calcTotal();
                            });
                          }
                        }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('${p.quantity}',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark)),
                    ),
                    _qtyButton(
                        icon: Icons.add,
                        onTap: () {
                          setState(() {
                            p.quantity++;
                            _total = _calcTotal();
                          });
                        }),
                  ]),
                  Text('\$${(p.price * p.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                ],
              ),
            )),
        Divider(height: 16, color: Colors.grey.shade100),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            Text('\$${_total.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
          ],
        ),
      ]),
    );
  }

  Widget _buildPayButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: GestureDetector(
        onTap: (_isLoading || _paid) ? null : _pay,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: _paid ? Colors.green : AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: (_paid ? Colors.green : AppColors.primary)
                      .withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8))
            ],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Text(_paid ? 'Paid ✓' : 'Pay',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 16, color: AppColors.textDark),
      ),
    );
  }

  Widget _mastercardLogo() {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
              color: Color(0xFFEB001B), shape: BoxShape.circle)),
      Transform.translate(
        offset: const Offset(-8, 0),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
              color: const Color(0xFFF79E1B).withOpacity(0.9),
              shape: BoxShape.circle),
        ),
      ),
    ]);
  }
}
