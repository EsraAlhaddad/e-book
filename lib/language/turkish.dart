import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:e_book/framework/colors/appcolors.dart';
import 'package:e_book/language/langugemanager.dart';
import 'package:e_book/language/pdfviewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

class Turkish extends StatefulWidget {
  const Turkish({Key? key}) : super(key: key);

  @override
  State<Turkish> createState() => _TurkishState();
}

class _TurkishState extends State<Turkish> {
  late LanguageManager languageManager;
  List<Map<String, dynamic>> pdfData = [];
  bool _isMounted = false;
  String? _userEmail;
  Map<String, bool> isDownloadingMap = {};

  final TextEditingController _bookNameController = TextEditingController();
  final TextEditingController _pageCountController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    languageManager = LanguageManager('tr');
    getCurrentUser();
    getAllPdf();
  }

  @override
  void dispose() {
    _isMounted = false;
    _bookNameController.dispose();
    _pageCountController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userEmail = user?.email;
    });
  }

  Future<void> pickFile() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Book Information"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _bookNameController,
                    decoration: const InputDecoration(labelText: 'Book Name'),
                  ),
                  TextField(
                    controller: _authorController,
                    decoration: const InputDecoration(labelText: 'Author Name'),
                  ),
                  TextField(
                    controller: _pageCountController,
                    decoration:
                        const InputDecoration(labelText: 'Number of pages'),
                    keyboardType: TextInputType.number,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.image,
                      );
                      if (result != null) {
                        setState(() {
                          _selectedImage = File(result.files.single.path!);
                        });
                      }
                    },
                    child: const Text("Select Image"),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    if (_bookNameController.text.isEmpty ||
                        _pageCountController.text.isEmpty ||
                        _authorController.text.isEmpty ||
                        _selectedImage == null) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Warning"),
                            content: const Text(
                                "Please fill in all required fields."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      Navigator.of(context).pop();
                      final pickedFile = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf'],
                      );

                      if (pickedFile != null) {
                        String fileName = pickedFile.files.first.name;
                        File file = File(pickedFile.files.first.path!);

                        uploadPdf(
                            fileName,
                            file,
                            _bookNameController.text,
                            int.tryParse(_pageCountController.text) ?? 0,
                            _authorController.text,
                            _selectedImage!);

                        _bookNameController.clear();
                        _pageCountController.clear();
                        _authorController.clear();
                      }
                    }
                  },
                  child: const Text("Upload"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> uploadPdf(String fileName, File file, String bookName, int pageCount, String authorName, File imageFile) async {
    if (!_isMounted) return;

    // Yükleniyor göstergesini göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      String imageUrl = await uploadImageToStorage(imageFile);

      final downloadLink = await languageManager.uploadPdf(
          fileName, file, bookName, pageCount, authorName);
      
      if (_isMounted) {
        setState(() {
          languageManager.addPdf(
              fileName, downloadLink, bookName, pageCount, authorName, imageUrl);
        });
      }

      await getAllPdf();
    } finally {
      // Yükleniyor göstergesini kapat
      Navigator.of(context).pop();
    }
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference reference = storage.ref().child("images/$fileName");
      UploadTask uploadTask = reference.putFile(imageFile);
      await uploadTask;
      String imageUrl = await reference.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print("Resim yüklenirken bir hata oluştu: $e");
      return "";
    }
  }

  Future<void> getAllPdf() async {
    final data = await languageManager.getAllPdf();
    if (_isMounted) {
      setState(() {
        pdfData = data;
      });
    }
  }

  void _deletePdf(String pdfid) async {
    await FirebaseFirestore.instance
        .collection('pdfs_tr')
        .doc(pdfid)
        .delete()
        .then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF Deleted')),
      );
      if (mounted) {
        getAllPdf();
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    });
  }

  void _toggleFavorite(int index) async {
    bool isFavorite = pdfData[index]['favorites'] ?? false;
    String pdfId = pdfData[index]['id'] as String;
    bool newFavoriteState = !isFavorite;
    await languageManager.toggleFavorite(pdfId, newFavoriteState);
    if (_isMounted) {
      setState(() {
        pdfData[index]['favorites'] = newFavoriteState;
      });
    }

    if (newFavoriteState) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF added to fav')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF Removed from Fav')),
      );
    }
  }

  void _downloadPdf(String url, String fileName, String fileId) async {
    setState(() {
      isDownloadingMap[fileId] = true;
    });

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;

    String fullPath = '$tempPath/$fileName';

    Dio dio = Dio();
    try {
      await dio.download(url, fullPath);

      File file = File(fullPath);
      String savedDir = '/storage/emulated/0/Download';

      int duplicateCount = 1;
      String newFileName = fileName;
      while (await File('$savedDir/$newFileName').exists()) {
        String extension = fileName.split('.').last;
        String baseName = fileName.replaceAll(
            RegExp(r'\.[^.]+$'), '');
        newFileName =
            '$baseName($duplicateCount).$extension';
        duplicateCount++;
      }

      await file.copy('$savedDir/$newFileName');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF Downloaded')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The file has already been downloaded'),
        ),
      );
    } finally {
      setState(() {
        isDownloadingMap[fileId] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgrouncolor(),
      appBar: AppBar(
        backgroundColor: AppColors.appbuttombar(),
        title: Text(
          'Turkish Books',
          style: TextStyle(color: AppColors.text()),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.icon(),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView.builder(
        itemCount: pdfData.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      pdfViewerPage(pdfUrl: pdfData[index]['pdfUrl']),
                ));
              },
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(width: 4,color: AppColors.appbuttombar()),color: const Color.fromARGB(255, 235, 208, 188),
                ),
                child: Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black, // Border rengi
          width: 2.0,         // Border kalınlığı
        ),
      ),
      child: Image.network(
        pdfData[index]['imageUrl'],
        height: 200,
        width: 120,
        fit: BoxFit.cover,
      ),
    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Book Name: ${pdfData[index]['bookName'].toString()}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Author: ${pdfData[index]['authorName'].toString()}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Pages: ${pdfData[index]['pageCount'].toString()}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  pdfData[index]['favorites']
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: pdfData[index]['favorites']
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                                onPressed: () {
                                  _toggleFavorite(index);
                                },
                              ),
                              IconButton(
                                icon: isDownloadingMap[pdfData[index]['id']] ?? false
                                    ? const CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Color.fromARGB(255, 29, 146, 146),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.download,
                                        color: Color.fromARGB(255, 29, 146, 146),
                                      ),
                                onPressed: () {
                                  if (!(isDownloadingMap[pdfData[index]['id']] ??
                                      false)) {
                                    _downloadPdf(
                                        pdfData[index]['pdfUrl'],
                                        pdfData[index]['name'],
                                        pdfData[index]['id'] as String);
                                  }
                                },
                              ),
                              if (_userEmail == 'esra@gmail.com')
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.black),
                                  onPressed: () {
                                    _deletePdf(pdfData[index]['id'] as String);
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.appbuttombar(),
        onPressed: pickFile,
        child: Icon(Icons.upload_file, size: 40, color: AppColors.button()),
      ),
    );
  }
}
