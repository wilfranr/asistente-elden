import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const String _storageKey = 'eldenRingProgress';
  
  static Future<void> saveProgress(String itemId, bool isCompleted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_storageKey:$itemId', isCompleted);
  }
  
  static Future<bool> getProgress(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_storageKey:$itemId') ?? false;
  }
  
  static Future<Map<String, bool>> getAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final progress = <String, bool>{};
    
    for (final key in keys) {
      if (key.startsWith('$_storageKey:')) {
        final itemId = key.substring(_storageKey.length + 1);
        progress[itemId] = prefs.getBool(key) ?? false;
      }
    }
    
    return progress;
  }
  
  static Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    for (final key in keys) {
      if (key.startsWith('$_storageKey:')) {
        await prefs.remove(key);
      }
    }
  }
  
  static Future<double> calculateProgress(List<String> itemIds) async {
    if (itemIds.isEmpty) return 100.0;
    
    final progress = await getAllProgress();
    int completedCount = 0;
    
    for (final itemId in itemIds) {
      if (progress[itemId] == true) {
        completedCount++;
      }
    }
    
    return (completedCount / itemIds.length) * 100;
  }
}
