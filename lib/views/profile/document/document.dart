// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hrportal/constants/apiconstants.dart';
import 'package:hrportal/service/profile/documentService.dart';
import 'package:hrportal/views/profile/document/documentViewer.dart';
import 'package:provider/provider.dart';


class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() =>
        Provider.of<DocumentProvider>(context, listen: false)
            .fetchDocuments());
  }

  @override
  Widget build(BuildContext context) {

    final provider = Provider.of<DocumentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Documents"),
      ),

      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            documentCard(
              context,
              title: "ID Proof",
              filePath: provider.empIdProof,
              type: "id",
            ),

            const SizedBox(height: 20),

            documentCard(
              context,
              title: "Address Proof",
              filePath: provider.empAddressProof,
              type: "address",
            ),
          ],
        ),
      ),
    );
  }

  Widget documentCard(
      BuildContext context, {
        required String title,
        required String filePath,
        required String type,
      }) {

    final provider = Provider.of<DocumentProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          /// VIEW DOCUMENT
          if (filePath.isNotEmpty)
            Row(
              children: [

                const Icon(Icons.remove_red_eye),

                const SizedBox(width: 6),

                GestureDetector(
                  onTap: () {

                    final url =
                        "${Apiconstants.baseUrl}/$filePath";

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DocumentViewerScreen(url: url),
                      ),
                    );
                  },
                  child: const Text(
                    "View Current Document",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 12),

          /// UPLOAD BUTTON
          ElevatedButton.icon(

            icon: const Icon(Icons.upload_file),

            label: Text(
              filePath.isEmpty
                  ? "Upload Document"
                  : "Change Document",
            ),

            onPressed: () async {

              FilePickerResult? result =
              await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['jpg','jpeg','png','pdf'],
              );

              if (result != null) {

                File file = File(result.files.single.path!);

                await provider.uploadDocument(
                  file: file,
                  type: type,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}