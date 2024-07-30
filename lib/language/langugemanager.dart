import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class LanguageManager {
  final String languageCode;
  final CollectionReference collectionReference;
  LanguageManager(this.languageCode)
      : collectionReference =
            FirebaseFirestore.instance.collection("pdfs_$languageCode");
  Future<String> uploadPdf(String fileName, File file, String bookName, 
  int pageCount, String authorName) async {
    final reference = FirebaseStorage.instance.ref().child("pdfs_$languageCode/$fileName.pdf");
    final UploadTask uploadTask = reference.putFile(file);
    await uploadTask.whenComplete(() {});

    final downloadLink = await reference.getDownloadURL();
    return downloadLink;
  }
  Future<void> addPdf(String fileName, String downloadLink, String bookName,
   int pageCount, String authorName, String imageUrl) async {
    await collectionReference.add({
      "name": fileName,
      "pdfUrl": downloadLink,
      "imageUrl": imageUrl,
      "bookName": bookName,
      "pageCount": pageCount,
      "authorName": authorName,
      "public": true,
      "favorites": false,
      
    });
  }

  Future<List<Map<String, dynamic>>> getAllPdf() async {
    final results = await collectionReference.get();
    print("getAllPdf results: $results");
    return results.docs.map((e) {
      Map<String, dynamic> data = e.data() as Map<String, dynamic>;
      data['id'] = e.id;
      if (!data.containsKey('favorites')) {
        data['favorites'] = false;
      }
      return data;
    }).toList();
  }
  Future<void> toggleFavorite(String pdfId, bool isFavorite) async {
    try {
      final docSnapshot = await collectionReference.doc(pdfId).get();
      if (docSnapshot.exists) {
        await collectionReference.doc(pdfId).update({'favorites': isFavorite});
      } else {
        print('Belge bulunamadı: $pdfId');
      }
    } catch (e) {
      print('toggleFavorite hata: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFavoritePdf() async {
    final querySnapshot = await collectionReference.where('favorites', isEqualTo: true).get();
    return querySnapshot.docs.map<Map<String, dynamic>>((doc) {
      final data = doc.data();
      if (data != null && data is Map<String, dynamic>) {
        return {...data, 'id': doc.id};
      } else {
        return {};
      }
    }).toList();
  }

  void dispose() {}
}
