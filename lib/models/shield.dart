class ShieldStat {
  final String name;
  final num amount;

  ShieldStat({
    required this.name,
    required this.amount,
  });

  factory ShieldStat.fromJson(Map<String, dynamic> json) {
    return ShieldStat(
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

class ShieldScaling {
  final String name;
  final String scaling;

  ShieldScaling({
    required this.name,
    required this.scaling,
  });

  factory ShieldScaling.fromJson(Map<String, dynamic> json) {
    return ShieldScaling(
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

class Shield {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final String? category;
  final double? weight;
  final List<ShieldStat> attack;
  final List<ShieldStat> defence;
  final List<ShieldScaling> scalesWith;
  final List<ShieldStat> requiredAttributes;

  Shield({
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

  factory Shield.fromJson(Map<String, dynamic> json) {
    return Shield(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      image: json['image'],
      category: json['category'],
      weight: (json['weight'] as num?)?.toDouble(),
      attack: json['attack'] != null
          ? (json['attack'] as List).map((item) => ShieldStat.fromJson(item)).toList()
          : [],
      defence: json['defence'] != null
          ? (json['defence'] as List).map((item) => ShieldStat.fromJson(item)).toList()
          : [],
      scalesWith: json['scalesWith'] != null
          ? (json['scalesWith'] as List).map((item) => ShieldScaling.fromJson(item)).toList()
          : [],
      requiredAttributes: json['requiredAttributes'] != null
          ? (json['requiredAttributes'] as List).map((item) => ShieldStat.fromJson(item)).toList()
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
  num get physicalAttack {
    return attack.firstWhere((stat) => stat.name == 'Phy', orElse: () => ShieldStat(name: 'Phy', amount: 0)).amount;
  }

  num get criticalAttack {
    return attack.firstWhere((stat) => stat.name == 'Crit', orElse: () => ShieldStat(name: 'Crit', amount: 100)).amount;
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
