import 'dart:ui';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen_model.dart';
export 'home_screen_model.dart';

class HomeScreenWidget extends StatefulWidget {
  const HomeScreenWidget({super.key});

  static String routeName = 'HomeScreen';
  static String routePath = '/homeScreen';

  @override
  State<HomeScreenWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget> {
  late HomeScreenModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isButtonPressed = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeScreenModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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
                text: "Home",
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Illustration principale
                  Container(
                    width: 92,
                    height: 92,
                    margin: EdgeInsets.only(bottom: 20, top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(48),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 14)],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Image.asset(
                        'assets/images/detect.png', // CHANGE selon ton asset
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // SLOGAN PRINCIPAL (effet glass/frosted)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.55),
                        ),
                        child: Column(
                          children: const [
                            Text(
                              'Detect Deepfakes in the blink of an eye!',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Protect yourself from fake videos thanks to artificial intelligence.',
                              style: TextStyle(fontSize: 15, color: Colors.black54),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // SECTION "How does it work?" avec cartes
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.80),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3, spreadRadius: 1)],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'How does it work?',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StepCard(icon: 'assets/images/upload.png', label: 'Upload'),
                            _StepCard(icon: 'assets/images/analyze.png', label: 'Analyze'),
                            _StepCard(icon: 'assets/images/result.png', label: 'Result'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 38),

                  // BOUTON PRINCIPAL animé
                  AnimatedScale(
                    scale: _isButtonPressed ? 0.96 : 1.0,
                    duration: Duration(milliseconds: 120),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() => _isButtonPressed = true);
                          Future.delayed(Duration(milliseconds: 120), () {
                            setState(() => _isButtonPressed = false);
                            context.pushNamed(AnalyzeScreenWidget.routeName);
                          });
                        },
                        icon: const Icon(Icons.psychology_alt_rounded),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14.0),
                          child: Text(
                            'Analyzing video',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color(0xFF8E44AD),
                          elevation: 7,
                          shadowColor: Color(0xFF8E44AD).withOpacity(0.18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),

                  // INFO CONFIDENTIALITÉ
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.shield_outlined, color: Color(0xFF8E44AD), size: 20),
                        SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            'Your videos remain private on your device.',
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ),
      ),
      // --- BARRE DE NAVIGATION EN BAS (inchangée) ---
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

// === Mini-card étape pour "How does it work?" ===
class _StepCard extends StatelessWidget {
  final String icon;
  final String label;
  const _StepCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 3),
      margin: EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          Image.asset(icon, width: 38, height: 38),
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
