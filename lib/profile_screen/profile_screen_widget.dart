import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart'; // Assurez-vous que CreateAccountScreenWidget.routeName est exporté ici
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_screen_model.dart';
export 'profile_screen_model.dart';

class ProfileScreenWidget extends StatefulWidget {
  const ProfileScreenWidget({super.key});

  static String routeName = 'ProfileScreen';
  static String routePath = '/profileScreen';

  @override
  State<ProfileScreenWidget> createState() => _ProfileScreenWidgetState();
}

class _ProfileScreenWidgetState extends State<ProfileScreenWidget> {
  late ProfileScreenModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfileScreenModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey, // N'oubliez pas d'assigner la clé si vous l'utilisez
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: "Deepfake ",
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
            children: [
              TextSpan(
                text: "Profil",
                style: TextStyle(
                    fontWeight: FontWeight.normal, color: Colors.grey[900]),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding( // <<< MODIFICATION ICI: Padding est maintenant la valeur de 'body'
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 36.0, 0.0, 0.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FFButtonWidget(
              onPressed: () async {
                // Assurez-vous que CreateAccountScreenWidget et son routeName sont correctement importés/exportés
                context.pushNamed(CreateAccountScreenWidget.routeName);
              },
              text: 'Log Out',
              options: FFButtonOptions(
                width: 130.0,
                height: 50.0,
                padding:
                const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                iconPadding:
                const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                color: FlutterFlowTheme.of(context).secondaryBackground,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                  fontFamily: GoogleFonts.interTight().fontFamily, // Correction pour utiliser fontFamily
                  color: const Color(0xDFFF0000),
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w500,
                  // fontStyle: FlutterFlowTheme.of(context) // Redondant si déjà dans le thème
                  //     .titleSmall
                  //     .fontStyle,
                ),
                elevation: 0.0,
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).alternate,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ],
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