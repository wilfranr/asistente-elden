class Zone {
  final String id;
  final String name;
  final String? description;
  final List<String> jefes;
  final List<String> misiones;
  final List<String> armas;
  final List<String> objetos;
  final List<String> locaciones;
  final String? difficulty;

  Zone({
    required this.id,
    required this.name,
    this.description,
    required this.jefes,
    required this.misiones,
    required this.armas,
    required this.objetos,
    required this.locaciones,
    this.difficulty,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      jefes: json['jefes'] != null ? List<String>.from(json['jefes']) : [],
      misiones: json['misiones'] != null ? List<String>.from(json['misiones']) : [],
      armas: json['armas'] != null ? List<String>.from(json['armas']) : [],
      objetos: json['objetos'] != null ? List<String>.from(json['objetos']) : [],
      locaciones: json['locaciones'] != null ? List<String>.from(json['locaciones']) : [],
      difficulty: json['difficulty'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'jefes': jefes,
      'misiones': misiones,
      'armas': armas,
      'objetos': objetos,
      'locaciones': locaciones,
      'difficulty': difficulty,
    };
  }
}
