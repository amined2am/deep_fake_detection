import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../analyze_screen/analyze_detail_screen_widget.dart';
import '../model/AnalyzeHistoryEntry.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'history_screen_model.dart';

class HistoryScreenWidget extends StatefulWidget {
  const HistoryScreenWidget({super.key});

  static String routeName = 'HistoryScreen';
  static String routePath = '/historyScreen';

  @override
  State<HistoryScreenWidget> createState() => _HistoryScreenWidgetState();
}

class _HistoryScreenWidgetState extends State<HistoryScreenWidget> {
  Future<void> _deleteEntryFromFirestore(AnalyzeHistoryEntry entry) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("[ERROR] No user logged in.");
      return;
    }

    final query = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .where('id', isEqualTo: entry.id)
        .get();

    for (var doc in query.docs) {
      await doc.reference.delete();
      print('[FIRESTORE] Deleted entry with ID: ${entry.id}');
    }
  }

  Future<void> _shareEntry(AnalyzeHistoryEntry entry) async {
    final Map<String, dynamic> metadata = entry.meta['metadata'] ?? {};

    final buffer = StringBuffer();
    buffer.writeln('Deepfake analysis result:');
    buffer.writeln('Result: ${entry.result}');
    buffer.writeln('Confidence: ${entry.confidence.toStringAsFixed(2)}%');
    buffer.writeln('Date: ${DateFormat('dd/MM/yyyy HH:mm').format(entry.analyzedAt)}');
    buffer.writeln('File: ${entry.filename}');
    buffer.writeln('\nMetadata:');
    metadata.forEach((key, value) {
      buffer.writeln('$key: $value');
    });

    // Crée le fichier temporaire .txt
    final tempDir = await getTemporaryDirectory();
    final txtFile = File('${tempDir.path}/deepfake_analysis_${entry.id}.txt');
    await txtFile.writeAsString(buffer.toString());

    // Partage le fichier .txt
    await Share.shareXFiles(
        [XFile(txtFile.path)],
        text: "Deepfake analysis result exported as .txt"
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, AnalyzeHistoryEntry entry) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete analysis?'),
        content: const Text('Are you sure you want to delete this analysis?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context, true);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteEntryFromFirestore(entry);
      // Rien d'autre à faire ! StreamBuilder va actualiser la liste tout seul.
    }
  }

  void _openAnalyzeDetail(BuildContext context, AnalyzeHistoryEntry entry) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalyzeDetailScreenWidget(entry: entry),
      ),
    );
    // Rien à faire ici non plus, le StreamBuilder est auto-refresh.
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: "Deepfake ",
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
            children: [
              TextSpan(
                text: "History",
                style:
                TextStyle(fontWeight: FontWeight.normal, color: Colors.grey[900]),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('history')
            .orderBy('analyzedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No analysis history yet.",
                  style: TextStyle(fontSize: 17, color: Colors.black54)),
            );
          }

          final entries = snapshot.data!.docs
              .map((doc) => AnalyzeHistoryEntry.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
          final total = entries.length;
          final max = 10;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "$total / $max analyses enregistrées",
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: total >= max ? Colors.red[700] : Colors.grey[800],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 7),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final entry = entries[idx];
                    final isReal = entry.result == "REAL";
                    final color = isReal ? Color(0xFF43D188) : Color(0xFFD6336C);

                    return Card(
                      elevation: 2.5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            entry.frameThumbPath != null &&
                                File(entry.frameThumbPath!).existsSync()
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Image.file(
                                File(entry.frameThumbPath!),
                                width: 54,
                                height: 54,
                                fit: BoxFit.cover,
                              ),
                            )
                                : Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Icon(Icons.video_file,
                                  size: 32, color: Colors.grey[500]),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        entry.result,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: color,
                                          fontSize: 16.8,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.13),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          "${entry.confidence.toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    DateFormat('dd/MM/yyyy HH:mm')
                                        .format(entry.analyzedAt),
                                    style: const TextStyle(
                                        fontSize: 13.2, color: Colors.black54),
                                  ),
                                  SizedBox(height: 1),
                                  Row(
                                    children: [
                                      Icon(Icons.insert_drive_file,
                                          color: Colors.grey[500], size: 16),
                                      SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          entry.filename ?? '',
                                          style: const TextStyle(
                                              fontSize: 13.1, color: Colors.black54),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.open_in_new,
                                  color: Colors.deepPurple, size: 26),
                              onPressed: () => _openAnalyzeDetail(context, entry),
                              tooltip: "See analysis details",
                            ),
                            IconButton(
                              icon: const Icon(Icons.share_outlined,
                                  color: Color(0xFF8E44AD), size: 24),
                              onPressed: () => _shareEntry(entry),
                              tooltip: 'Share',
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_forever_rounded,
                                  color: Colors.red[400], size: 26),
                              onPressed: () => _showDeleteConfirmation(context, entry),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      // --- BARRE DE NAVIGATION EN BAS ---
      bottomNavigationBar: Container(
        width: double.infinity,
        height: 80.0,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey[300]!,
              width: 1.0,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => context.pushNamed(HomeScreenWidget.routeName),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home_outlined, color: Colors.grey[700], size: 24.0),
                    SizedBox(height: 4),
                    Text('Home', style: TextStyle(color: Colors.grey[700], fontSize: 10.0)),
                  ],
                ),
              ),
              InkWell(
                onTap: () => context.pushNamed(StatisticScreenWidget.routeName),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart_outlined, color: Colors.grey[700], size: 24.0),
                    SizedBox(height: 4),
                    Text('Statistics', style: TextStyle(color: Colors.grey[700], fontSize: 10.0)),
                  ],
                ),
              ),
              InkWell(
                onTap: () => context.pushNamed(AnalyzeScreenWidget.routeName),
                child: Container(
                  width: 56.0,
                  height: 56.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8E44AD),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3.0,
                    ),
                  ),
                  child: const Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Icon(
                      Icons.psychology_alt_rounded,
                      color: Colors.white,
                      size: 28.0,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => context.pushNamed(HistoryScreenWidget.routeName),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_outlined, color: Colors.grey[700], size: 24.0),
                    SizedBox(height: 4),
                    Text('History', style: TextStyle(color: Colors.grey[700], fontSize: 10.0)),
                  ],
                ),
              ),
              InkWell(
                onTap: () => context.pushNamed(ProfileScreenWidget.routeName),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_outline, color: Colors.grey[700], size: 24.0),
                    SizedBox(height: 4),
                    Text('Profile', style: TextStyle(color: Colors.grey[700], fontSize: 10.0)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
