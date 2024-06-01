import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:k_mart/models/Item.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailPage extends StatelessWidget {
  final Item item;
  final String userToken;

  ItemDetailPage({required this.item, required this.userToken});

  TextEditingController _textFieldController = TextEditingController();

  void updateSalesNumber() async {
    final itemRef = FirebaseFirestore.instance
        .collection('sales')
        .doc('deleted_items_number');

    final itemData = await itemRef.get();
    var data = itemData.data() as Map<String, dynamic>;

    final salesNumber = data['Count'];

    final updatedSalesNumber = salesNumber + 1;

    await itemRef.update({'Count': updatedSalesNumber});
  }

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String directoryPath = "images/"; // Replace with your directory path

  Future<void> deleteDirectory() async {
    try {
      ListResult result = await _storage.ref("images/${item.id}").listAll();
      for (Reference ref in result.items) {
        await ref.delete();
      }
      print('Directory deleted successfully.');
    } catch (e) {
      print('Error deleting directory: $e');
    }
  }

  Future<void> _showInputDialog(BuildContext context) async {
    return showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Item Deletion'),
          content: Text("Are you sure you want to delete this item?"),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () async {
                print(item.id);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                FirebaseFirestore firestore = FirebaseFirestore.instance;
                CollectionReference collection = firestore.collection('items');

                QuerySnapshot snapshot =
                    await collection.where('Id', isEqualTo: item.id).get();

                for (var doc in snapshot.docs) {
                  doc.reference.delete();
                  updateSalesNumber();
                }
                deleteDirectory();
                Fluttertoast.showToast(msg: "This item will be deleted");
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Timestamp timestamp = item.expirationTimestamp;
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
    DateTime currentDate = DateTime.now();
    Duration difference = dateTime.difference(currentDate);
    int remainingDays = difference.inDays;
    int remainingHours = difference.inHours % 24;
    showErrorDialog() {
      return showAdaptiveDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Contact Failed'),
            content: const Text('Could not contact. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Item Details'),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            CupertinoIcons.back,
            color: Colors.black,
            size: 30,
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.80,
            child: FloatingActionButton(
              onPressed: () async {
                String url = 'https://wa.me/${item.contact}';
                try {
                  if (await canLaunch(url)) {
                    await launch(url);
                  }
                } catch (e) {
                  showErrorDialog();
                }
              },
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.green,
                    ),
                    Text(
                      '${item.contact}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            )),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              child: Stack(
                children: [
                  CarouselSlider(
                      options: CarouselOptions(
                        aspectRatio: 1,
                        viewportFraction: 1.0,
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 5),
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 800),
                        autoPlayCurve: Curves.decelerate,
                        enlargeCenterPage: true,
                      ),
                      items: item.imageUrls.map((url) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Hero(
                              tag: 'item_${item.id}',
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green,
                                      Color.fromARGB(255, 29, 221, 163)
                                    ],
                                  ),
                                ),
                                width: double.infinity,
                                child: FancyShimmerImage(
                                  imageUrl: url,
                                  boxFit: BoxFit.contain,
                                  shimmerBaseColor: Colors.green,
                                  shimmerHighlightColor: Colors.greenAccent,
                                  shimmerBackColor: Colors.green.shade900,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList()),
                  item.userToken == userToken
                      ? Positioned(
                          top: 0,
                          right: 5,
                          child: ElevatedButton(
                              onPressed: () {
                                _showInputDialog(context);
                              },
                              child: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              )),
                        )
                      : Text("")
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 40, right: 14, left: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.category,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "Expires in $remainingDays days and $remainingHours hours",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${item.name} - (${item.condition})',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        'SR ${item.price}',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                  ,
                  const SizedBox(height: 8),
                  Text('Description: ${item.description}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      )
                  ),
                  SizedBox(height: 70,)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
