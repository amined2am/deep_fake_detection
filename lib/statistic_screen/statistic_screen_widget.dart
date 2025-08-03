import 'dart:ui';
import 'package:deep_fake_detection/model/AnalyzeHistoryEntry.dart';
import 'package:fl_chart/fl_chart.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'statistic_screen_model.dart';
export 'statistic_screen_model.dart';

class StatisticScreenWidget extends StatefulWidget {
  const StatisticScreenWidget({Key? key, this.entry}) : super(key: key);
  final AnalyzeHistoryEntry? entry;

  static String routeName = 'StatisticScreen';
  static String routePath = '/statisticScreen';

  @override
  State<StatisticScreenWidget> createState() => _StatisticScreenWidgetState();
}

class _StatisticScreenWidgetState extends State<StatisticScreenWidget> {
  late StatisticScreenModel _model;


  int totalVideos = 0;
  int totalFakes = 0;
  int totalReal = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StatisticScreenModel());
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .get();

      int real = 0, fake = 0;
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['result'] == 'REAL') real++;
        else if (data['result'] == 'FAKE') fake++;
      }
      setState(() {
        totalVideos = snap.docs.length;
        totalReal = real;
        totalFakes = fake;
        _loading = false;
      });
    } catch (e) {
      print('[STATS] Error fetching stats: $e');
      setState(() => _loading = false);
    }
  }
  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double fakePercent = totalVideos == 0 ? 0 : totalFakes / totalVideos * 100;
    double realPercent = totalVideos == 0 ? 0 : totalReal / totalVideos * 100;
    if(_loading){
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: "Deepfake ",
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
            children: [
              TextSpan(
                text: "Statistic",
                style: TextStyle(fontWeight: FontWeight.normal, color: Colors.grey[900]),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFf8e8ff), Color(0xFFf0f0ff)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // <--- pour tout aligner à gauche
                children: [
                  // Bloc titre - logo plus gros, en haut à gauche
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Image.asset(
                            'assets/images/statistique.png', // Mets ton icône ici
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(width: 13),
                      Text(
                        "Your statistics",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Color(0xFF8E44AD),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 22),

                  // Statistiques clés
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatCard(
                        label: "Analyzed",
                        value: "$totalVideos",
                        icon: Icons.play_circle_outline,
                        color: Colors.blue[200]!,
                      ),
                      _StatCard(
                        label: "Deepfakes",
                        value: "$totalFakes",
                        icon: Icons.warning_amber_rounded,
                        color: Colors.pink[200]!,
                      ),
                      _StatCard(
                        label: "Real",
                        value: "$totalReal",
                        icon: Icons.verified_user_outlined,
                        color: Colors.green[200]!,
                      ),
                    ],
                  ),
                  SizedBox(height: 30),

                  // Camembert (pie chart)
                  Center(
                    child: Container(
                      width: 230, height: 230,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 48,
                            sections: [
                              PieChartSectionData(
                                color: Color(0xFFD6336C),
                                value: totalFakes.toDouble(),
                                title: "${fakePercent.toStringAsFixed(1)}%",
                                radius: 50,
                                titleStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                              ),
                              PieChartSectionData(
                                color: Color(0xFF54C69D),
                                value: totalReal.toDouble(),
                                title: "${realPercent.toStringAsFixed(1)}%",
                                radius: 50,
                                titleStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PieLegend(color: Color(0xFFD6336C), label: 'Deepfake'),
                      SizedBox(width: 20),
                      _PieLegend(color: Color(0xFF54C69D), label: 'Real')
                    ],
                  ),

                ],
              ),
            ),
          ),
        ),
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

// Petite carte statistique (chiffre clé)
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.23),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: 7),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          SizedBox(height: 5),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.black54)),
        ],
      ),
    );
  }
}

// Légende Pie Chart
class _PieLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _PieLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 18, height: 18, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6))),
        SizedBox(width: 7),
        Text(label, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      ],
    );
  }
}
