import 'package:flutter/material.dart';
import '../models/shield.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_container.dart';
import 'shield_detail_screen.dart';

class ShieldsScreen extends StatefulWidget {
  final List<Shield> shields;

  const ShieldsScreen({
    super.key,
    required this.shields,
  });

  @override
  State<ShieldsScreen> createState() => _ShieldsScreenState();
}

class _ShieldsScreenState extends State<ShieldsScreen> {
  List<Shield> _filteredShields = [];
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _filteredShields = widget.shields;
  }

  void _filterShields() {
    setState(() {
      _filteredShields = widget.shields.where((shield) {
        bool matchesSearch = shield.name.toLowerCase().contains(_searchQuery.toLowerCase());
        bool matchesCategory = _selectedCategory == null || shield.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();

      // Ordenar por defensa física descendente
      _filteredShields.sort((a, b) => (b.defence.firstWhere((element) => element.name == 'Phy').amount as int)
          .compareTo((a.defence.firstWhere((element) => element.name == 'Phy').amount as int)));
    });
  }

  Set<String> get _availableCategories {
    return widget.shields.map((shield) => shield.category ?? 'Sin categoría').toSet();
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
                  hintText: 'Buscar escudos...',
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
                  _filterShields();
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
                        _filterShields();
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
                '${_filteredShields.length} escudos encontrados',
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
              Text(
                'Ordenado por defensa',
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Lista de escudos
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredShields.length,
            itemBuilder: (context, index) {
              final shield = _filteredShields[index];
              return _buildShieldCard(shield);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShieldCard(Shield shield) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        onTap: () => _navigateToShieldDetail(shield),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícono del escudo por categoría
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getShieldIcon(shield.category),
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
                              shield.name,
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
                              color: _getCategoryColor(shield.category),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              shield.category ?? 'Sin categoría',
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
                          _buildStatChip('🛡️ ${shield.defence.firstWhere((stat) => stat.name == 'Phy').amount}', Colors.blue),
                          const SizedBox(width: 8),
                          _buildStatChip('⚖️ ${shield.weight?.toStringAsFixed(1)}', Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Requisitos
                      Text(
                        'Requisitos: ${shield.requiredStats}',
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

  IconData _getShieldIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'escudo pequeño':
        return Icons.shield_outlined;
      case 'escudo mediano':
        return Icons.shield;
      case 'gran escudo':
        return Icons.security;
      default:
        return Icons.shield;
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'escudo pequeño':
        return Colors.green;
      case 'escudo mediano':
        return Colors.blue;
      case 'gran escudo':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _navigateToShieldDetail(Shield shield) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ShieldDetailScreen(
          shield: shield,
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
