
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class SignedFileDetailPage extends StatelessWidget {
  final String filename;
  final String sha256;
  final String signedAt;
  final String signatureB64;
  final String algorithm;

  const SignedFileDetailPage({
    super.key,
    required this.filename,
    required this.sha256,
    required this.signedAt,
    required this.signatureB64,
    required this.algorithm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Signed file"),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: Colors.green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      filename,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _kv("Algorithm", algorithm),
            _kv("Signed at", signedAt),
            _kv("SHA-256", sha256, selectable: true, isMonospace: true),
            const SizedBox(height: 12),

            const Text("Signature (Base64)", style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            _monoBox(signatureB64),
            const SizedBox(height: 14),

            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _copy(context, sha256),
                  icon: const Icon(Icons.copy),
                  label: const Text("Copy SHA-256"),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _copy(context, signatureB64),
                  icon: const Icon(Icons.copy),
                  label: const Text("Copy signature"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _export(context, filename, signatureB64),
              icon: const Icon(Icons.download),
              label: const Text("Exporter .sig"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v, {bool selectable = false, bool isMonospace = false}) {
    final styleVal = TextStyle(
      fontWeight: FontWeight.w600,
      fontFamily: isMonospace ? 'monospace' : null,
    );
    final w = selectable
        ? SelectableText(v, style: styleVal)
        : Text(v, style: styleVal);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(k, style: const TextStyle(color: Colors.black54))),
          const SizedBox(width: 8),
          Expanded(child: w),
        ],
      ),
    );
  }

  Widget _monoBox(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: SelectableText(
        content,
        style: const TextStyle(fontFamily: 'monospace'),
      ),
    );
  }

  Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Copy in press-paper")),
    );
    // ignore: use_build_context_synchronously
  }

  Future<void> _export(BuildContext context, String filename, String sigB64) async {
    try {
      final dir = await getTemporaryDirectory();
      final base = filename.replaceAll('/', '_');
      final file = File('${dir.path}/$base.sig');
      await file.writeAsString(sigB64.trim());
      await Share.shareXFiles([XFile(file.path)], text: "Signature for $filename");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Export impossible : $e")),
      );
    }
  }
}