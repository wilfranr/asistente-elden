import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener progreso del usuario desde Firestore
  Future<Map<String, bool>> getUserProgress() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('progress')
          .doc('elden_ring')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final progress = <String, bool>{};
        
        data.forEach((key, value) {
          if (value is bool) {
            progress[key] = value;
          }
        });
        
        return progress;
      }
      
      return {};
    } catch (e) {
      print('Error obteniendo progreso: $e');
      return {};
    }
  }

  // Guardar progreso del usuario en Firestore
  Future<void> saveUserProgress(Map<String, bool> progress) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('progress')
          .doc('elden_ring')
          .set(progress);
    } catch (e) {
      print('Error guardando progreso: $e');
    }
  }

  // Sincronizar progreso local con Firestore
  Future<void> syncProgress(Map<String, bool> localProgress) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Obtener progreso remoto
      final remoteProgress = await getUserProgress();
      
      // Combinar progreso local y remoto (el más reciente gana)
      final mergedProgress = <String, bool>{};
      
      // Agregar todo el progreso local
      mergedProgress.addAll(localProgress);
      
      // Agregar progreso remoto que no esté en local
      remoteProgress.forEach((key, value) {
        if (!mergedProgress.containsKey(key)) {
          mergedProgress[key] = value;
        }
      });
      
      // Guardar progreso combinado
      await saveUserProgress(mergedProgress);
    } catch (e) {
      print('Error sincronizando progreso: $e');
    }
  }

  // Obtener estadísticas del usuario
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final progress = await getUserProgress();
      final completedCount = progress.values.where((value) => value).length;
      final totalCount = progress.length;
      
      return {
        'completedItems': completedCount,
        'totalItems': totalCount,
        'completionPercentage': totalCount > 0 ? (completedCount / totalCount) * 100 : 0,
        'lastSync': FieldValue.serverTimestamp(),
      };
    } catch (e) {
      print('Error obteniendo estadísticas: $e');
      return {};
    }
  }

  // Actualizar estadísticas del usuario
  Future<void> updateUserStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final stats = await getUserStats();
      
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('elden_ring')
          .set(stats);
    } catch (e) {
      print('Error actualizando estadísticas: $e');
    }
  }
}
