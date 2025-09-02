import 'package:flutter/material.dart';
import '../models/weapon.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_container.dart';
import 'weapon_detail_screen.dart';

class WeaponsScreen extends StatefulWidget {
  final List<Weapon> weapons;

  const WeaponsScreen({
    super.key,
    required this.weapons,
  });

  @override
  State<WeaponsScreen> createState() => _WeaponsScreenState();
}

class _WeaponsScreenState extends State<WeaponsScreen> {
  List<Weapon> _filteredWeapons = [];
  String _searchQuery = '';
  String? _selectedCategory;
  
  @override
  void initState() {
    super.initState();
    _filteredWeapons = widget.weapons;
  }

  void _filterWeapons() {
    setState(() {
      _filteredWeapons = widget.weapons.where((weapon) {
        bool matchesSearch = weapon.name.toLowerCase().contains(_searchQuery.toLowerCase());
        bool matchesCategory = _selectedCategory == null || weapon.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
      
      // Ordenar por ataque físico descendente
      _filteredWeapons.sort((a, b) => b.physicalAttack.compareTo(a.physicalAttack));
    });
  }

  Set<String> get _availableCategories {
    return widget.weapons.map((weapon) => weapon.category ?? 'Sin categoría').toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de búsqueda y filtros
        GlassContainer(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Barra de búsqueda
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar armas...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryColor),
                  ),
                  filled: true,
                  fillColor: AppTheme.surfaceColor.withOpacity(0.5),
                ),
                style: const TextStyle(color: AppTheme.textColor),
                onChanged: (value) {
                  _searchQuery = value;
                  _filterWeapons();
                },
              ),
              const SizedBox(height: 12),

              // Filtro por categoría
              Row(
                children: [
                  const Icon(Icons.filter_list, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String?>(
                      value: _selectedCategory,
                      hint: const Text(
                        'Todas las categorías',
                        style: TextStyle(color: AppTheme.textSecondaryColor),
                      ),
                      isExpanded: true,
                      dropdownColor: AppTheme.surfaceColor,
                      style: const TextStyle(color: AppTheme.textColor),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                        _filterWeapons();
                      },
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Todas las categorías'),
                        ),
                        ..._availableCategories.map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        )).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Información de resultados
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_filteredWeapons.length} armas encontradas',
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
              Text(
                'Ordenado por daño',
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Lista de armas
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredWeapons.length,
            itemBuilder: (context, index) {
              final weapon = _filteredWeapons[index];
              return _buildWeaponCard(weapon);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeaponCard(Weapon weapon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        onTap: () => _navigateToWeaponDetail(weapon),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícono del arma por categoría
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getWeaponIcon(weapon.category),
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                // Información principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              weapon.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(weapon.category),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              weapon.category ?? 'Sin categoría',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Stats principales
                      Row(
                        children: [
                          _buildStatChip('⚔️ ${weapon.physicalAttack}', Colors.red),
                          const SizedBox(width: 8),
                          _buildStatChip('📊 ${weapon.primaryScaling}', Colors.blue),
                          const SizedBox(width: 8),
                          if (weapon.weight != null)
                            _buildStatChip('⚖️ ${weapon.weight!.toStringAsFixed(1)}', Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Requisitos
                      Text(
                        'Requisitos: ${weapon.requiredStats}',
                        style: const TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Flecha de navegación
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.textSecondaryColor,
                  size: 16,
                ),
              ],
            ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  IconData _getWeaponIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'espada recta':
      case 'espada':
        return Icons.construction;
      case 'hacha':
        return Icons.hardware;
      case 'lanza':
        return Icons.grain;
      case 'arco':
        return Icons.tune;
      case 'bastón':
        return Icons.timeline;
      default:
        return Icons.sports_esports;
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'espada recta':
      case 'espada':
        return Colors.blue;
      case 'hacha':
        return Colors.orange;
      case 'lanza':
        return Colors.green;
      case 'arco':
        return Colors.purple;
      case 'bastón':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  void _navigateToWeaponDetail(Weapon weapon) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => WeaponDetailScreen(
          weapon: weapon,
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

