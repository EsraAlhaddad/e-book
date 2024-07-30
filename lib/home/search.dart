import 'package:e_book/framework/colors/appcolors.dart';
import 'package:e_book/language/pdfviewer.dart';
import 'package:flutter/material.dart';

class SearchResultsPage extends StatefulWidget {
  final List<Map<String, dynamic>> searchResults;
  final bool isLoading;

  const SearchResultsPage(
      {super.key, required this.searchResults, required this.isLoading});

  @override
  // ignore: library_private_types_in_public_api
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgrouncolor(),
      appBar: AppBar(
        backgroundColor: AppColors.appbuttombar(),
        title: Text(
          'Search Result',
          style: TextStyle(color: AppColors.text()),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.icon(),
          onPressed: () {
            Navigator.of(context).pop();
            // Geri butonuna basıldığında arama sonuçlarını temizleme işlemi
            setState(() {
              widget.searchResults.clear();
            });
          },
        ),
      ),
      body: widget.isLoading
          ? const Center(child: CircularProgressIndicator())
          : widget.searchResults.isEmpty
              ? const Center(child: Text('No results'))
              : ListView.builder(
                  itemCount: widget.searchResults.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(widget.searchResults[index]['bookName']),
                      subtitle: Text(widget.searchResults[index]['authorName']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => pdfViewerPage(
                                pdfUrl: widget.searchResults[index]['pdfUrl']),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
