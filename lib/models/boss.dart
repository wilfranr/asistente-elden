class Boss {
  final String id;
  final String name;
  final String? description;
  final String? location;
  final String? region;
  final String? healthPoints;
  final int? runes;
  final List<String>? drops;
  final List<String>? weaknesses;
  final List<String>? strengths;
  final List<String>? immunities;
  final String? type;
  final List<String>? recommendations;
  final String? image;

  Boss({
    required this.id,
    required this.name,
    this.description,
    this.location,
    this.region,
    this.healthPoints,
    this.runes,
    this.drops,
    this.weaknesses,
    this.strengths,
    this.immunities,
    this.type,
    this.recommendations,
    this.image,
  });

  factory Boss.fromJson(Map<String, dynamic> json) {
    return Boss(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      location: json['location'],
      region: json['region'],
      healthPoints: json['healthPoints'],
      runes: json['runes'],
      drops: json['drops'] != null ? List<String>.from(json['drops']) : null,
      weaknesses: json['weaknesses'] != null ? List<String>.from(json['weaknesses']) : null,
      strengths: json['strengths'] != null ? List<String>.from(json['strengths']) : null,
      immunities: json['immunities'] != null ? List<String>.from(json['immunities']) : null,
      type: json['type'],
      recommendations: json['recommendations'] != null ? List<String>.from(json['recommendations']) : null,
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'region': region,
      'healthPoints': healthPoints,
      'runes': runes,
      'drops': drops,
      'weaknesses': weaknesses,
      'strengths': strengths,
      'immunities': immunities,
      'type': type,
      'recommendations': recommendations,
      'image': image,
    };
  }
}
