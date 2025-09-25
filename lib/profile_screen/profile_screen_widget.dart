import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart'; // Assurez-vous que CreateAccountScreenWidget.routeName est exporté ici
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'SignedFileDetailPage.dart';
import 'profile_screen_model.dart';
export 'profile_screen_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';


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

  // ----- Helpers pour "Signed files" -----

// Extrait proprement un champ depuis Map potentiellement null.
  T? _getField<T>(Map<String, dynamic>? m, List<String> path) {
    dynamic cur = m;
    for (final p in path) {
      if (cur is Map<String, dynamic> && cur.containsKey(p)) {
        cur = cur[p];
      } else {
        return null;
      }
    }
    return cur as T?;
  }

// UI de la section "Signed files"
  Widget _buildSignedFilesSection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return _signedCardShell(
        title: "Signed files",
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Veuillez vous connecter pour voir vos fichiers signés.",
            style: TextStyle(fontSize: 14),
          ),
        ),
      );
    }

    // On récupère toutes les analyses de l'utilisateur,
    // puis on filtre côté client celles qui contiennent meta.integrity.signature_b64.
    final stream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _signedCardShell(
            title: "Signed files",
            child: const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (snap.hasError) {
          return _signedCardShell(
            title: "Signed files",
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Erreur de chargement : ${snap.error}",
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final docsAll = snap.data?.docs ?? [];
        final docs = docsAll.where((d) {
          final data = d.data();
          final integrity = _getField<Map<String, dynamic>>(data, ['meta', 'integrity']);
          final sig = _getField<String>(integrity, ['signature_b64']);
          return (sig != null && sig.trim().isNotEmpty);
        }).toList();

        if (docs.isEmpty) {
          return _signedCardShell(
            title: "Signed files",
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "No signed files for the moment.",
                style: TextStyle(fontSize: 14),
              ),
            ),
          );
        }

        // Liste cliquable
        return _signedCardShell(
          title: "Signed files",
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text("${docs.length}",
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data();
              final filename = _getField<String>(data, ['filename']) ?? doc.id;

              final integrity = _getField<Map<String, dynamic>>(data, ['meta', 'integrity']) ?? {};
              final sha256 = _getField<String>(integrity, ['sha256']) ?? "-";
              final signedAt = _getField<String>(integrity, ['signed_at']) ?? "-";
              final alg = _getField<String>(integrity, ['alg']) ?? "RSA-2048/SHA-256";
              final sigB64 = _getField<String>(integrity, ['signature_b64']) ?? "";

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                leading: const Icon(Icons.verified, color: Colors.green),
                title: Text(
                  filename,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  "SHA-256: ${sha256.length >= 16 ? '${sha256.substring(0,16)}…' : sha256}\nSigned at: $signedAt",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  tooltip: "Exporter la signature (.sig)",
                  icon: const Icon(Icons.download),
                  onPressed: sigB64.isEmpty ? null : () => _exportSigFile(filename, sigB64),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SignedFileDetailPage(
                        filename: filename,
                        sha256: sha256,
                        signedAt: signedAt,
                        signatureB64: sigB64,
                        algorithm: alg,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

// Carte conteneur stylée pour la section
  Widget _signedCardShell({
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 5))],
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
              child: Row(
                children: [
                  const Icon(Icons.fact_check_outlined, color: Color(0xFF4C51BF)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (trailing != null) trailing,
                ],
              ),
            ),
            const Divider(height: 1),
            // Contenu
            child,
          ],
        ),
      ),
    );
  }

// Exporter la signature dans un fichier .sig puis partager
  Future<void> _exportSigFile(String filename, String signatureB64) async {
    try {
      final dir = await getTemporaryDirectory();
      final base = filename.replaceAll('/', '_');
      final file = File('${dir.path}/$base.sig');
      await file.writeAsString(signatureB64.trim());
      await Share.shareXFiles([XFile(file.path)], text: "Signature pour $filename");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Export impossible : $e")),
      );
    }
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 6),
              // ---- NOUVELLE SECTION : Signed files ----
              _buildSignedFilesSection(),

              const SizedBox(height: 12),

              // ---- Ton bouton existant "Log Out" ----
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FFButtonWidget(
                    onPressed: () async {
                      context.pushNamed(CreateAccountScreenWidget.routeName);
                    },
                    text: 'Log Out',
                    options: FFButtonOptions(
                      width: 130.0,
                      height: 50.0,
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: GoogleFonts.interTight().fontFamily,
                        color: const Color(0xDFFF0000),
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
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
            ],
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

