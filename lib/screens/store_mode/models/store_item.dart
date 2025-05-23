class StoreItem {
  final String id;
  final String name;
  final double price;
  final String? description;
  final bool isProduct;
  final String? imageUrl;

  StoreItem({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.isProduct = true,
    this.imageUrl,
  });

  StoreItem copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    bool? isProduct,
    String? imageUrl,
  }) {
    return StoreItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      isProduct: isProduct ?? this.isProduct,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'isProduct': isProduct,
      'imageUrl': imageUrl,
    };
  }

  factory StoreItem.fromMap(Map<String, dynamic> map) {
    return StoreItem(
      id: map['id'],
      name: map['name'],
      price: map['price']?.toDouble() ?? 0.0,
      description: map['description'],
      isProduct: map['isProduct'] ?? true,
      imageUrl: map['imageUrl'],
    );
  }
}
