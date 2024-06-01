import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:k_mart/screens/post.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';


import '../constants/categories.dart';
import '../models/Item.dart';
import 'about_us.dart';
import 'item_details.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.showcase});

  final String title;
  final bool showcase;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {


  void _navigateToPostScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => PostScreen(),
      ),
    );
  }

  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();
  final GlobalKey _three = GlobalKey();

  bool isShowMyItems = false;

  void _showMyItems() {
    setState(() {
      isShowMyItems = isShowMyItems == false ? true : false;
    });
    handleRefresh();
  }

  @override
  void initState() {
    super.initState();
    initToken();
    if(widget.showcase) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          ShowCaseWidget.of(context).startShowCase([_one, _two, _three])
      );
    }
  }


  //Item List

  List<String> choices = categories;
  Set<String> selectedChoices = {};

  void onChoiceSelected(String choice) {
    setState(() {
      if (selectedChoices.contains(choice)) {
        selectedChoices.remove(choice);
      } else {
        selectedChoices.add(choice);
      }
      handleRefresh();
    });
  }

  void deleteExpiredDocuments() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference collection = firestore.collection('items');

    QuerySnapshot snapshot = await collection
        .where('ExpirationTimestamp', isLessThan: Timestamp.now())
        .get();

    snapshot.docs.forEach((doc) async {
      var data = doc.data() as Map<String, dynamic>;
      var itemId = data["Id"];
      ListResult result = await FirebaseStorage.instance.ref("images/$itemId").listAll();
      for (Reference ref in result.items) {
        ref.delete();
      }
      doc.reference.delete();
    });
  }

  String _userToken = 'Unknown';

  Future<void> initToken() async {
    String userToken;

    try {
      userToken = await getUserToken();
    } on PlatformException {
      userToken = 'Failed to get token';
    }

    if (!mounted) return;

    setState(() {
      _userToken = userToken;
    });
  }

  future() {
    deleteExpiredDocuments();
    if(isShowMyItems) {
      if(search != "") {
        return FirebaseFirestore.instance
            .collection('items')
            .where("UserToken", isEqualTo: _userToken)
            .where("Name", isGreaterThanOrEqualTo: capitalize(search))
            .get();
      } else {
        return FirebaseFirestore.instance
            .collection('items')
            .where("UserToken", isEqualTo: _userToken)
            .get();
      }
    } else {
      if (selectedChoices.isNotEmpty && search != "") {
        return FirebaseFirestore.instance
            .collection('items')
            .where("Category", whereIn: selectedChoices)
            .where("Name", isGreaterThanOrEqualTo: capitalize(search))
            .get();
      } else if (selectedChoices.isNotEmpty && search == "") {
        return FirebaseFirestore.instance
            .collection('items')
            .where("Category", whereIn: selectedChoices)
            .get();
      } else if (selectedChoices.isEmpty && search != "") {
        return FirebaseFirestore.instance
            .collection('items')
            .where("Name", isGreaterThanOrEqualTo: capitalize(search))
            .get();
      } else {
        return FirebaseFirestore.instance.collection('items').get();
      }
    }

  }

  Future<void> handleRefresh() async {
    _ongoingFuture = future();
    QuerySnapshot newData = await _ongoingFuture;

    if (mounted) {
      setState(() {
        snapshotData = newData;
      });
    }
  }

  GestureDetector singleItem(QueryDocumentSnapshot document) {
    var data = document.data() as Map<String, dynamic>;
    Item item = Item(
        userToken: data["UserToken"],
        id: data["Id"],
        name: data["Name"],
        imageUrls: data["ImageUrl"],
        description: data["Description"],
        condition: data["Condition"],
        price: data["Price"],
        contact: data["Contact"],
        expirationTimestamp: data["ExpirationTimestamp"],
        category: data["Category"]);
    return GestureDetector(
      onTap: () async {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ItemDetailPage(
              item: item,
              userToken: _userToken,
            ),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Hero(
                tag: 'item_${data["Id"]}',
                child: FancyShimmerImage(
                  imageUrl: "${data["ImageUrl"][0]}",
                  boxFit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  shimmerBaseColor: Colors.green,
                  shimmerHighlightColor: Colors.greenAccent,
                  shimmerBackColor: Colors.green.shade900,
                )
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${data["Name"]}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${data["Price"]} SR",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  late QuerySnapshot snapshotData;
  late String search = "";
  late Future _ongoingFuture;

  @override
  void dispose() {
    super.dispose();
  }

  buildItems(snapshotData) {
    return GridView.custom(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      childrenDelegate: SliverChildBuilderDelegate(
            (context, index) {
          return Padding(
            padding: EdgeInsets.only(
                top: index < 2 ? 8 : 0,
                left: index % 2 == 0 ? 8.0 : 0,
                bottom: index == snapshotData!.docs.length ? 450 : 0,
                right: index % 2 != 0 ? 8.0 : 0),
            child: singleItem(snapshotData!.docs[index]),
          );
        },
        childCount: snapshotData!.docs.length,
      ),
    );
  }

  TextEditingController _search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    double screenHeight = mediaQueryData.size.height;
    double statusBarHeight = mediaQueryData.padding.top;
    double appBarHeight = kToolbarHeight;
    double availableContentHeight = screenHeight - statusBarHeight - appBarHeight;


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          GestureDetector(
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => AboutUs()));
            },
            child: Row(
              children: [
                const Text("Contact Us"),
                IconButton(
                  icon: const Icon(Icons.contact_mail),
                  onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => AboutUs()));
                  },
                ),
              ],
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Column(
              children: <Widget>[
                Container(
                  height: 60,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 9, 8, 8),
                          child: TextField(
                            controller: _search,
                            onTapOutside: (event) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            onChanged: (value) {
                              setState(() {
                                search = value;
                              });
                              handleRefresh();
                            },
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              border: InputBorder.none,
                              hintText: "Search",
                            ),
                          ),
                        ),
                      ),
                      // Cross Icon
                      SizedBox(width: 8), // Adding some space between the icons
                      // Clear Filter Button
                      GestureDetector(
                        onTap: () {
                          // Implement your logic for clearing filters here
                          setState(() {
                            _search.clear();
                            selectedChoices.clear();
                            search = "";
                            handleRefresh();
                          });
                        },
                        child: Text(
                          "Clear All Filters",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      SizedBox(width: 8), // Adding some space between the icons
                    ],
                  ),
                ),
                isShowMyItems ? const SizedBox(height: 60, child: Center(child: Text("Your Items", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),),) : SizedBox(
                  height: 60,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: choices.map((choice) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ChoiceChip(
                          label: Text(choice),
                          selected: selectedChoices.contains(choice),
                          onSelected: (isSelected) {
                            onChoiceSelected(choice);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  height: availableContentHeight - 130,
                  child: FutureBuilder<QuerySnapshot>(
                    future: future(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Text("Error fetching data");
                      } else {
                        if (snapshot.hasData) {
                          snapshotData = snapshot.data!;
                          print(snapshotData.docs.length);
                          if (snapshotData.docs.isEmpty) {
                            return Center(
                                child: ElevatedButton(
                                    onPressed: () {
                                      _search.clear();
                                      search = "";
                                      handleRefresh();
                                    },
                                    child: const Text(
                                        "No data available. Tap to refresh")));
                          }

                          return widget.showcase ? Showcase(
                            key: _three,
                            description: "Pull to refresh the items",
                            child: LiquidPullToRefresh(
                              showChildOpacityTransition: false,
                              onRefresh: handleRefresh,
                              child: buildItems(snapshotData),
                            ),
                          ) : LiquidPullToRefresh(
                      showChildOpacityTransition: false,
                      onRefresh: handleRefresh,
                      child: buildItems(snapshotData),
                      );
                        } else {
                          return const Text("No Data");
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: widget.showcase ? Stack(
        children: [
          Positioned(
            bottom: 0,
            right: 0,
            child: Showcase(
              key: _one,
              description: "You can post your item here",
              child: FloatingActionButton(
                heroTag: "postItem",
                onPressed: _navigateToPostScreen,
                tooltip: 'Post Item',
                child: const Icon(Icons.add),
              ),
            ),
          ),
          Positioned(
            bottom: 70,
            right: 0,
            child: Showcase(
              key: _two,
              description: "Tap here to see your items",
              child: FloatingActionButton(
                backgroundColor: isShowMyItems ? Theme.of(context).colorScheme.inversePrimary : Theme.of(context).colorScheme.primaryContainer,
                heroTag: "myItems",
                onPressed: (){
                  _search.clear();
                  search = "";
                  selectedChoices.clear();
                  _showMyItems();
                },
                tooltip: 'My Items',
                child: isShowMyItems ? const Icon(Icons.home) : const Icon(Icons.perm_contact_cal_outlined),
              ),
            ),
          ),
        ],
      ) : Stack(
        children: [
          Positioned(
            bottom: 0,
            right: 0,
            child: FloatingActionButton(
              heroTag: "postItem",
              onPressed: _navigateToPostScreen,
              tooltip: 'Post Item',
              child: const Icon(Icons.add),
            ),
          ),
          Positioned(
            bottom: 70,
            right: 0,
            child: FloatingActionButton(
              backgroundColor: isShowMyItems ? Theme.of(context).colorScheme.inversePrimary : Theme.of(context).colorScheme.primaryContainer,
              heroTag: "myItems",
              onPressed: (){
                _search.clear();
                search = "";
                selectedChoices.clear();
                _showMyItems();
              },
              tooltip: 'My Items',
              child: isShowMyItems ? const Icon(Icons.home) : const Icon(Icons.perm_contact_cal_outlined),
            ),
          )

        ],
      ),
    );
  }
}

Future<String> getUserToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_token') ?? '';
}
