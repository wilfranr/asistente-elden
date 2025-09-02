class ArmorStat {
  final String name;
  final int amount;

  ArmorStat({
    required this.name,
    required this.amount,
  });

  factory ArmorStat.fromJson(Map<String, dynamic> json) {
    return ArmorStat(
      name: json['name'] ?? '',
      amount: json['amount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
    };
  }
}

class Armor {
  final String id;
  final String name;
  final String? image;
  final String? description;
  final String? category;
  final double weight;
  final List<ArmorStat> dmgNegation;
  final List<ArmorStat> resistance;

  Armor({
    required this.id,
    required this.name,
    this.image,
    this.description,
    this.category,
    required this.weight,
    required this.dmgNegation,
    required this.resistance,
  });

  factory Armor.fromJson(Map<String, dynamic> json) {
    return Armor(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      weight: (json['weight'] as num).toDouble(),
      dmgNegation: (json['dmgNegation'] as List<dynamic>)
          .map((e) => ArmorStat.fromJson(e as Map<String, dynamic>))
          .toList(),
      resistance: (json['resistance'] as List<dynamic>)
          .map((e) => ArmorStat.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'description': description,
      'category': category,
      'weight': weight,
      'dmgNegation': dmgNegation.map((e) => e.toJson()).toList(),
      'resistance': resistance.map((e) => e.toJson()).toList(),
    };
  }
}
