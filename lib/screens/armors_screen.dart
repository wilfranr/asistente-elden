import 'package:flutter/material.dart';
import '../models/armor.dart';
import '../utils/app_theme.dart';
import 'armor_detail_screen.dart';

class ArmorsScreen extends StatefulWidget {
  final List<Armor> armors;

  const ArmorsScreen({
    super.key,
    required this.armors,
  });

  @override
  State<ArmorsScreen> createState() => _ArmorsScreenState();
}

class _ArmorsScreenState extends State<ArmorsScreen> {
  List<Armor> _filteredArmors = [];
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _filteredArmors = widget.armors;
  }

  void _filterArmors() {
    setState(() {
      _filteredArmors = widget.armors.where((armor) {
        bool matchesSearch = armor.name.toLowerCase().contains(_searchQuery.toLowerCase());
        bool matchesCategory = _selectedCategory == null || armor.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();

      // Ordenar por peso descendente
      _filteredArmors.sort((a, b) => b.weight.compareTo(a.weight));
    });
  }

  Set<String> get _availableCategories {
    return widget.armors.map((armor) => armor.category ?? 'Sin categoría').toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de búsqueda y filtros
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Barra de búsqueda
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar armaduras...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.backgroundColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryColor),
                  ),
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                ),
                style: const TextStyle(color: AppTheme.textColor),
                onChanged: (value) {
                  _searchQuery = value;
                  _filterArmors();
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
                        _filterArmors();
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
                '${_filteredArmors.length} armaduras encontradas',
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
              Text(
                'Ordenado por peso',
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Lista de armaduras
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredArmors.length,
            itemBuilder: (context, index) {
              final armor = _filteredArmors[index];
              return _buildArmorCard(armor);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildArmorCard(Armor armor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToArmorDetail(armor),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícono del armadura por categoría
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getArmorIcon(armor.category),
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
                            armor.name,
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
                            color: _getCategoryColor(armor.category),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            armor.category ?? 'Sin categoría',
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
                        _buildStatChip('🛡️ ${armor.dmgNegation.firstWhere((s) => s.name == 'Phy', orElse: () => ArmorStat(name: 'Phy', amount: 0)).amount}', Colors.blueGrey),
                        const SizedBox(width: 8),
                        _buildStatChip('⚖️ ${armor.weight.toStringAsFixed(1)}', Colors.grey),
                      ],
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

  IconData _getArmorIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'helm':
        return Icons.helmet;
      case 'chest armor':
        return Icons.security;
      case 'gauntlets':
        return Icons.pan_tool;
      case 'leg armor':
        return Icons.do_not_step;
      default:
        return Icons.shield;
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'helm':
        return Colors.blue;
      case 'chest armor':
        return Colors.orange;
      case 'gauntlets':
        return Colors.green;
      case 'leg armor':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _navigateToArmorDetail(Armor armor) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ArmorDetailScreen(
          armor: armor,
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
