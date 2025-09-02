import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/boss.dart';
import '../utils/app_theme.dart';
import '../widgets/aurora_background.dart';
import '../widgets/glass_container.dart';

class BossDetailScreen extends StatelessWidget {
  final Boss boss;

  const BossDetailScreen({
    super.key,
    required this.boss,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          boss.name,
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
      body: Stack(
        children: [
          const AuroraBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen del jefe
                if (boss.image != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: boss.image!,
                      placeholder: (context, url) => Container(
                        height: 225,
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
                        height: 225,
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
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Nombre del jefe
                Text(
                  boss.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Descripción
                if (boss.description != null) ...[
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      boss.description!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textColor,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Información detallada en grid expandido
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildInfoCard(
                      'Ubicación',
                      boss.location ?? 'Desconocida',
                      Icons.location_on,
                      AppTheme.primaryColor,
                    ),
                    _buildInfoCard(
                      'Región',
                      boss.region ?? 'No especificada',
                      Icons.map,
                      Colors.blue,
                    ),
                    _buildInfoCard(
                      'Puntos de Vida',
                      boss.healthPoints ?? 'No disponible',
                      Icons.favorite,
                      Colors.red,
                    ),
                    _buildInfoCard(
                      'Runas Obtenidas',
                      boss.runes != null ? _formatNumber(boss.runes!) : _extractRunesFromDrops(),
                      Icons.monetization_on,
                      AppTheme.primaryColor,
                    ),
                    _buildInfoCard(
                      'Recompensa Principal',
                      _getMainReward(),
                      Icons.inventory,
                      Colors.green,
                    ),
                    _buildInfoCard(
                      'Item Especial',
                      _getBestUniqueItem(),
                      Icons.star,
                      Colors.purple,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Tipo de jefe
                if (boss.type != null) ...[
                  _buildTypeSection(boss.type!),
                  const SizedBox(height: 16),
                ],

                // Debilidades
                if (boss.weaknesses != null && boss.weaknesses!.isNotEmpty) ...[
                  _buildListSection('Debilidades', boss.weaknesses!, Colors.green),
                  const SizedBox(height: 16),
                ],

                // Fortalezas
                if (boss.strengths != null && boss.strengths!.isNotEmpty) ...[
                  _buildListSection('Fortalezas', boss.strengths!, Colors.red),
                  const SizedBox(height: 16),
                ],

                // Inmunidades
                if (boss.immunities != null && boss.immunities!.isNotEmpty) ...[
                  _buildListSection('Inmunidades', boss.immunities!, Colors.orange),
                  const SizedBox(height: 16),
                ],

                // Recompensas detalladas
                if (boss.drops != null && boss.drops!.isNotEmpty) ...[
                  _buildDropsSection(boss.drops!),
                  const SizedBox(height: 16),
                ],

                // Recomendaciones
                if (boss.recommendations != null && boss.recommendations!.isNotEmpty) ...[
                  _buildRecommendationsSection(boss.recommendations!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSection(String type) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.sports_esports, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Tipo de Jefe: ',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              type,
              style: const TextStyle(
                color: AppTheme.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              color == Colors.green ? Icons.thumb_up : 
              color == Colors.red ? Icons.thumb_down : Icons.shield,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: color,
                    size: 8,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDropsSection(List<String> drops) {
    // Separar runas de otros items
    List<String> runas = [];
    List<String> items = [];
    
    for (final drop in drops) {
      if (drop.toLowerCase().contains('runas')) {
        runas.add(drop);
      } else {
        items.add(drop);
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.inventory, color: Colors.amber, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Recompensas Completas',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Sección de Runas
        if (runas.isNotEmpty) ...[
          GlassContainer(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryColor.withOpacity(0.1),
            border: Border.all(color: AppTheme.primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.monetization_on, color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Runas',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...runas.map((runa) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    runa,
                    style: const TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )).toList(),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Sección de Items
        if (items.isNotEmpty) ...[
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Items y Equipamiento (${items.length})',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...items.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(
                            color: AppTheme.textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRecommendationsSection(List<String> recommendations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Recomendaciones Estratégicas',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: recommendations.map((recommendation) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.tips_and_updates, color: AppTheme.primaryColor, size: 16),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: const TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  String _extractRunesFromDrops() {
    if (boss.drops == null || boss.drops!.isEmpty) return 'No disponible';
    
    for (final drop in boss.drops!) {
      if (drop.toLowerCase().contains('runas')) {
        // Extraer número de runas del string
        final runeMatch = RegExp(r'(\d+(?:[.,]\d+)*)').firstMatch(drop);
        if (runeMatch != null) {
          String numStr = runeMatch.group(1)!.replaceAll('.', '').replaceAll(',', '');
          final runeValue = int.tryParse(numStr);
          if (runeValue != null) {
            return _formatNumber(runeValue);
          }
        }
        return drop; // Retornar el string original si no se puede parsear
      }
    }
    return 'No disponible';
  }

  String _getMainReward() {
    if (boss.drops == null || boss.drops!.isEmpty) return 'No disponible';
    
    // Buscar la primera recompensa que no sea runas
    for (final drop in boss.drops!) {
      if (!drop.toLowerCase().contains('runas')) {
        // Truncar si es muy largo
        if (drop.length > 16) {
          return '${drop.substring(0, 13)}...';
        }
        return drop;
      }
    }
    
    // Si solo hay runas, mostrar la cantidad
    for (final drop in boss.drops!) {
      if (drop.toLowerCase().contains('runas')) {
        return drop;
      }
    }
    
    return 'No disponible';
  }

  String _getBestUniqueItem() {
    if (boss.drops == null || boss.drops!.isEmpty) return 'Ninguno';
    
    List<String> uniqueItems = [];
    for (final drop in boss.drops!) {
      if (!drop.toLowerCase().contains('runas')) {
        uniqueItems.add(drop);
      }
    }
    
    if (uniqueItems.isEmpty) return 'Solo runas';
    if (uniqueItems.length == 1) {
      // Truncar si es muy largo
      String item = uniqueItems.first;
      if (item.length > 16) {
        return '${item.substring(0, 13)}...';
      }
      return item;
    }
    
    // Si hay múltiples, buscar items especiales (talismanes, armas únicas, etc.)
    for (final item in uniqueItems) {
      String lowerItem = item.toLowerCase();
      if (lowerItem.contains('talismán') || 
          lowerItem.contains('talisman') ||
          lowerItem.contains('bolsa') ||
          lowerItem.contains('cenizas') ||
          lowerItem.contains('escudo') ||
          lowerItem.contains('espada')) {
        if (item.length > 16) {
          return '${item.substring(0, 13)}...';
        }
        return item;
      }
    }
    
    // Si no hay items especiales, mostrar el primero
    String item = uniqueItems.first;
    if (item.length > 20) {
      return '${item.substring(0, 17)}...';
    }
    return item;
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}