import 'package:flutter/material.dart';
import '../models/weapon.dart';
import '../models/shield.dart';
import '../utils/app_theme.dart';
import 'weapons_screen.dart';
import 'shields_screen.dart';

class ArsenalScreen extends StatefulWidget {
  final List<Weapon> weapons;
  final List<Shield> shields;

  const ArsenalScreen({
    super.key,
    required this.weapons,
    required this.shields,
  });

  @override
  State<ArsenalScreen> createState() => _ArsenalScreenState();
}

class _ArsenalScreenState extends State<ArsenalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Arsenal',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondaryColor,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(icon: Icon(Icons.construction), text: 'Armas'),
            Tab(icon: Icon(Icons.shield), text: 'Escudos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          WeaponsScreen(weapons: widget.weapons),
          ShieldsScreen(shields: widget.shields),
        ],
      ),
    );
  }
}
