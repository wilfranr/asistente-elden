class WeaponStat {
  final String name;
  final int amount;

  WeaponStat({
    required this.name,
    required this.amount,
  });

  factory WeaponStat.fromJson(Map<String, dynamic> json) {
    return WeaponStat(
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

class WeaponScaling {
  final String name;
  final String scaling;

  WeaponScaling({
    required this.name,
    required this.scaling,
  });

  factory WeaponScaling.fromJson(Map<String, dynamic> json) {
    return WeaponScaling(
      name: json['name'] ?? '',
      scaling: json['scaling'] ?? '-',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'scaling': scaling,
    };
  }
}

class Weapon {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final String? category;
  final double? weight;
  final List<WeaponStat> attack;
  final List<WeaponStat> defence;
  final List<WeaponScaling> scalesWith;
  final List<WeaponStat> requiredAttributes;

  Weapon({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.category,
    this.weight,
    required this.attack,
    required this.defence,
    required this.scalesWith,
    required this.requiredAttributes,
  });

  factory Weapon.fromJson(Map<String, dynamic> json) {
    return Weapon(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      image: json['image'],
      category: json['category'],
      weight: json['weight']?.toDouble(),
      attack: json['attack'] != null 
          ? (json['attack'] as List).map((item) => WeaponStat.fromJson(item)).toList()
          : [],
      defence: json['defence'] != null 
          ? (json['defence'] as List).map((item) => WeaponStat.fromJson(item)).toList()
          : [],
      scalesWith: json['scalesWith'] != null 
          ? (json['scalesWith'] as List).map((item) => WeaponScaling.fromJson(item)).toList()
          : [],
      requiredAttributes: json['requiredAttributes'] != null 
          ? (json['requiredAttributes'] as List).map((item) => WeaponStat.fromJson(item)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'category': category,
      'weight': weight,
      'attack': attack.map((item) => item.toJson()).toList(),
      'defence': defence.map((item) => item.toJson()).toList(),
      'scalesWith': scalesWith.map((item) => item.toJson()).toList(),
      'requiredAttributes': requiredAttributes.map((item) => item.toJson()).toList(),
    };
  }

  // Métodos de utilidad
  int get physicalAttack {
    return attack.firstWhere((stat) => stat.name == 'Phy', orElse: () => WeaponStat(name: 'Phy', amount: 0)).amount;
  }

  int get criticalAttack {
    return attack.firstWhere((stat) => stat.name == 'Crit', orElse: () => WeaponStat(name: 'Crit', amount: 100)).amount;
  }

  String get primaryScaling {
    if (scalesWith.isEmpty) return '-';
    
    // Encontrar el mejor escalado (A > B > C > D > E)
    var bestScaling = scalesWith.first;
    for (var scaling in scalesWith) {
      if (_getScalingValue(scaling.scaling) > _getScalingValue(bestScaling.scaling)) {
        bestScaling = scaling;
      }
    }
    
    return '${bestScaling.name}: ${bestScaling.scaling}';
  }

  int _getScalingValue(String scaling) {
    switch (scaling.toUpperCase()) {
      case 'S': return 6;
      case 'A': return 5;
      case 'B': return 4;
      case 'C': return 3;
      case 'D': return 2;
      case 'E': return 1;
      default: return 0;
    }
  }

  String get requiredStats {
    if (requiredAttributes.isEmpty) return 'Ninguno';
    
    List<String> requirements = [];
    for (var attr in requiredAttributes) {
      if (attr.amount > 0) {
        requirements.add('${attr.name}: ${attr.amount}');
      }
    }
    
    return requirements.isNotEmpty ? requirements.join(', ') : 'Ninguno';
  }
}