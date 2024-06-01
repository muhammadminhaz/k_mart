import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String name;
  final List imageUrls;
  final String description;
  final String condition;
  final String contact;
  final String category;
  final String price;
  final Timestamp expirationTimestamp;
  final String userToken;

  const Item({
    required this.id,
    required this.name,
    required this.imageUrls,
    required this.description,
    required this.condition,
    required this.price,
    required this.contact,
    required this.category,
    required this.expirationTimestamp,
    required this.userToken,
});

  toJson() {
    return {
      "UserToken": userToken,
      "Id": id,
      "Name": name,
      "Description": description,
      "Condition": condition,
      "Price": price,
      "ImageUrl": imageUrls,
      "Contact": contact,
      "Category": category,
      "ExpirationTimestamp": expirationTimestamp,
    };
  }
}