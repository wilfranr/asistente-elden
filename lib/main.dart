import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'utils/app_theme.dart';
import 'screens/auth/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase (comentado temporalmente)
  // await Firebase.initializeApp();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elden Ring Companion',
      theme: AppTheme.darkTheme,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
