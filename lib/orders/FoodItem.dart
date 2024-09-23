class FoodItem {
  final int count;
  final String imageUrl;
  final String name;
  final String price;

  FoodItem({
    required this.count,
    required this.imageUrl,
    required this.name,
    required this.price,
  });

  factory FoodItem.fromMap(Map<dynamic, dynamic> map) {
    return FoodItem(
      count: map['count'] as int? ?? 0,
      imageUrl: map['imageUrl'] as String? ?? '',
      name: map['name'] as String? ?? '',
      price: map['price'] as String? ?? '',
    );
  }
}
