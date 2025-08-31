import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream para escuchar cambios en el estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // Registrar usuario con email y contraseña
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    try {
      // Crear usuario en Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Crear documento de usuario en Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Iniciar sesión con email y contraseña
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Actualizar último login
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Restablecer contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Actualizar perfil de usuario
  Future<void> updateUserProfile({
    String? username,
    String? displayName,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Actualizar en Firebase Auth
        if (displayName != null) {
          await user.updateDisplayName(displayName);
        }

        // Actualizar en Firestore
        final updates = <String, dynamic>{};
        if (username != null) updates['username'] = username;
        if (displayName != null) updates['displayName'] = displayName;

        if (updates.isNotEmpty) {
          await _firestore.collection('users').doc(user.uid).update(updates);
        }
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Obtener datos del usuario desde Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Manejar errores de autenticación
  String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'weak-password':
          return 'La contraseña es demasiado débil.';
        case 'email-already-in-use':
          return 'Este email ya está registrado.';
        case 'user-not-found':
          return 'No se encontró un usuario con este email.';
        case 'wrong-password':
          return 'Contraseña incorrecta.';
        case 'invalid-email':
          return 'Email inválido.';
        case 'user-disabled':
          return 'Este usuario ha sido deshabilitado.';
        case 'too-many-requests':
          return 'Demasiados intentos fallidos. Intenta más tarde.';
        case 'operation-not-allowed':
          return 'Esta operación no está permitida.';
        default:
          return 'Error de autenticación: ${error.message}';
      }
    }
    return 'Error inesperado: $error';
  }
}
