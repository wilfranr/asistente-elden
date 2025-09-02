import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/boss.dart';
import '../models/weapon.dart';
import '../models/shield.dart';
import '../models/armor.dart';
import '../models/item.dart';
import '../models/zone.dart';
import '../models/mission.dart';

class DataService {
  // Método para cargar datos desde archivos JSON locales
  static Future<Map<String, dynamic>> loadGameData() async {
    try {
      // Cargar todos los archivos JSON en paralelo
      final futures = await Future.wait([
        _loadJsonFile('bosses.es.json'),
        _loadJsonFile('bosses_prologo.es.json'),
        _loadJsonFile('weapons.es.json'),
        _loadJsonFile('items.es.json'),
        _loadJsonFile('locations.es.json'),
        _loadJsonFile('regions_difficulty.es.json'),
        _loadJsonFile('armors.es.json'),
        _loadJsonFile('talismans.es.json'),
        _loadJsonFile('spirits.es.json'),
        _loadJsonFile('sorceries.es.json'),
        _loadJsonFile('shields.es.json'),
        _loadJsonFile('npcs.es.json'),
        _loadJsonFile('ashes.es.json'),
        _loadJsonFile('ammos.es.json'),
        _loadJsonFile('incantations.es.json'),
        _loadJsonFile('creatures.es.json'),
        _loadJsonFile('classes.es.json'),
      ]);

      // Procesar los datos
      final bosses = _parseBosses(futures[0]);
      final prologoBosses = _parseBosses(futures[1]);
      final weapons = _parseWeapons(futures[2]);
      final items = _parseItems(futures[3]);
      final locations = futures[4];
      final regionsDifficulty = futures[5];
      final armors = _parseArmors(futures[6]);
      final shields = _parseShields(futures[10]);
      
      // Combinar todos los jefes
      final allBosses = [...bosses, ...prologoBosses];
      
      // Procesar y organizar los datos en zonas
      final zones = _processZones(allBosses, weapons, items, locations, regionsDifficulty);
      
      return {
        'bosses': allBosses, // Usar todos los jefes combinados
        'prologoBosses': prologoBosses,
        'weapons': weapons,
        'items': items,
        'zones': zones,
        'shields': shields,
        'locations': locations,
        'regionsDifficulty': regionsDifficulty,
        'armors': armors,
        'talismans': futures[7],
        'spirits': futures[8],
        'sorceries': futures[9],
        'npcs': futures[11],
        'ashes': futures[12],
        'ammos': futures[13],
        'incantations': futures[14],
        'creatures': futures[15],
        'classes': futures[16],
      };
    } catch (e) {
      print('Error cargando datos locales: $e');
      // Si falla la carga local, usar datos mock
      return _getMockData();
    }
  }

  // Cargar archivo JSON desde assets
  static Future<dynamic> _loadJsonFile(String fileName) async {
    try {
      final jsonString = await rootBundle.loadString('lib/assets/data/$fileName');
      return json.decode(jsonString);
    } catch (e) {
      print('Error cargando $fileName: $e');
      return [];
    }
  }

  // Parsear jefes desde JSON
  static List<Boss> _parseBosses(dynamic jsonData) {
    if (jsonData is! List) return [];
    
    return jsonData.map((json) {
      // Extraer runas de los drops si están disponibles
      int? runes;
      if (json['drops'] != null && json['drops'] is List) {
        for (final drop in json['drops']) {
          if (drop.toString().toLowerCase().contains('runas')) {
            final runeText = drop.toString();
            // Buscar números con puntos decimales (ej: "3.200", "12.000", "13,000")
            final runeMatch = RegExp(r'(\d+(?:[.,]\d+)*)').firstMatch(runeText);
            if (runeMatch != null) {
              String numStr = runeMatch.group(1) ?? '0';
              // Remover puntos y comas que actúan como separadores de miles
              numStr = numStr.replaceAll('.', '').replaceAll(',', '');
              final runeValue = int.tryParse(numStr);
              if (runeValue != null) {
                runes = runeValue;
                break; // Tomar solo el primer valor de runas encontrado
              }
            }
          }
        }
      }

      return Boss(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'],
        location: json['location'],
        region: json['region'],
        healthPoints: json['healthPoints'],
        runes: runes,
        drops: json['drops'] != null ? List<String>.from(json['drops']) : null,
        weaknesses: json['weaknesses'] != null ? List<String>.from(json['weaknesses']) : null,
        strengths: json['strengths'] != null ? List<String>.from(json['strengths']) : null,
        immunities: json['immunities'] != null ? List<String>.from(json['immunities']) : null,
        type: json['type'],
        recommendations: json['recommendations'] != null ? List<String>.from(json['recommendations']) : null,
        image: json['image'],
      );
    }).toList();
  }

  // Parsear armas desde JSON
  static List<Weapon> _parseWeapons(dynamic jsonData) {
    if (jsonData is! List) return [];
    
    return jsonData.map((json) {
      return Weapon.fromJson(json);
    }).toList();
  }

  // Parsear escudos desde JSON
  static List<Shield> _parseShields(dynamic jsonData) {
    if (jsonData is! List) return [];

    return jsonData.map((json) {
      return Shield.fromJson(json);
    }).toList();
  }

  // Parsear armaduras desde JSON
  static List<Armor> _parseArmors(dynamic jsonData) {
    if (jsonData is! List) return [];

    return jsonData.map((json) {
      return Armor.fromJson(json);
    }).toList();
  }

  // Parsear items desde JSON
  static List<Item> _parseItems(dynamic jsonData) {
    if (jsonData is! List) return [];
    
    return jsonData.map((json) {
      return Item(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'],
        location: null, // No hay en los datos actuales
        type: json['type'],
        effect: json['effect'],
      );
    }).toList();
  }

