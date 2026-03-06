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
  File? selectedIdFile;
  File? selectedAddressFile;

  @override
  void initState() {
    super.initState();

    Future.microtask(
      () => Provider.of<DocumentProvider>(
        context,
        listen: false,
      ).fetchDocuments(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DocumentProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Documents",
          style: theme.textTheme.titleMedium!.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
        ),
      ),

      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: documentCard(
                      context,
                      title: "ID Proof",
                      filePath: provider.empIdProof,
                      type: "id",
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: documentCard(
                      context,
                      title: "Address Proof",
                      filePath: provider.empAddressProof,
                      type: "address",
                    ),
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
    final theme = Theme.of(context);

    File? selectedFile = type == "id" ? selectedIdFile : selectedAddressFile;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          /// VIEW CURRENT DOCUMENT
          if (filePath.isNotEmpty)
            GestureDetector(
              onTap: () {
                final url = "${Apiconstants.fileUrl}/$filePath";

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DocumentViewerScreen(url: url),
                  ),
                );
              },
              child: Text(
                "View Current Document",
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),

          const SizedBox(height: 10),

          /// SELECT FILE
          ElevatedButton.icon(
            icon: const Icon(Icons.attach_file),
            label: const Text("Select File"),
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
              );

              if (result != null) {
                setState(() {
                  if (type == "id") {
                    selectedIdFile = File(result.files.single.path!);
                  } else {
                    selectedAddressFile = File(result.files.single.path!);
                  }
                });
              }
            },
          ),

          /// FILE NAME
          if (selectedFile != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                selectedFile.path.split('/').last,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: theme.textTheme.bodyMedium,
              ),
            ),

          const SizedBox(height: 10),

          /// SUBMIT BUTTON
          if (selectedFile != null)
            ElevatedButton(
              child: const Text("Submit"),
              onPressed: () async {
                bool success = await provider.uploadDocument(
                  file: selectedFile,
                  type: type,
                );

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Document uploaded successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );

                  setState(() {
                    if (type == "id") {
                      selectedIdFile = null;
                    } else {
                      selectedAddressFile = null;
                    }
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Upload failed"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}
