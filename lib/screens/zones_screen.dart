import 'package:flutter/material.dart';
import '../models/zone.dart';
import '../models/boss.dart';
import '../models/weapon.dart';
import '../models/shield.dart';
import '../models/item.dart';
import '../models/mission.dart';
import '../services/progress_service.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/aurora_background.dart';
import '../widgets/glass_container.dart';
import 'zone_detail_screen.dart';
import 'arsenal_screen.dart';

class ZonesScreen extends StatefulWidget {
  final Map<String, Zone> zones;
  final List<Boss> bosses;
  final List<Boss> prologoBosses;
  final List<Weapon> weapons;
  final List<Shield> shields;
  final List<Item> items;
  final List<Mission> missions;
  final List<Map<String, dynamic>> locations;
  final VoidCallback? onNavigateToItems;

  const ZonesScreen({
    super.key,
    required this.zones,
    required this.bosses,
    required this.prologoBosses,
    required this.weapons,
    required this.shields,
    required this.items,
    required this.missions,
    required this.locations,
    this.onNavigateToItems,
  });

  @override
  State<ZonesScreen> createState() => _ZonesScreenState();
}

class _ZonesScreenState extends State<ZonesScreen> 
    with TickerProviderStateMixin {
  Map<String, bool> progressState = {};
  double overallProgress = 0.0;
  
  // Filtro por nivel
  int? _selectedLevel;
  List<String> _availableLevelRanges = [];
  List<Zone> _filteredZones = [];
  
  // Controladores de animación
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;
  late AnimationController _cardAnimationController;
  late Animation<double> _cardAnimation;

  // Controlador para Parallax
  late ScrollController _scrollController;
  double _backgroundOffset = 0.0;

  @override
  void initState() {
    super.initState();
    
    // Controlador de Scroll para Parallax
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      setState(() {
        _backgroundOffset = _scrollController.offset * 0.3;
      });
    });

    // Inicializar controladores de animación
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _loadProgress();
    _initializeFilters();
    
    // Iniciar animaciones
    _cardAnimationController.forward();
  }

  Future<void> _loadProgress() async {
    final progress = await ProgressService.getAllProgress();
    setState(() {
      progressState = progress;
      overallProgress = _calculateOverallProgress();
    });
    
    // Iniciar animación de progreso después de cargar datos
    _progressAnimationController.forward();
  }

  double _calculateOverallProgress() {
    if (widget.zones.isEmpty) return 0.0;
    
    double totalProgress = 0.0;
    for (final zone in widget.zones.values) {
      totalProgress += _calculateZoneProgress(zone);
    }
    
    return totalProgress / widget.zones.length;
  }

  double _calculateZoneProgress(Zone zone) {
    // Solo consideramos el progreso de los jefes por ahora
    final bossProgress = _calculateProgress(zone.jefes);
    
    // El resto retorna 0% de progreso
    return bossProgress;
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

  // Inicializar filtros disponibles
  void _initializeFilters() {
    final zones = widget.zones.values.toList();
    final difficulties = zones.map((zone) => _getZoneDifficulty(zone.name)).toSet().toList();
    difficulties.sort();
    
    _availableLevelRanges = difficulties.map((diff) => _getDifficultyText(diff)).toList();
    
    // Aplicar filtros iniciales
    _applyFilters();
  }

  // Aplicar filtro seleccionado
  void _applyFilters() {
    final zones = _getSortedZones();
    
    if (_selectedLevel == null) {
      _filteredZones = zones;
    } else {
      _filteredZones = zones.where((zone) {
        final difficulty = _getZoneDifficulty(zone.name);
        return difficulty == _selectedLevel;
      }).toList();
    }
    
    setState(() {});
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _cardAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Zonas de las Tierras Intermedias',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Stack(
        children: [
          Transform.translate(
            offset: Offset(0, _backgroundOffset),
            child: const AuroraBackground(),
          ),
          Column(
            children: [
              // Barra de progreso general
              Padding(
                padding: const EdgeInsets.all(16),
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Progreso General',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${overallProgress.toInt()}%',
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return LinearProgressIndicator(
                            value: (overallProgress / 100) * _progressAnimation.value,
                            backgroundColor: AppTheme.surfaceColor.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor.withOpacity(0.8 + 0.2 * _progressAnimation.value),
                            ),
                            minHeight: 8,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Indicador de ordenamiento con filtro integrado
              GestureDetector(
                onTap: () => _showFilterModal(context),
                child: GlassContainer(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  borderRadius: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _selectedLevel != null ? Icons.filter_list : Icons.sort,
                        color: AppTheme.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedLevel != null
                            ? 'Filtrado: ${_getDifficultyText(_selectedLevel!)} (${_filteredZones.length} zonas)'
                            : 'Zonas ordenadas por nivel recomendado (más bajo → más alto)',
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_selectedLevel != null)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedLevel = null;
                              _applyFilters();
                            });
                          },
                          icon: Icon(Icons.close, color: AppTheme.primaryColor, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                        ),
                    ],
                  ),
                ),
              ),

              // Lista de zonas ordenadas
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredZones.length,
                  itemBuilder: (context, index) {
                    final zone = _filteredZones[index];
                    final zoneProgress = _calculateZoneProgress(zone);
                    final difficulty = _getZoneDifficulty(zone.name);

                    return AnimatedBuilder(
                      animation: _cardAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 0.8 + 0.2 * _cardAnimation.value,
                          child: Opacity(
                            opacity: _cardAnimation.value.clamp(0.0, 1.0),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: GlassContainer(
                                onTap: () => _navigateToZoneDetail(zone),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    zone.name,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppTheme.textColor,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  // Indicador de dificultad
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: _getDifficultyColor(difficulty),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      _getDifficultyText(difficulty),
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              '${zoneProgress.toInt()}%',
                                              style: const TextStyle(
                                                color: AppTheme.primaryColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          zone.description ?? 'Una de las regiones de las Tierras Intermedias.',
                                          style: const TextStyle(
                                            color: AppTheme.textSecondaryColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        AnimatedBuilder(
                                          animation: _progressAnimation,
                                          builder: (context, child) {
                                            return LinearProgressIndicator(
                                              value: (zoneProgress / 100) * _progressAnimation.value,
                                              backgroundColor: AppTheme.surfaceColor.withOpacity(0.3),
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                AppTheme.primaryColor.withOpacity(0.7 + 0.3 * _progressAnimation.value),
                                              ),
                                              minHeight: 6,
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            _buildProgressItem('Jefes', zone.jefes.length, _calculateProgress(zone.jefes)),
                                            _buildProgressItem('Misiones', zone.misiones.length, 0.0), // Por ahora 0%
                                            _buildProgressItem('Armas', zone.armas.length, 0.0), // Por ahora 0%
                                            _buildProgressItem('Objetos', zone.objetos.length, 0.0), // Por ahora 0%
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            _buildProgressItem('Ubicaciones', zone.locaciones.length, 0.0), // Por ahora 0%
                                            const Spacer(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Botones de navegación en la parte inferior
              GlassContainer(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(8),
                borderRadius: 16,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {}, // Ya estamos en zonas
                        icon: const Icon(Icons.map),
                        label: const Text('Zonas'),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToArsenal(),
                        icon: const Icon(Icons.construction),
                        label: const Text('Arsenal'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.backgroundColor.withOpacity(0.5),
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
                        onPressed: widget.onNavigateToItems,
                        icon: const Icon(Icons.inventory_2),
                        label: const Text('Inventario'),
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
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, int total, double progress) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${progress.toInt()}%',
          style: TextStyle(
            color: progress == 100 ? Colors.green : AppTheme.primaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '$total',
          style: const TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  void _navigateToZoneDetail(Zone zone) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ZoneDetailScreen(
          zone: zone,
          bosses: widget.bosses, // Ahora incluye todos los jefes (incluido prólogo)
          weapons: widget.weapons,
          items: widget.items,
          missions: widget.missions,
          locations: widget.locations,
          onProgressChanged: () => _loadProgress(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween(begin: 0.9, end: 1.0).chain(
            CurveTween(curve: Curves.easeOutCubic),
          );

          return ScaleTransition(
            scale: animation.drive(tween),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          contentPadding: EdgeInsets.zero,
          content: GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Cerrar Sesión',
                  style: TextStyle(color: AppTheme.textColor, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  '¿Estás seguro de que quieres cerrar sesión?',
                  style: TextStyle(color: AppTheme.textSecondaryColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: AppTheme.textSecondaryColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _logout();
                      },
                      child: const Text('Cerrar Sesión'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    try {
      final authService = AuthService();
      await authService.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: AppTheme.veryHardColor,
          ),
        );
      }
    }
  }

  // Obtener zonas ordenadas por dificultad
  List<Zone> _getSortedZones() {
    final zones = widget.zones.values.toList();
    zones.sort((a, b) {
      final difficultyA = _getZoneDifficulty(a.name);
      final difficultyB = _getZoneDifficulty(b.name);
      
      // Si ambas tienen la misma dificultad, priorizar "Prólogo" primero
      if (difficultyA == difficultyB) {
        if (a.name == 'Prólogo') return -1;
        if (b.name == 'Prólogo') return 1;
        return a.name.compareTo(b.name);
      }
      
      return difficultyA.compareTo(difficultyB); // Orden ascendente (más fácil primero)
    });
    return zones;
  }

  // Obtener dificultad de una zona
  int _getZoneDifficulty(String zoneName) {
    // Mapeo de nombres de zonas a dificultades basado en regions_difficulty.es.json
    // Conectando los nombres reales de los datos con los nombres de la lista actualizada
    final difficultyMap = {
      // Nombres reales de los datos JSON
      'Prólogo': 1, // Prólogo y Necrolimbo oeste (Nivel 1-20)
      'Limgrave': 1, // Corresponde a "Prólogo y Necrolimbo oeste" (Nivel 1-20)
      'Península del Llanto': 3, // Nivel 20-30
      'Liurnia de los Lagos': 5, // Corresponde a "Liurnia este, Liurnia norte y Liurnia oeste" (Nivel 40-50)
      'Caelid': 8, // Corresponde a "Calid" (Nivel 60-70)
      'Meseta de Altus': 9, // Corresponde a "Meseta Altus" (Nivel 60-80)
      'Monte Gelmir': 12, // Nivel 80-100
      'Campo Sacroníveo': 15, // Corresponde a "Campo sacroníveo" (Nivel 100-120)
      'Sepultura del Dragón': 13, // Corresponde a "Montedrago, lecho de Greyoll" (Nivel 90-110)
      'Picos de los Gigantes': 15, // Corresponde a "Picos de los Gigantes oeste y Picos de los Gigantes este" (Nivel 100-120)
    };
    
    return difficultyMap[zoneName] ?? 5; // Dificultad media por defecto
  }

  // Obtener color de dificultad
  Color _getDifficultyColor(int difficulty) {
    if (difficulty <= 2) return AppTheme.easyColor;
    if (difficulty <= 4) return AppTheme.mediumColor;
    if (difficulty <= 6) return AppTheme.hardColor;
    return AppTheme.veryHardColor;
  }

  // Obtener texto de dificultad con rango de nivel
  String _getDifficultyText(int difficulty) {
    // Mapeo de dificultad a rangos de nivel basado en la guía
    final levelRanges = {
      1: 'Nivel 1-20',
      3: 'Nivel 20-30',
      5: 'Nivel 40-50',
      8: 'Nivel 60-70',
      9: 'Nivel 60-80',
      12: 'Nivel 80-100',
      13: 'Nivel 90-110',
      15: 'Nivel 100-120',
    };
    
    return levelRanges[difficulty] ?? 'Nivel ??';
  }

  // Mostrar modal de filtro
  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => GlassContainer(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                // Header del modal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filtrar por Nivel',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: AppTheme.textSecondaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Opción "Todos los niveles"
                _buildFilterOption(
                  context,
                  null,
                  'Todos los niveles',
                  'Mostrar todas las zonas',
                  Icons.all_inclusive,
                ),

                // Separador
                Divider(color: AppTheme.backgroundColor, height: 16),

                // Opciones de nivel específico
                ..._availableLevelRanges.map((levelRange) {
                  final difficulty = _getDifficultyFromText(levelRange);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildFilterOption(
                      context,
                      difficulty,
                      levelRange,
                      'Zonas de este nivel',
                      Icons.location_on,
                    ),
                  );
                }).toList(),

                const SizedBox(height: 16),
              ],
            ),
        ),
      ),
    );
  }

  // Construir opción de filtro
  Widget _buildFilterOption(
    BuildContext context,
    int? difficulty,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedLevel == difficulty;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLevel = difficulty;
          _applyFilters();
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.backgroundColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.black : AppTheme.textSecondaryColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  // Obtener dificultad desde el texto del nivel
  int? _getDifficultyFromText(String levelText) {
    final levelRanges = {
      'Nivel 1-20': 1,
      'Nivel 20-30': 3,
      'Nivel 40-50': 5,
      'Nivel 60-70': 8,
      'Nivel 60-80': 9,
      'Nivel 80-100': 12,
      'Nivel 90-110': 13,
      'Nivel 100-120': 15,
    };
    
    return levelRanges[levelText];
  }

  void _navigateToArsenal() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ArsenalScreen(
          weapons: widget.weapons,
          shields: widget.shields,
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
