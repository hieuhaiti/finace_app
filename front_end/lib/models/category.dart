class Category {
  static int _idCounter = 1;
  final String id;
  final String userId;
  final String name;
  final String icon;
  final String color;

  Category({
    String? id,
    required this.userId,
    required this.name,
    required this.icon,
    required this.color,
  }) : id = id ?? (_idCounter++).toString();

  factory Category.fromJson(Map<String, dynamic> json) {
    if (json['userId'] == null ||
        json['name'] == null ||
        json['icon'] == null ||
        json['color'] == null) {
      throw ArgumentError('Missing required fields in Category JSON');
    }
    return Category(
      id: json['id'] ?? (_idCounter++).toString(),
      userId: json['userId'],
      name: json['name'],
      icon: json['icon'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'icon': icon,
        'color': color,
      };
}
