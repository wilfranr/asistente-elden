import 'package:flutter/material.dart';
import '../models/boss.dart';
import '../models/weapon.dart';
import '../models/item.dart';
import '../models/zone.dart';
import '../models/mission.dart';
import '../services/data_service.dart';
import '../utils/app_theme.dart';
import 'zones_screen.dart';
import 'loading_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isLoading = true;
  String _loadingMessage = 'Inicializando...';
  Map<String, dynamic>? _gameData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGameData();
  }

  Future<void> _loadGameData() async {
    try {
      setState(() {
        _loadingMessage = 'Cargando datos del juego...';
      });

      final gameData = await DataService.loadGameData();
      
      // Verificar que los datos se cargaron correctamente
      if (gameData['bosses'] == null || gameData['zones'] == null) {
        throw Exception('Error en la estructura de datos cargados');
      }

      setState(() {
        _gameData = gameData;
        _isLoading = false;
      });

      // Mostrar información de carga exitosa
      if (mounted) {
        final bossCount = (gameData['bosses'] as List).length;
        final zoneCount = (gameData['zones'] as Map).length;
        final weaponCount = (gameData['weapons'] as List).length;
        final itemCount = (gameData['items'] as List).length;
        
        print('✅ Datos cargados exitosamente:');
        print('   🗡️ Jefes: $bossCount');
        print('   🗺️ Zonas: $zoneCount');
        print('   ⚔️ Armas: $weaponCount');
        print('   📦 Objetos: $itemCount');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los datos: $e';
        _isLoading = false;
      });
      print('❌ Error cargando datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return LoadingScreen();
    }

    if (_errorMessage != null) {
      return _buildErrorScreen();
    }

    if (_gameData == null) {
      return _buildErrorScreen();
    }

    return ZonesScreen(
      zones: _gameData!['zones'] as Map<String, Zone>,
      bosses: _gameData!['bosses'] as List<Boss>, // Ahora incluye todos los jefes
      prologoBosses: _gameData!['prologoBosses'] as List<Boss>,
      weapons: _gameData!['weapons'] as List<Weapon>,
      items: _gameData!['items'] as List<Item>,
      missions: _gameData!['missions'] ?? <Mission>[],
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: AppTheme.veryHardColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Error al cargar la aplicación',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Ocurrió un error inesperado',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadGameData();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
