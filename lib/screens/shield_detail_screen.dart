import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/shield.dart';
import '../utils/app_theme.dart';

class ShieldDetailScreen extends StatelessWidget {
  final Shield shield;

  const ShieldDetailScreen({
    super.key,
    required this.shield,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          shield.name,
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
            // Imagen del escudo
            if (shield.image != null) ...[
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: shield.image!,
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
                    shield.name,
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
                    color: _getCategoryColor(shield.category),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    shield.category ?? 'Sin categoría',
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
            if (shield.description != null) ...[
              Text(
                shield.description!,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Stats de ataque
            _buildStatsSection(
              'Poder de Ataque',
              shield.attack,
              Icons.whatshot,
              Colors.red,
            ),
            const SizedBox(height: 20),

            // Stats de defensa
            _buildStatsSection(
              'Defensa/Resistencia',
              shield.defence,
              Icons.shield,
              Colors.blue,
            ),
            const SizedBox(height: 20),

            // Escalado de atributos
            _buildScalingSection(),
            const SizedBox(height: 20),

            // Requisitos
            _buildRequirementsSection(),
            const SizedBox(height: 20),

            // Información adicional
            if (shield.weight != null) ...[
              _buildInfoSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(String title, List<ShieldStat> stats, IconData icon, Color color) {
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

  Widget _buildStatRow(ShieldStat stat, Color color) {
    final String displayName = _getStatDisplayName(stat.name);
    final double percentage = (stat.amount as num).toDouble() / 150.0; // Normalizamos a 150 como máximo típico

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
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

  Widget _buildScalingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.trending_up, color: AppTheme.primaryColor, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Escalado de Atributos',
              style: TextStyle(
                color: AppTheme.primaryColor,
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
          child: shield.scalesWith.isNotEmpty
              ? Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: shield.scalesWith.map((scaling) => _buildScalingChip(scaling)).toList(),
                )
              : const Center(
                  child: Text(
                    'Sin escalado de atributos',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildScalingChip(ShieldScaling scaling) {
    final Color color = _getScalingColor(scaling.scaling);
    final String displayName = _getStatDisplayName(scaling.name);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            displayName,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              scaling.scaling,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.assignment, color: Colors.orange, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Requisitos de Atributos',
              style: TextStyle(
                color: Colors.orange,
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
          child: shield.requiredAttributes.isNotEmpty
              ? Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: shield.requiredAttributes
                      .where((req) => req.amount > 0)
                      .map((req) => _buildRequirementChip(req))
                      .toList(),
                )
              : const Center(
                  child: Text(
                    'Sin requisitos especiales',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildRequirementChip(ShieldStat requirement) {
    final String displayName = _getStatDisplayName(requirement.name);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: Text(
        '$displayName: ${requirement.amount}',
        style: const TextStyle(
          color: Colors.orange,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
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
                '${shield.weight!.toStringAsFixed(1)} unidades',
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
      case 'mag': return 'Mágico';
      case 'fire': return 'Fuego';
      case 'ligt': return 'Rayo';
      case 'holy': return 'Sagrado';
      case 'crit': return 'Crítico';
      case 'boost': return 'Boost';
      case 'str': return 'Fuerza';
      case 'dex': return 'Destreza';
      case 'int': return 'Inteligencia';
      case 'fai': return 'Fe';
      case 'arc': return 'Arcano';
      default: return stat;
    }
  }

  Color _getScalingColor(String scaling) {
    switch (scaling.toUpperCase()) {
      case 'S': return const Color(0xFFFF6B00); // Naranja brillante
      case 'A': return const Color(0xFF4CAF50); // Verde
      case 'B': return const Color(0xFF2196F3); // Azul
      case 'C': return const Color(0xFFFF9800); // Naranja
      case 'D': return const Color(0xFF9E9E9E); // Gris
      case 'E': return const Color(0xFF616161); // Gris oscuro
      default: return Colors.grey;
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
}
