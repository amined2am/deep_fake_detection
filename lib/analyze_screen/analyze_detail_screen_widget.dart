import 'dart:io';

import 'package:flutter/material.dart';
import '../model/AnalyzeHistoryEntry.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '../home_screen/home_screen_widget.dart';
import '../statistic_screen/statistic_screen_widget.dart';
import '../profile_screen/profile_screen_widget.dart';
import '../history_screen/history_screen_widget.dart';
import 'analyze_screen_widget.dart';

class AnalyzeDetailScreenWidget extends StatelessWidget {
  final AnalyzeHistoryEntry entry;

  const AnalyzeDetailScreenWidget({required this.entry, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final frames = entry.meta['frames_for_display'] ?? [];
    final croppedFaces = entry.meta['cropped_faces'] ?? [];
    final metadata = entry.meta['metadata'] ?? entry.meta;

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: "Deepfake ",
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
            children: [
              TextSpan(
                text: "Details",
                style: TextStyle(fontWeight: FontWeight.normal, color: Colors.grey[900]),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7E6FF), Color(0xFFF7F9FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Résultat principal SANS image
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 14, offset: Offset(0, 6))],
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.result,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: entry.result == "REAL" ? Colors.green[700] : Colors.red[700],
                          fontSize: 22,
                        ),
                      ),
                      Text(
                        "Confidence: ${entry.confidence.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: entry.result == "REAL" ? Colors.green[800] : Colors.red[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "File: ${entry.filename}",
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Analyzed: ${DateFormat('dd/MM/yyyy HH:mm').format(entry.analyzedAt)}",
                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // FRAMES SPLIT (depuis meta)
                if (frames.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/images/frame.png', height: 22),
                          SizedBox(width: 7),
                          Text("Frames", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 115,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: frames.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 7),
                          itemBuilder: (context, idx) {
                            final frameObj = frames[idx];
                            final url = frameObj['url'];
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                url != null
                                    ? GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: InteractiveViewer(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.network(
                                              url,
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error, stack) => Container(
                                                color: Colors.grey[300],
                                                width: 350,
                                                height: 350,
                                                child: Icon(Icons.broken_image, size: 80, color: Colors.grey[700]),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      url,
                                      width: 95,
                                      height: 75,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => Container(
                                        width: 95, height: 75, color: Colors.grey[300],
                                        child: const Icon(Icons.broken_image, size: 40),
                                      ),
                                    ),
                                  ),
                                )
                                    : Container(
                                  width: 95,
                                  height: 75,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image),
                                ),
                                Text(
                                  "${frameObj['label'] ?? ''} - ${frameObj['confidence']?.toStringAsFixed(1) ?? ''}%",
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),

                // CROPPED FACES
                if (croppedFaces.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.face_retouching_natural, color: Colors.deepPurple[400], size: 22),
                          SizedBox(width: 7),
                          Text("Detected Faces", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: croppedFaces.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 7),
                          itemBuilder: (context, idx) {
                            final cropped = croppedFaces[idx];
                            final url = cropped['url'];
                            return url != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: Image.network(
                                url,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => Container(
                                  width: 90, height: 90, color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image, size: 30),
                                ),
                              ),
                            )
                                : Container(
                              width: 90,
                              height: 90,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),

                // Bloc MétaData
                if (metadata != null && metadata.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5FAFF),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueGrey.withOpacity(0.09),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue[400], size: 18),
                                SizedBox(width: 7),
                                Text(
                                  "Metadata",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15.5,
                                    color: Colors.blue[900],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ...metadata.entries.map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 2.5),
                              child: Text("${e.key}: ${e.value}", style: const TextStyle(fontSize: 13.4)),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
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
