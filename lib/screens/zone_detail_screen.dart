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
  final VoidCallback onProgressChanged;

  const ZoneDetailScreen({
    super.key,
    required this.zone,
    required this.bosses,
    required this.weapons,
    required this.items,
    required this.missions,
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
    _tabController = TabController(length: 3, vsync: this);
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
                _buildTab('Misiones', widget.zone.misiones.length, _calculateProgress(widget.zone.misiones)),
                _buildTab('Objetos', widget.zone.objetos.length, _calculateProgress(widget.zone.objetos)),
              ],
            ),
          ),
          
          // Contenido de las pestañas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBossesTab(),
                _buildMissionsTab(),
                _buildItemsTab(),
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
        child: Text(
          'No hay objetos registrados en esta zona.',
          style: TextStyle(color: AppTheme.textSecondaryColor),
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
                Text(
                  item.description ?? '',
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
                if (item.type != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Tipo: ${item.type}',
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

  double _calculateProgress(List<String> itemIds) {
    if (itemIds.isEmpty) return 100.0;
    
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
