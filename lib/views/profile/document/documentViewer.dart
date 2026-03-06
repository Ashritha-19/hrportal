// ignore_for_file: file_names

import 'package:flutter/material.dart';

class DocumentViewerScreen extends StatelessWidget {
  final String url;

  const DocumentViewerScreen({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Document")),

      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            url,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;

              return const Center(
                child: CircularProgressIndicator(),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Text("Unable to load document");
            },
          ),
        ),
      ),
    );
  }
}