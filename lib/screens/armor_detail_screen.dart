import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/armor.dart';
import '../utils/app_theme.dart';

class ArmorDetailScreen extends StatelessWidget {
  final Armor armor;

  const ArmorDetailScreen({
    super.key,
    required this.armor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          armor.name,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la armadura
            if (armor.image != null) ...[
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: armor.image!,
                    height: 200,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.error,
                          color: AppTheme.textSecondaryColor,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Nombre y categoría
            Row(
              children: [
                Expanded(
                  child: Text(
                    armor.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(armor.category),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    armor.category ?? 'Sin categoría',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Descripción
            if (armor.description != null) ...[
              Text(
                armor.description!,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Stats de negación de daño
            _buildStatsSection(
              'Negación de Daño',
              armor.dmgNegation,
              Icons.shield,
              Colors.blue,
            ),
            const SizedBox(height: 20),

            // Stats de resistencia
            _buildStatsSection(
              'Resistencia',
              armor.resistance,
              Icons.health_and_safety,
              Colors.green,
            ),
            const SizedBox(height: 20),

            // Información adicional
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(String title, List<ArmorStat> stats, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.backgroundColor),
          ),
          child: Column(
            children: stats.map((stat) => _buildStatRow(stat, color)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(ArmorStat stat, Color color) {
    final String displayName = _getStatDisplayName(stat.name);
    final double percentage = stat.amount / 100.0; // Normalizamos a 100 como máximo típico

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              displayName,
              style: const TextStyle(
                color: AppTheme.textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage.clamp(0.0, 1.0),
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Text(
                      '${stat.amount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info, color: Colors.grey, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Información Adicional',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.backgroundColor),
          ),
          child: Row(
            children: [
              Icon(Icons.fitness_center, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Peso:',
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${armor.weight.toStringAsFixed(1)} unidades',
                style: const TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStatDisplayName(String stat) {
    switch (stat.toLowerCase()) {
      case 'phy': return 'Físico';
      case 'strike': return 'Golpe';
      case 'slash': return 'Corte';
      case 'pierce': return 'Perforación';
      case 'magic': return 'Mágico';
      case 'fire': return 'Fuego';
      case 'ligt': return 'Rayo';
      case 'holy': return 'Sagrado';
      case 'immunity': return 'Inmunidad';
      case 'robustness': return 'Robustez';
      case 'focus': return 'Enfoque';
      case 'vitality': return 'Vitalidad';
      case 'poise': return 'Equilibrio';
      default: return stat;
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
}
