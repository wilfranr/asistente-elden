import 'package:flutter/material.dart';
import '../models/zone.dart';
import '../models/boss.dart';
import '../models/weapon.dart';
import '../models/item.dart';
import '../models/mission.dart';
import '../services/progress_service.dart';
import '../utils/app_theme.dart';
import 'boss_detail_screen.dart';
import 'weapons_screen.dart';

class ZoneDetailScreen extends StatefulWidget {
  final Zone zone;
  final List<Boss> bosses;
  final List<Weapon> weapons;
  final List<Item> items;
  final List<Mission> missions;
  final List<Map<String, dynamic>> locations;
  final VoidCallback onProgressChanged;

  const ZoneDetailScreen({
    super.key,
    required this.zone,
    required this.bosses,
    required this.weapons,
    required this.items,
    required this.missions,
    required this.locations,
    required this.onProgressChanged,
  });

  @override
  State<ZoneDetailScreen> createState() => _ZoneDetailScreenState();
}

class _ZoneDetailScreenState extends State<ZoneDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, bool> progressState = {};

  @override
  void initState() {
    super.initState();
    // Calcular el número de pestañas dinámicamente
    int tabCount = 1; // Siempre hay jefes
    if (widget.zone.locaciones.isNotEmpty) tabCount++;
    // Misiones y Objetos se manejan desde la pantalla principal
    
    _tabController = TabController(length: tabCount, vsync: this);
    _loadProgress();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final progress = await ProgressService.getAllProgress();
    setState(() {
      progressState = progress;
    });
  }

  Future<void> _onProgressChanged(String itemId, bool isCompleted) async {
    await ProgressService.saveProgress(itemId, isCompleted);
    await _loadProgress();
    widget.onProgressChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.zone.name,
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Pestañas de navegación
          Container(
            color: AppTheme.surfaceColor,
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.textSecondaryColor,
              indicatorColor: AppTheme.primaryColor,
              isScrollable: true,
              tabs: [
                _buildTab('Jefes', widget.zone.jefes.length, _calculateProgress(widget.zone.jefes)),
                if (widget.zone.locaciones.isNotEmpty)
                  _buildTab('Ubicaciones', widget.zone.locaciones.length, 0.0), // Por ahora 0%
                // Misiones y Objetos se manejan desde la pantalla principal
                // _buildTab('Misiones', widget.zone.misiones.length, _calculateProgress(widget.zone.misiones)),
                // _buildTab('Objetos', widget.zone.objetos.length, _calculateProgress(widget.zone.objetos)),
              ],
            ),
          ),
          
          // Contenido de las pestañas
          Expanded(
            child: TabBarView(
              controller: _tabController,
                          children: [
              _buildBossesTab(),
              if (widget.zone.locaciones.isNotEmpty) _buildLocationsTab(),
              // _buildMissionsTab(), // Se maneja desde la pantalla principal
              // _buildItemsTab(),   // Se maneja desde la pantalla principal
            ],
            ),
          ),
          
          // Botones de navegación en la parte inferior
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              border: Border(
                top: BorderSide(color: AppTheme.backgroundColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.map),
                    label: const Text('Zonas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.backgroundColor,
                      foregroundColor: AppTheme.textColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToAllWeapons(),
                    icon: const Icon(Icons.construction),
                    label: const Text('Arsenal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int count, double progress) {
    return Tab(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
          if (count > 0) ...[
            const SizedBox(height: 2),
            Text(
              '${progress.toInt()}%',
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBossesTab() {
    final zoneBosses = widget.bosses
        .where((boss) => widget.zone.jefes.contains(boss.id))
        .toList();

    if (zoneBosses.isEmpty) {
      return const Center(
        child: Text(
          'No hay jefes registrados en esta zona.',
          style: TextStyle(color: AppTheme.textSecondaryColor),
        ),
      );
    }

    // Ordenar jefes por dificultad
    zoneBosses.sort((a, b) => _calculateBossDifficulty(a).compareTo(_calculateBossDifficulty(b)));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: zoneBosses.length + 1, // +1 para el indicador de ordenamiento
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_esports, color: AppTheme.primaryColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Jefes ordenados por dificultad (más fácil → más difícil)',
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }

        final boss = zoneBosses[index - 1];
        final isCompleted = progressState[boss.id] ?? false;
        final difficulty = _calculateBossDifficulty(boss);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Checkbox(
              value: isCompleted,
              onChanged: (value) => _onProgressChanged(boss.id, value ?? false),
            ),
            title: Text(
              '${index}. ${boss.name}',
              style: TextStyle(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? AppTheme.textSecondaryColor : AppTheme.textColor,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (boss.healthPoints != null) ...[
                      Text(
                        '${boss.healthPoints} HP',
                        style: const TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.getDifficultyColor(difficulty),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        AppTheme.getDifficultyText(difficulty),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (boss.drops != null && boss.drops!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    boss.drops!.firstWhere(
                      (drop) => drop.contains('Runes'),
                      orElse: () => boss.drops!.first,
                    ),
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            trailing: TextButton(
              onPressed: () => _navigateToBossDetail(boss),
              child: const Text(
                'Ver',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMissionsTab() {
    final zoneMissions = widget.missions
        .where((mission) => widget.zone.misiones.contains(mission.id))
        .toList();

    if (zoneMissions.isEmpty) {
      return const Center(
        child: Text(
          'No hay misiones registradas en esta zona.',
          style: TextStyle(color: AppTheme.textSecondaryColor),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: zoneMissions.length,
      itemBuilder: (context, index) {
        final mission = zoneMissions[index];
        final isCompleted = progressState[mission.id] ?? false;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Checkbox(
              value: isCompleted,
              onChanged: (value) => _onProgressChanged(mission.id, value ?? false),
            ),
            title: Text(
              mission.name,
              style: TextStyle(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? AppTheme.textSecondaryColor : AppTheme.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  mission.description ?? '',
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
                if (mission.location != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Ubicación: ${mission.location}',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }



  Widget _buildItemsTab() {
    final zoneItems = widget.items
        .where((item) => widget.zone.objetos.contains(item.id))
        .toList();

    if (zoneItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2,
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'No hay objetos registrados en esta zona.',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: zoneItems.length,
      itemBuilder: (context, index) {
        final item = zoneItems[index];
        final isCompleted = progressState[item.id] ?? false;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Checkbox(
              value: isCompleted,
              onChanged: (value) => _onProgressChanged(item.id, value ?? false),
            ),
            title: Text(
              item.name,
              style: TextStyle(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? AppTheme.textSecondaryColor : AppTheme.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                if (item.description != null && item.description!.isNotEmpty) ...[
                  Text(
                    item.description!,
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    if (item.type != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primaryColor),
                        ),
                        child: Text(
                          item.type!,
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    if (item.effect != null && item.effect!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.textSecondaryColor),
                          ),
                          child: Text(
                            item.effect!,
                            style: const TextStyle(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.info_outline,
                color: AppTheme.primaryColor,
              ),
              onPressed: () => _showItemDetails(item),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationsTab() {
    // Mostrar la información de cada ubicación
    return _buildLocationsList();
  }

  Widget _buildLocationsList() {
    if (widget.zone.locaciones.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on,
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'No hay ubicaciones registradas en esta zona.',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.zone.locaciones.length,
      itemBuilder: (context, index) {
        final locationId = widget.zone.locaciones[index];
        final isCompleted = progressState[locationId] ?? false;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Checkbox(
              value: isCompleted,
              onChanged: (value) => _onProgressChanged(locationId, value ?? false),
            ),
            title: Text(
              _getLocationName(locationId),
              style: TextStyle(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? AppTheme.textSecondaryColor : AppTheme.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  _getLocationDescription(locationId),
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Ubicación en ${widget.zone.name}',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: _getLocationImage(locationId),
          ),
        );
      },
    );
  }

  Widget _getLocationImage(String locationId) {
    // Buscar la ubicación en los datos reales
    final location = widget.locations.firstWhere(
      (loc) => loc['id'] == locationId,
      orElse: () => <String, dynamic>{},
    );
    
    if (location.containsKey('image') && location['image'] != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          location['image'] as String,
          width: 60,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
        ),
      );
    }
    
    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 60,
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: const Icon(
        Icons.image,
        color: AppTheme.textSecondaryColor,
        size: 20,
      ),
    );
  }

  String _getLocationName(String locationId) {
    // Buscar la ubicación en los datos reales
    final location = widget.locations.firstWhere(
      (loc) => loc['id'] == locationId,
      orElse: () => <String, dynamic>{},
    );
    
    if (location.containsKey('name')) {
      return location['name'] as String;
    }
    
    // Fallback: formatear el ID
    return locationId.replaceAll('-', ' ').split(' ').map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }
      return word;
    }).join(' ');
  }

  String _getLocationDescription(String locationId) {
    // Buscar la ubicación en los datos reales
    final location = widget.locations.firstWhere(
      (loc) => loc['id'] == locationId,
      orElse: () => <String, dynamic>{},
    );
    
    if (location.containsKey('description')) {
      return location['description'] as String;
    }
    
    // Fallback: descripción genérica
    return 'Una ubicación interesante en ${widget.zone.name} que merece ser explorada.';
  }

  double _calculateProgress(List<String> itemIds) {
    if (itemIds.isEmpty) return 0.0; // No hay items = 0% de progreso
    
    int completedCount = 0;
    for (final itemId in itemIds) {
      if (progressState[itemId] == true) {
        completedCount++;
      }
    }
    
    return (completedCount / itemIds.length) * 100;
  }

  int _calculateBossDifficulty(Boss boss) {
    int difficulty = 0;
    
    // Basado en puntos de vida
    if (boss.healthPoints != null) {
      final health = int.tryParse(boss.healthPoints!.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
      if (health > 0) {
        if (health < 5000) difficulty += 1;
        else if (health < 15000) difficulty += 2;
        else if (health < 50000) difficulty += 3;
        else difficulty += 4;
      }
    }
    
    // Basado en runas (recompensa)
    if (boss.runes != null) {
      final runes = boss.runes!;
      if (runes > 100000) difficulty += 3;
      else if (runes > 50000) difficulty += 2;
      else if (runes > 10000) difficulty += 1;
    }
    
    // Jefes especiales conocidos por su dificultad
    const hardBosses = ['malenia', 'elden beast', 'radagon', 'maliketh', 'radahn'];
    if (hardBosses.any((hardBoss) => boss.name.toLowerCase().contains(hardBoss))) {
      difficulty += 2;
    }
    
    return difficulty;
  }

  void _navigateToBossDetail(Boss boss) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BossDetailScreen(boss: boss),
      ),
    );
  }

  void _showItemDetails(Item item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          title: Text(
            item.name,
            style: const TextStyle(
              color: AppTheme.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.description != null && item.description!.isNotEmpty) ...[
                  Text(
                    'Descripción:',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description!,
                    style: const TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (item.type != null) ...[
                  Text(
                    'Tipo:',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.type!,
                    style: const TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (item.effect != null && item.effect!.isNotEmpty) ...[
                  Text(
                    'Efecto:',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.effect!,
                    style: const TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cerrar',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToAllWeapons() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => WeaponsScreen(
          weapons: widget.weapons,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
