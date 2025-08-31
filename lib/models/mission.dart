class Mission {
  final String id;
  final String name;
  final String? description;
  final String? location;
  final String? region;

  Mission({
    required this.id,
    required this.name,
    this.description,
    this.location,
    this.region,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      location: json['location'],
      region: json['region'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'region': region,
    };
  }
}
