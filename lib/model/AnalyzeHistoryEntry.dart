class AnalyzeHistoryEntry {
  final String id; // UUID
  final String filename;
  final String? frameThumbPath;
  final String? croppedFacePath;
  final String result; // "FAKE"/"REAL"
  final double confidence;
  final DateTime analyzedAt;
  final Map<String, dynamic> meta;

  AnalyzeHistoryEntry({
    required this.id,
    required this.filename,
    this.frameThumbPath,
    this.croppedFacePath,
    required this.result,
    required this.confidence,
    required this.analyzedAt,
    required this.meta,
  });

  factory AnalyzeHistoryEntry.fromJson(Map<String, dynamic> json) => AnalyzeHistoryEntry(
    id: json['id'],
    filename: json['filename'],
    frameThumbPath: json['frameThumbPath'],
    croppedFacePath: json['croppedFacePath'],
    result: json['result'],
    confidence: json['confidence']?.toDouble() ?? 0.0,
    analyzedAt: DateTime.parse(json['analyzedAt']),
    meta: json['meta'] ?? {},
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "filename": filename,
    "frameThumbPath": frameThumbPath,
    "croppedFacePath": croppedFacePath,
    "result": result,
    "confidence": confidence,
    "analyzedAt": analyzedAt.toIso8601String(),
    "meta": meta,
  };
}
