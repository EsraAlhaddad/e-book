import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_book/framework/colors/appcolors.dart';
import 'package:e_book/home/search.dart';
import 'package:e_book/intro_pages/onboarding_screen.dart';
import 'package:e_book/language/arabic.dart';
import 'package:e_book/language/english.dart';
import 'package:e_book/language/turkish.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _timer;
  final ScrollController _controller = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<String> imageList = [
    'kontainer1.jpg',
    'kontainer2.jpg',
    'kontainer3.jpg'
  ];

  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (_controller.hasClients) {
        const int itemCount = 3;
        final double itemExtent =
            MediaQuery.of(context).size.width + 28; // item width + margin
        final double maxExtent = itemExtent * itemCount;
        final double currentOffset = _controller.offset;

        if (currentOffset < maxExtent - itemExtent) {
          _controller.animateTo(
            currentOffset + itemExtent,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
          );
        } else {
          _controller.jumpTo(0.0); //en başa dönmesi için
        }
      }
    });
  }

  Future<void> searchBooks(String searchText) async {
    try {
      setState(() {
        isLoading = true;
      });
      List<String> collections = ['pdfs_ar', 'pdfs_tr', 'pdfs_en'];
      List<String> searchs = ['bookName', 'authorName'];
      List<Map<String, dynamic>> results = [];
      searchText = searchText.toLowerCase();
      for (String collection in collections) {
        QuerySnapshot querySnapshot =
            await FirebaseFirestore.instance.collection(collection).get();
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          for (String searchKey in searchs) {
            String bookName = data[searchKey].toString().toLowerCase();
            if (bookName.contains(searchText)) {
              results.add(data);
              break; // Eğer bir eşleşme bulunursa, döngüyü kır.
            }
          }
        }
      }
      setState(() {
        searchResults = results;
        isLoading = false;
      });

      _navigateToSearchResults();
    } catch (error) {
      // ignore: avoid_print
      print("Arama sırasında bir hata oluştu: $error");
      setState(() {
        isLoading = false;
      });
    }
  }
  void _navigateToSearchResults() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsPage(
            searchResults: searchResults, isLoading: isLoading),
      ),
    );
    setState(() {
      searchResults.clear(); // Arama sonuçları sayfasından geri dönüldüğünde sonuçları temizle
    });
     _searchController.clear(); // Arama yapıldıktan sonra TextField'i temizle
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgrouncolor(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 500,
              height: 170,
              decoration: BoxDecoration(
                color: AppColors.appbuttombar(),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 20,
                    left: 10,
                    child: Row(
                      children: [
                        IconButton(
                          color: AppColors.icon(),
                          icon: const Icon(
                            Icons.arrow_back,
                            size: 30,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const OnBoardingScreen()),
                            );
                          },
                        ),
                        Text(
                          "Home Page",
                          style:
                              TextStyle(color: AppColors.text(), fontSize: 30),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 110,
                    left: 30,
                    right: 30,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          contentPadding: EdgeInsets.symmetric(horizontal: 15),
                          border: InputBorder.none,
                          suffixIcon: Icon(Icons.search, size: 25),
                        ),
                        onEditingComplete: () {
                          searchBooks(_searchController.text);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width,
              color: AppColors.backgrouncolor(),
              height: 200,
              child: ListView.builder(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (BuildContext context, int index) {
                  final int adjustedIndex = index % 3;
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 203, 171, 150),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        Image.asset(
                          "images/${imageList[adjustedIndex]}",
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                Card(
                  color: AppColors.backgrouncolor(),
                  child: ListTile(
                    title: const Text('Turkish Books'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Turkish()),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Card(
                  color: AppColors.backgrouncolor(),
                  child: ListTile(
                    title: const Text('English Books'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const English()),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Card(
                  color: AppColors.backgrouncolor(),
                  child: ListTile(
                      title: const Text('Arabic Books'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Arabic()),
                        );
                      }),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
