import 'package:flutter/material.dart';
import 'package:e_book/framework/colors/appcolors.dart';
import 'package:e_book/language/langugemanager.dart';
import 'package:e_book/language/pdfviewer.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FavoriteState createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  late final LanguageManager enLanguageManager;
  late final LanguageManager arLanguageManager;
  late final LanguageManager trLanguageManager;
  late List<Map<String, dynamic>> favoritePdfData = [];
  @override
  void initState() {
    super.initState();
    enLanguageManager = LanguageManager("en");
    arLanguageManager = LanguageManager("ar");
    trLanguageManager = LanguageManager("tr");
    _getAllFavoritePdf();
  }
  @override
  void dispose() {
    super.dispose();
    enLanguageManager.dispose();
    arLanguageManager.dispose();
    trLanguageManager.dispose();
  }
  Future<void> _getAllFavoritePdf() async {
    final List<Future<List<Map<String, dynamic>>>> futures = [
      _getFavoritePdf(enLanguageManager),
      _getFavoritePdf(arLanguageManager),
      _getFavoritePdf(trLanguageManager),
    ];
    final List<List<Map<String, dynamic>>> results = await Future.wait(futures);
    if (mounted) {
      setState(() {
        favoritePdfData = results.expand((element) => element).toList();
      });
    }
  }

  Future<List<Map<String, dynamic>>> _getFavoritePdf(LanguageManager languageManager) async {
    return await languageManager.getFavoritePdf();
  }

  void _removeFavoritePdf(LanguageManager languageManager, String pdfId) async {
    if (mounted) {
      await languageManager.toggleFavorite(pdfId, false);
      _getAllFavoritePdf();
    }
  }

  void _viewPdf(String pdfUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => pdfViewerPage(pdfUrl: pdfUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgrouncolor(),
      appBar: AppBar(
        backgroundColor: AppColors.appbuttombar(),
        title: Text(
          'Favorite Books',
          style: TextStyle(color: AppColors.text()),
        ),
        leading: IconButton(
          icon:const Icon(Icons.arrow_back),
          color: AppColors.icon(),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView.builder(
        itemCount: favoritePdfData.length,
        itemBuilder: (context, index) {
          return ListTile(
             leading:Image.network(
                      favoritePdfData[index]['imageUrl'],
                      height: 70,
                      width: 40,
                      fit: BoxFit.cover,
                    ),
            title: Text(favoritePdfData[index]['bookName'] ?? 'no book name'),
            //solundaki ifadenin null olup olmadığını kontrol eder. 
            //Eğer bu ifade null ise, sağındaki değeri  yani boş bir string kullanır.
            subtitle: Text(favoritePdfData[index]['authorName'] ?? 'no author name'), 
            trailing: IconButton(
              icon: const Icon(
                Icons.favorite,
                color: Colors.red,
              ),
              onPressed: () {
                final String pdfId = favoritePdfData[index]['id'];
                _removeFavoritePdf(enLanguageManager, pdfId);
                _removeFavoritePdf(arLanguageManager, pdfId);
                _removeFavoritePdf(trLanguageManager, pdfId);
              },
            ),
            onTap: () {
              _viewPdf(favoritePdfData[index]['pdfUrl']);
            },
          );
        },
      ),
    );
  }
}
