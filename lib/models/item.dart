class Item {
  final String id;
  final String name;
  final String? description;
  final String? location;
  final String? type;
  final String? effect;

  Item({
    required this.id,
    required this.name,
    this.description,
    this.location,
    this.type,
    this.effect,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      location: json['location'],
      type: json['type'],
      effect: json['effect'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'type': type,
      'effect': effect,
    };
  }
}
