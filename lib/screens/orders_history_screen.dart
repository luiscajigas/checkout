import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/order.dart';
import '../theme.dart';

class OrdersHistoryScreen extends StatefulWidget {
  const OrdersHistoryScreen({super.key});

  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen> {
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() =>
      setState(() => _ordersFuture = DatabaseHelper.instance.getAllOrders());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: FutureBuilder<List<Order>>(
                future: _ordersFuture,
                builder: (_, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary));
                  }
                  final orders = snap.data ?? [];
                  if (orders.isEmpty) return _buildEmpty();
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: orders.length,
                    itemBuilder: (_, i) => _OrderCard(
                      order: orders[i],
                      onDelete: () async {
                        await DatabaseHelper.instance
                            .deleteOrder(orders[i].id!);
                        _load();
                      },
                    ),
                  );
                },
              ),
            ),
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
              child: Text('Payment History',
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

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.textGrey),
          SizedBox(height: 12),
          Text('No payments yet',
              style: TextStyle(fontSize: 16, color: AppColors.textGrey)),
          SizedBox(height: 6),
          Text('Your completed orders will appear here.',
              style: TextStyle(fontSize: 13, color: AppColors.textGrey)),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onDelete;

  const _OrderCard({required this.order, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(order.createdAt);
    final dateStr = date != null
        ? '${date.day}/${date.month}/${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
        : order.createdAt;

    final lastFour = order.cardNumber.replaceAll(' ', '').length >= 4
        ? order.cardNumber
            .replaceAll(' ', '')
            .substring(order.cardNumber.replaceAll(' ', '').length - 4)
        : order.cardNumber;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('\$${order.total.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
            Row(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(order.paymentMethod,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _confirmDelete(context),
                child: const Icon(Icons.delete_outline,
                    size: 20, color: Colors.redAccent),
              ),
            ]),
          ],
        ),
        const SizedBox(height: 12),
        Divider(height: 1, color: Colors.grey.shade100),
        const SizedBox(height: 12),
        _row('Products', order.products),
        _row('Card holder', order.cardHolder),
        _row('Card', '**** **** **** $lastFour'),
        if (order.promoCode.isNotEmpty) _row('Promo code', order.promoCode),
        _row('Date', dateStr),
      ]),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete order?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textGrey))),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                onDelete();
              },
              child: const Text('Delete',
                  style: TextStyle(
                      color: Colors.redAccent, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 90,
              child: Text('$label:',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textGrey)),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark)),
            ),
          ],
        ),
      );
}