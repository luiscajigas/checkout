import 'package:flutter/material.dart';
import '../models/products.dart';
import '../theme.dart';
import 'payment_screen.dart';

class PaymentDataScreen extends StatefulWidget {
  final List<Product> selectedProducts;
  final double total;

  const PaymentDataScreen({
    super.key,
    required this.selectedProducts,
    required this.total,
  });

  @override
  State<PaymentDataScreen> createState() => _PaymentDataScreenState();
}

class _PaymentDataScreenState extends State<PaymentDataScreen> {
  String _selectedMethod = 'Credit';
  final _cardNumberCtrl = TextEditingController();
  final _validUntilCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _cardHolderCtrl = TextEditingController();
  bool _saveCard = true;

  final List<String> _methods = ['PayPal', 'Credit', 'Wallet'];

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _validUntilCtrl.dispose();
    _cvvCtrl.dispose();
    _cardHolderCtrl.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_cardNumberCtrl.text.trim().isEmpty ||
        _cardHolderCtrl.text.trim().isEmpty ||
        _validUntilCtrl.text.trim().isEmpty ||
        _cvvCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all fields'),
            backgroundColor: AppColors.primary),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          selectedProducts: widget.selectedProducts,
          total: widget.total,
          paymentMethod: _selectedMethod,
          cardNumber: _cardNumberCtrl.text.trim(),
          cardHolder: _cardHolderCtrl.text.trim(),
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
                    const SizedBox(height: 8),
                    _buildTotalSection(),
                    const SizedBox(height: 24),
                    _buildPaymentMethodTabs(),
                    const SizedBox(height: 24),
                    _buildLabel('Card number'),
                    const SizedBox(height: 10),
                    _buildCardNumberField(),
                    const SizedBox(height: 16),
                    _buildValidAndCVV(),
                    const SizedBox(height: 16),
                    _buildLabel('Card holder'),
                    const SizedBox(height: 10),
                    _buildInputField(
                        controller: _cardHolderCtrl,
                        hint: 'Your name and surname'),
                    const SizedBox(height: 20),
                    _buildSaveCardToggle(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildProceedButton(),
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
              child: Text('Payment data',
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

  Widget _buildTotalSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Total price',
          style: TextStyle(
              fontSize: 14,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      Text('\$${widget.total.toStringAsFixed(2)}',
          style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppColors.primary)),
    ]);
  }

  Widget _buildPaymentMethodTabs() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Payment Method',
          style: TextStyle(
              fontSize: 14,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w500)),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: _methods.map((m) {
            final isSelected = _selectedMethod == m;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedMethod = m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(m,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.textGrey)),
                      if (isSelected) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.check_circle,
                            color: Colors.white, size: 16),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ]);
  }

  Widget _buildCardNumberField() {
    return _buildFieldContainer(
      child: Row(
        children: [
          _mastercardLogo(),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _cardNumberCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: '**** **** **** ****',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidAndCVV() {
    return Row(
      children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildLabel('Valid until'),
            const SizedBox(height: 10),
            _buildInputField(
                controller: _validUntilCtrl,
                hint: 'Month / Year',
                keyboardType: TextInputType.datetime),
          ]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildLabel('CVV'),
            const SizedBox(height: 10),
            _buildInputField(
                controller: _cvvCtrl,
                hint: '***',
                keyboardType: TextInputType.number,
                obscure: true),
          ]),
        ),
      ],
    );
  }

  Widget _buildSaveCardToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Text('Save card data for future payments',
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500)),
          ),
          Switch(
            value: _saveCard,
            onChanged: (v) => setState(() => _saveCard = v),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildProceedButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: GestureDetector(
        onTap: _onContinue,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8))
            ],
          ),
          child: const Center(
            child: Text('Proceed to confirm',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text,
      style: const TextStyle(
          fontSize: 14,
          color: AppColors.textGrey,
          fontWeight: FontWeight.w500));

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
  }) {
    return _buildFieldContainer(
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFieldContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
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
      child: child,
    );
  }

  Widget _mastercardLogo() {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 22,
        height: 22,
        decoration:
            const BoxDecoration(color: Color(0xFFEB001B), shape: BoxShape.circle),
      ),
      Transform.translate(
        offset: const Offset(-8, 0),
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
              color: const Color(0xFFF79E1B).withOpacity(0.9),
              shape: BoxShape.circle),
        ),
      ),
    ]);
  }
}
