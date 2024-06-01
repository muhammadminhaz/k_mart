import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:k_mart/constants/categories.dart';
import 'package:k_mart/models/Item.dart';
import 'package:uuid/uuid.dart';

import 'home.dart';

String uuid = "";

class PostScreen extends StatefulWidget {
  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            CupertinoIcons.back,
            color: Colors.black, size: 30,
          ),
        ),
        title: const Text("Post Your Item"),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              Upload()
            ],
          ),
        ),
      ),
    );
  }
}

class Upload extends StatefulWidget {
  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController _name = TextEditingController();
  TextEditingController _condition = TextEditingController();
  TextEditingController _description = TextEditingController();
  TextEditingController _price = TextEditingController();
  TextEditingController _contact = TextEditingController();

  GlobalKey<FormState> key = GlobalKey();

  List<XFile> images = [];
  List<String> imageUrls = [];
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  pickImages() async {
    final pickImages = ImagePicker();
    images = await pickImages.pickMultiImage(
        requestFullMetadata: false, imageQuality: null);
    setState(() {
      this.images = images;
      uploadText = "Clear";
    });
  }

  void clearImages() {
    setState(() {
      images.clear();
      imageUrls.clear();
      uploadText = "Select";
    });
  }

  String uploadText = "Select";


  Future<void> uploadImagesToStorage(List<XFile> images, String uuid) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference reference = storage.ref();
    
    for(int i = 0; i < images.length; i++) {
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String imagePath = images[i].path;

      final UploadTask uploadTask = reference
          .child("images/$uuid")
          .child(timestamp + i.toString())
          .putFile(File(imagePath));

      final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      final String imageUrl = await taskSnapshot.ref.getDownloadURL();
      imageUrls.add(imageUrl);
    }
  }

  Future<void> uploadDataToFirestore(Item item) async {

    CollectionReference dataCollection =
        FirebaseFirestore.instance.collection('items');
    await dataCollection
        .add(item.toJson())
        .whenComplete(() => Fluttertoast.showToast(msg: "Item Uploaded"));
  }

  String _selectedDropdownValue = "";


  String _userToken = 'Unknown';

  @override
  void initState() {
    super.initState();
    initToken();
  }

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


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Form(
        key: key,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            images.isEmpty
                ? Padding(
                    padding:
                        const EdgeInsets.only(left: 12.0, bottom: 12, top: 6),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GestureDetector(
                          onTap: pickImages,
                          child: Image.asset(
                            'assets/images/no_image.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal, child: imageRow(images)),
            Center(
                child: ElevatedButton(
                    onPressed: uploadText == "Clear" ? clearImages : pickImages, child: Text("$uploadText Image(s)"))),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: "Name",
                  hintText: "Give the name of this item",
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "This box cannot be empty";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _description,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: "Description",
                  hintText: "Give the description of this item",                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "This box cannot be empty";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _condition,
                decoration: const InputDecoration(
                  labelText: "Condition",
                  hintText: "e.g. New, Used",
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "This box cannot be empty";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _price,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: "Price (SR)",
                  hintText: "e.g. 1000",
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "This box cannot be empty";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                value: _selectedDropdownValue == ""
                    ? categories[0]
                    : _selectedDropdownValue,
                onChanged: (newValue) {
                  _selectedDropdownValue = newValue!;
                },
                items: categories.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _contact,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Contact No.",
                  hintText: "e.g. +966012345678",                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "This box cannot be empty";
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () async {
                if(images.isEmpty) {
                  Fluttertoast.showToast(msg: "Please select image(s)");
                  return;
                }
                if (key.currentState!.validate()) {
                  String name = capitalize(_name.text);
                  String condition = _condition.text;
                  String description = _description.text;
                  String price = _price.text;
                  String contact = _contact.text;
                  String category = _selectedDropdownValue == ""
                      ? categories[0]
                      : _selectedDropdownValue;
                  uuid = const Uuid().v4();
                  DateTime currentDate = DateTime.now();
                  DateTime expirationDate = currentDate.add(const Duration(days: 30));
                  Timestamp expirationTimestamp = Timestamp.fromDate(expirationDate);

                  Item item = Item(
                      userToken: _userToken,
                      id: uuid,
                      name: name,
                      imageUrls: imageUrls,
                      description: description,
                      contact: contact,
                      condition: condition,
                      category: category,
                      expirationTimestamp: expirationTimestamp,
                      price: price);

                  showItemId(item, images, uuid);
                 // Navigator.of(context).pop();
                }
              },
              child: Container(
                width: 100,
                height: 100,
                child: Icon(
                  Icons.upload,
                  size: 60,
                  color: Colors.grey[800],
                ),
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.shade600,
                          offset: const Offset(4, 4),
                          blurRadius: 15,
                          spreadRadius: 1),
                      const BoxShadow(
                          color: Colors.white,
                          offset: Offset(-4, -4),
                          blurRadius: 15,
                          spreadRadius: 1)
                    ],
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey.shade200,
                          Colors.grey.shade300,
                          Colors.grey.shade400,
                          Colors.grey.shade500,
                        ],
                        stops: const [
                          0.1,
                          0.3,
                          0.8,
                          0.9
                        ])),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Row imageRow(List<XFile> images) {
    List<Widget> widgets = [];
    for (int i = 0; i < images.length; i++) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(left: 12.0, bottom: 12, top: 6),
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(images[i].path),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ));
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: widgets,
    );
  }

  showItemId(item, images, uuid) {
    return showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure you want to upload this item?', style: TextStyle(fontSize: 16),),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                uploadImagesToStorage(images, uuid).whenComplete(() => uploadDataToFirestore(item));
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            )
          ],
        );
      },
    );
  }
}

String capitalize(String str) => str[0].toUpperCase() + str.substring(1);
