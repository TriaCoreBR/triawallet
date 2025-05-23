class CheckoutItem {
  final String id;
  final String name;
  final double price;
  final String? description;
  final bool isProduct;
  int quantity;

  CheckoutItem({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.isProduct = true,
    this.quantity = 1,
  });

  CheckoutItem copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    bool? isProduct,
    int? quantity,
  }) {
    return CheckoutItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      isProduct: isProduct ?? this.isProduct,
      quantity: quantity ?? this.quantity,
    );
  }

  double get total => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'isProduct': isProduct,
      'quantity': quantity,
    };
  }

  factory CheckoutItem.fromMap(Map<String, dynamic> map) {
    return CheckoutItem(
      id: map['id'],
      name: map['name'],
      price: map['price'].toDouble(),
      description: map['description'],
      isProduct: map['isProduct'] ?? true,
      quantity: map['quantity'] ?? 1,
    );
  }
}
