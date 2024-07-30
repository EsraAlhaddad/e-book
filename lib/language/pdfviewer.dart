import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class pdfViewerPage extends StatefulWidget {
  final String pdfUrl;
  const pdfViewerPage({super.key, required this.pdfUrl});

  @override
  State<pdfViewerPage> createState() => _pdfViewerPageState();
}

// ignore: camel_case_types
class _pdfViewerPageState extends State<pdfViewerPage> {
  PDFDocument? document;
  void initialisePdf() async {
    document = await PDFDocument.fromURL(widget.pdfUrl);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initialisePdf();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: document != null
          ? PDFViewer(
              document: document!,
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
