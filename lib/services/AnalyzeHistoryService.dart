import 'package:hive/hive.dart';
import '../model/AnalyzeHistoryEntry.dart';

class AnalyzeHistoryService {
  static final AnalyzeHistoryService _instance = AnalyzeHistoryService._internal();
  factory AnalyzeHistoryService() => _instance;
  AnalyzeHistoryService._internal();

  Box<dynamic>? _box;

  Future<void> init() async {
    if (_box != null && _box!.isOpen) return;
    _box = await Hive.openBox('analyzeHistory');
  }

  Future<void> addEntry(AnalyzeHistoryEntry entry) async {
    if (_box == null || !_box!.isOpen) return;
    print("[HIVE] Entry added: ${entry.toJson()}");
    await _box!.put(entry.id, entry.toJson());
  }

  List<AnalyzeHistoryEntry> getAllEntries() {
    if (_box == null || !_box!.isOpen) return [];
    return _box!.values
        .map((e) => AnalyzeHistoryEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  AnalyzeHistoryEntry? getEntry(String id) {
    if (_box == null || !_box!.isOpen) return null;
    final json = _box!.get(id);
    if (json == null) return null;
    return AnalyzeHistoryEntry.fromJson(Map<String, dynamic>.from(json));
  }

  Box<dynamic>? get box => _box;
}
