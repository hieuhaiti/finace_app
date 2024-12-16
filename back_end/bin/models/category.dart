class Category {
  static int _idCounter = 1;
  final String id;
  final String name;
  final String icon;

  Category({String? id, required this.name, required this.icon})
      : id = id ?? _idCounter.toString() {
    _idCounter++; 
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
      };
}