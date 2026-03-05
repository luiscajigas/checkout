class Order {
  final int? id;
  final String products;
  final double total;
  final String paymentMethod;
  final String cardNumber;
  final String cardHolder;
  final String promoCode;
  final String createdAt;

  Order({
    this.id,
    required this.products,
    required this.total,
    required this.paymentMethod,
    required this.cardNumber,
    required this.cardHolder,
    required this.promoCode,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'products': products,
        'total': total,
        'payment_method': paymentMethod,
        'card_number': cardNumber,
        'card_holder': cardHolder,
        'promo_code': promoCode,
        'created_at': createdAt,
      };

  factory Order.fromMap(Map<String, dynamic> map) => Order(
        id: map['id'],
        products: map['products'],
        total: map['total'],
        paymentMethod: map['payment_method'],
        cardNumber: map['card_number'],
        cardHolder: map['card_holder'],
        promoCode: map['promo_code'],
        createdAt: map['created_at'],
      );
}