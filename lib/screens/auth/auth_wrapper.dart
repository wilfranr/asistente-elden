import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../../services/auth_service.dart';
import '../main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Temporalmente, mostrar directamente la aplicación principal
    // para probar la carga de datos JSON
    return const MainScreen();
    
    // Código original comentado temporalmente:
    // return StreamBuilder<User?>(
    //   stream: AuthService().authStateChanges,
    //   builder: (context, snapshot) {
    //     // Si está cargando, mostrar pantalla de carga
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const Scaffold(
    //         backgroundColor: Color(0xFF111827),
    //         body: Center(
    //           child: CircularProgressIndicator(
    //             color: Color(0xFFF59E0B),
    //           ),
    //         ),
    //       );
    //     }
    //
    //     // Si hay un usuario autenticado, mostrar la aplicación principal
    //     if (snapshot.hasData && snapshot.data != null) {
    //       return const MainScreen();
    //     }
    //
    //     // Si no hay usuario autenticado, mostrar pantalla de login
    //     return const LoginScreen();
    //   },
    // );
  }
}