  // Procesar zonas basándose en los datos reales
  static Map<String, Zone> _processZones(
    List<Boss> bosses,
    List<Weapon> weapons,
    List<Item> items,
    dynamic locations,
    dynamic regionsDifficulty,
  ) {
    final zones = <String, Zone>{};
    
    // Crear zonas basadas en las regiones de los jefes
    for (final boss in bosses) {
      if (boss.region != null) {
        final regionId = boss.region!.toLowerCase().replaceAll(' ', '-').replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u').replaceAll('ñ', 'n');
        
        if (!zones.containsKey(regionId)) {
          // Buscar dificultad de la región
          String? difficulty;
          if (regionsDifficulty is List) {
            final regionData = regionsDifficulty.firstWhere(
              (region) => region['name'] == boss.region,
              orElse: () => {'difficulty': 'Medio'},
            );
            difficulty = _getDifficultyText(regionData['difficulty'] ?? 5);
          }

          zones[regionId] = Zone(
            id: regionId,
            name: boss.region!,
            description: 'Explora la región de ${boss.region}.',
            jefes: [],
            misiones: [],
            armas: [],
            objetos: [],
            locaciones: [],
            difficulty: difficulty,
          );
        }
        
        zones[regionId]!.jefes.add(boss.id);
      }
    }

    // Agregar locaciones a las zonas correspondientes
    if (locations is List) {
      for (final location in locations) {
        if (location['region'] != null) {
          final regionName = location['region'] as String;
          final regionId = regionName.toLowerCase().replaceAll(' ', '-').replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u').replaceAll('ñ', 'n');
          
          if (zones.containsKey(regionId)) {
            zones[regionId]!.locaciones.add(location['id']);
          } else {
            // Crear zona si no existe
            String? difficulty;
            if (regionsDifficulty is List) {
              final regionData = regionsDifficulty.firstWhere(
                (region) => region['name'] == regionName,
                orElse: () => {'difficulty': 'Medio'},
              );
              difficulty = _getDifficultyText(regionData['difficulty'] ?? 5);
            }

            zones[regionId] = Zone(
              id: regionId,
              name: regionName,
              description: 'Explora la región de $regionName.',
              jefes: [],
              misiones: [],
              armas: [],
              objetos: [],
              locaciones: [location['id']],
              difficulty: difficulty,
            );
          }
        }
      }
    }

    // Agregar objetos a las zonas correspondientes
    if (items is List) {
      for (final item in items) {
        if (item.location != null) {
          final regionName = item.location as String;
          final regionId = regionName.toLowerCase().replaceAll(' ', '-').replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u').replaceAll('ñ', 'n');
          
          if (zones.containsKey(regionId)) {
            zones[regionId]!.objetos.add(item.id);
          }
        }
      }
    }

    // Si no hay zonas, usar las mock
    if (zones.isEmpty) {
      return _getMockZones();
    }

    return zones;
  }

  // Convertir número de dificultad a texto
  static String _getDifficultyText(dynamic difficulty) {
    if (difficulty is int) {
      if (difficulty <= 2) return 'Fácil';
      if (difficulty <= 4) return 'Medio';
      if (difficulty <= 6) return 'Difícil';
      if (difficulty <= 8) return 'Muy Difícil';
      return 'Extremo';
    }
    return 'Medio';
  }

  // Datos mock para fallback
  static Map<String, dynamic> _getMockData() {
    return {
      'bosses': _getMockBosses(),
      'weapons': _getMockWeapons(),
      'items': _getMockItems(),
      'zones': _getMockZones(),
      'missions': _getMockMissions(),
    };
  }

  static List<Boss> _getMockBosses() {
    return [
      Boss(
        id: 'godrick',
        name: 'Godrick el Injertado',
        description: 'Un jefe temprano del juego, conocido por su apariencia grotesca y ataques con hacha.',
        location: 'Castillo Stormveil',
        region: 'Limgrave',
        healthPoints: '6,080 HP',
        runes: 20000,
        drops: ['Remembrance of the Grafted', 'Godrick\'s Great Rune'],
        weaknesses: ['Fuego', 'Rayo'],
        strengths: ['Físico', 'Sangrado'],
        image: 'https://via.placeholder.com/400x225.png?text=Godrick+el+Injertado',
      ),
    ];
  }

  static List<Weapon> _getMockWeapons() {
    return [];
  }

  static List<Item> _getMockItems() {
    return [
      Item(
        id: 'item1',
        name: 'Poción de Curación',
        description: 'Restaura HP del jugador.',
        location: 'Limgrave',
        type: 'Consumible',
        effect: 'Restaura HP',
      ),
    ];
  }

  static Map<String, Zone> _getMockZones() {
    return {
      'limgrave': Zone(
        id: 'limgrave',
        name: 'Limgrave',
        description: 'La primera región que explorarás en Elden Ring.',
        jefes: ['godrick'],
        misiones: [],
        armas: ['sword1'],
        objetos: ['item1'],
        locaciones: ['iglesia-elleh', 'catacumbas-muerte'],
        difficulty: 'Fácil',
      ),
    };
  }

  static List<Mission> _getMockMissions() {
    return [
      Mission(
        id: 'mision01',
        name: 'Misión de Ranni',
        description: 'Ayuda a la bruja Ranni a desafiar a los Dos Dedos y forjar la Edad de las Estrellas.',
        location: 'Liurnia of the Lakes',
        region: 'Liurnia',
      ),
    ];
  }
}
