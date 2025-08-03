import 'dart:io';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_fake_detection/home_screen/home_screen_widget.dart';
import 'package:deep_fake_detection/index.dart';
import 'package:deep_fake_detection/profile_screen/profile_screen_widget.dart';
import 'package:deep_fake_detection/statistic_screen/statistic_screen_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../model/AnalyzeHistoryEntry.dart';
import '../services/AnalyzeHistoryFirestoreService.dart';
import '../services/AnalyzeHistoryService.dart';
import '../utils/VideoUtils.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'analyze_screen_model.dart';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:video_player/video_player.dart';
import 'package:uuid/uuid.dart';
import 'package:chewie/chewie.dart';
export 'analyze_screen_model.dart';


class AnalyzeScreenWidget extends StatefulWidget {
  const AnalyzeScreenWidget({super.key});

  static String routeName = 'AnalyzeScreen';
  static String routePath = '/analyzeScreen';

  @override
  State<AnalyzeScreenWidget> createState() => _AnalyzeScreenWidgetState();


}

class _AnalyzeScreenWidgetState extends State<AnalyzeScreenWidget> {
  late AnalyzeScreenModel _model;
  File? _selectedVideo;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  Map<String, dynamic>? _result;
  bool _isAnalyzing = false;
  String? _analyzeError;
  final scaffoldKey = GlobalKey<ScaffoldState>();



  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AnalyzeScreenModel());
  }

  @override
  void dispose() {
    _model.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.video);
    if (picked != null && picked.files.single.path != null) {
      final file = File(picked.files.single.path!);

      // Libère les anciens controllers
      _videoController?.dispose();
      _chewieController?.dispose();

      // Crée un nouveau controller vidéo
      final controller = VideoPlayerController.file(file);
      await controller.initialize();


      // Crée ChewieController
      final chewie = ChewieController(
        videoPlayerController: controller,
        autoPlay: false,
        looping: false,
        aspectRatio: controller.value.aspectRatio,
      );

      setState(() {
        _selectedVideo = file;
        _videoController = controller;
        _chewieController = chewie;
        _result = null;
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _saveAnalysisToHistory() async {
    final uuid = Uuid().v4();
    final filename = _selectedVideo?.path.split('/').last ?? "unknown";
    String? frameThumbPath;

    try {
      frameThumbPath = await VideoUtils.extractFrameThumbnail(_selectedVideo!.path);
    } catch (e) {
      print('[WARN] Failed to extract thumbnail: $e');
      frameThumbPath = null;
    }

    final result = _result?['result'] ?? "Unknown";
    final confidence = (_result?['confidence'] is num)
        ? (_result?['confidence'] as num).toDouble()
        : 0.0;
    final analyzedAt = DateTime.now();

    // Traite et complète les URLs
    List framesForDisplay = (_result?['frames_for_display'] ?? []).map((frame) {
      if (frame['url'] != null && !frame['url'].toString().startsWith('http')) {
        frame['url'] = 'http://10.0.2.2:8000${frame['url']}';
      }
      return frame;
    }).toList();

    List croppedFaces = (_result?['cropped_faces'] ?? []).map((face) {
      if (face['url'] != null && !face['url'].toString().startsWith('http')) {
        face['url'] = 'http://10.0.2.2:8000${face['url']}';
      }
      return face;
    }).toList();

    final Map<String, dynamic> meta = {};
    meta['metadata'] = _result?['metadata'] ?? {};
    meta['frames_for_display'] = framesForDisplay;
    meta['cropped_faces'] = croppedFaces;

    final entry = AnalyzeHistoryEntry(
      id: uuid,
      filename: filename,
      frameThumbPath: frameThumbPath,
      result: result,
      confidence: confidence,
      analyzedAt: analyzedAt,
      meta: meta,
    );

    await AnalyzeHistoryService().addEntry(entry);

    try {
      await AnalyzeHistoryFirestoreService().saveEntry(entry);
    } catch (e) {
      print('[ERROR] Failed to save entry to Firestore: $e');
    }
  }






  Future<void> _exportCsvForSplitFrames() async {
    if (_selectedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No video to export.")),
      );
      return;
    }
    var uri = Uri.parse('http://10.0.2.2:8000/predict_csv/'); // Adapter si besoin
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', _selectedVideo!.path));
    var response = await request.send();
    var responseString = await response.stream.bytesToString();
    final decoded = jsonDecode(responseString);

    if (decoded['frames_csv'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("CSV export failed: no frames_csv.")),
      );
      return;
    }
    List framesCsv = decoded['frames_csv'];
    List<List<String>> csvData = [
      ['frame_index', 'confidence', 'label'],
      ...framesCsv.map<List<String>>((frame) => [
        frame['frame_index'].toString(),
        frame['confidence']?.toString() ?? '',
        frame['label'] ?? '',
      ])
    ];
    String csv = const ListToCsvConverter().convert(csvData);

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/split_frames.csv');
    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(file.path)], text: "Split frames export");
  }
  Widget _buildMetadataWidget(dynamic metadata) {
    if (metadata == null) return Text("No metadata extracted.");

    Widget _metaLine(String label, dynamic value, {bool bold = false}) {
      if (value == null || value.toString().trim().isEmpty) return SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Text(
          "$label: $value",
          style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _metaLine("Duration",
            metadata["duration"] != null
                ? "${double.tryParse(metadata["duration"].toString())?.toStringAsFixed(1) ?? metadata["duration"]} sec"
                : null),
        _metaLine("Resolution",
            metadata["width"] != null && metadata["height"] != null
                ? "${metadata["width"]} x ${metadata["height"]}"
                : null,
            bold: true),
        _metaLine("Video Codec", metadata["video_codec"]),
        _metaLine("File Size",
            metadata["file_size"] != null ? "${metadata["file_size"]} bytes" : null),
        _metaLine("Format", metadata["format"]),
        _metaLine("Created", metadata["creation_time"]),
        _metaLine("Bitrate", metadata["bit_rate"]),
        _metaLine("Location", metadata["location"]),
        _metaLine("Created", metadata["creation_time"]),
        _metaLine("Device", metadata["device_type"]),
        _metaLine("Model", metadata["device_model"]),
        _metaLine("Software", metadata["device_software"]),
        _metaLine("Device Type", metadata["device_type"]),
        _metaLine("Device Make", metadata["device_make"]),
        _metaLine("Device Model", metadata["device_model"]),
        _metaLine("Device Software", metadata["device_software"]),
        _metaLine("Encoder", metadata["encoder"]),
        // etc
      ],
    );
  }



  Future<void> showErrorDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Error', style: TextStyle(color: Colors.red)),
            ],
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _analyze() async {
    if (_selectedVideo == null) {
      await showErrorDialog(context, "Please select a video first!");
      setState(() {
        _analyzeError = null;
        _result = null;
      });
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .get();

      if (snapshot.docs.length >= 10) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Center(
              child: Text(
                "Limit reached",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            content: const Text(
              "You have already saved 10 analyses.\n\nPlease delete one to analyze a new video.",
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return;
      }
    }
    setState(() {
      _isAnalyzing = true;
      _analyzeError = null;
      _result = null;
    });

    var uri = Uri.parse('http://10.0.2.2:8000/predict/'); // Adapter selon config réseau
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', _selectedVideo!.path));
    var response = await request.send();
    var responseString = await response.stream.bytesToString();
    print("API RESPONSE: $responseString");
    final decoded = jsonDecode(responseString);

    setState(() {
      _result = decoded;
      _isAnalyzing = false;
    });
    await _saveAnalysisToHistory();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: "Deepfake ",
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
            children: [
              TextSpan(
                text: "Detection",
                style: TextStyle(fontWeight: FontWeight.normal, color: Colors.grey[900]),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Container(
        decoration: BoxDecoration(
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
                // 1. Bloc vidéo sélectionnée
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 6))],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        if (_selectedVideo != null && _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized)
                          AspectRatio(
                            aspectRatio: _chewieController!.videoPlayerController.value.aspectRatio,
                            child: Chewie(controller: _chewieController!),
                          )
                        else
                          Container(
                            height: 200,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/images/analyze.png', height: 70), // <-- Mets ton png ici
                                SizedBox(height: 15),
                                Text("Choose a video to start the analysis", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                              ],
                            ),
                          ),
                        const SizedBox(height: 10),

                        // Progress bar pendant l'analyse
                        if (_isAnalyzing) ...[
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 28,
                                width: 28,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8E44AD)),
                                  strokeWidth: 3.2,
                                ),
                              ),
                              SizedBox(width: 16),
                              Text(
                                "Analysis in progress...",
                                style: TextStyle(
                                  color: Color(0xFF8E44AD),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                        ],

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickVideo,
                              icon: Icon(Icons.video_library),
                              label: Text("Choose a video"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
                                textStyle: TextStyle(fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                                elevation: 0,
                              ),
                            ),
                            const SizedBox(width: 18),
                            ElevatedButton.icon(
                              onPressed: _isAnalyzing || _selectedVideo == null ? null : _analyze,
                              icon: Icon(Icons.psychology_outlined),
                              label: _isAnalyzing ? Text("Analyzing...") : Text("Analyze"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8E44AD),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 24),
                                textStyle: TextStyle(fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                                elevation: 2,
                                disabledBackgroundColor: Colors.grey[300],
                                disabledForegroundColor: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // 2. FRAMES SPLIT
                if (_result != null && _result!['frames_for_display'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/images/frame.png', height: 24),
                          SizedBox(width: 7),
                          Text("Frames Split", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                        ],
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        height: 135,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _result!['frames_for_display'].length,
                          itemBuilder: (context, idx) {
                            final frameObj = _result!['frames_for_display'][idx];
                            final frameUrl = "http://10.0.2.2:8000${frameObj['url']}";
                            final frameIndex = frameObj['frame_index'];
                            final confidence = frameObj['confidence'];
                            final label = frameObj['label'];
                            final frameTime = frameObj['frame_time_sec'];
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: InteractiveViewer(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.network(
                                              frameUrl,
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
                                      frameUrl,
                                      width: 100,
                                      height: 85,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) => Container(
                                        width: 100,
                                        height: 85,
                                        color: Colors.grey[300],
                                        child: Icon(Icons.broken_image, color: Colors.grey[700]),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "Frame $frameIndex — $label",
                                  style: TextStyle(fontSize: 12, color: Colors.grey[800], fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  frameTime != null ? "Time: ${frameTime.toStringAsFixed(2)} s" : "",
                                  style: TextStyle(fontSize: 11, color: Colors.grey[700], fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "Conf: ${confidence != null ? confidence.toStringAsFixed(2) : '?'}%",
                                  style: TextStyle(fontSize: 11, color: Colors.deepPurple[700], fontWeight: FontWeight.w600),
                                ),
                              ],
                            );
                          },
                          separatorBuilder: (_, __) => SizedBox(width: 8),
                        ),
                      ),
                    ],
                  ),

                // 3. CROPPED FACES
                if (_result != null && _result!['cropped_faces'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Image.asset('assets/images/crop.png', height: 24),
                          SizedBox(width: 7),
                          Text("Face Cropped Frames", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                        ],
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _result!['cropped_faces'].length,
                          itemBuilder: (context, idx) {
                            final cropped = _result!['cropped_faces'][idx];
                            final croppedUrl = "http://10.0.2.2:8000${cropped['url']}";
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                croppedUrl,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) => Container(
                                  width: 90,
                                  height: 90,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.broken_image, color: Colors.grey[700]),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (_, __) => SizedBox(width: 7),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.download),
                          label: Text("Export CSV"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: _exportCsvForSplitFrames,
                        ),
                      ),
                    ],
                  ),

                // 4. Bloc MetaData
                if (_result != null && _result!['metadata'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0, bottom: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFF5FAFF), // fond bleu très pâle
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueGrey.withOpacity(0.09),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue[400], size: 19),
                                SizedBox(width: 8),
                                Text(
                                  "Metadata",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.5,
                                    color: Colors.blue[900],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 7),
                            _buildMetadataWidget(_result!['metadata'])
                          ],
                        ),
                      ),
                    ),
                  ),

                // 5. Bloc Résultat
                if (_result != null) ...[
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _result!['result'] == 'REAL'
                            ? Color(0xFFE7FEE7)
                            : Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (_result!['result'] == 'REAL'
                                ? Colors.greenAccent.withOpacity(0.07)
                                : Colors.redAccent.withOpacity(0.08)),
                            blurRadius: 11,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _result!['result'] == 'REAL' ? Icons.check_circle : Icons.cancel,
                            color: _result!['result'] == 'REAL' ? Colors.green[700] : Colors.red[700],
                            size: 33,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Result: ${_result!['result'] ?? 'Unknown'}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _result!['result'] == 'REAL'
                                        ? Colors.green[800]
                                        : Colors.red[800],
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Confidence: ${_result!['confidence']?.toStringAsFixed(2) ?? '?'}%",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                if (_result!['filename'] != null)
                                  Text("File: ${_result!['filename']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                if (_result!['analyzed_at'] != null)
                                  Text("Analyzed at: ${_result!['analyzed_at']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                if (_result!['processing_time_sec'] != null)
                                  Text("Processing time: ${_result!['processing_time_sec']}s", style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
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




