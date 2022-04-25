import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  /*user info*/
  final String uid;
  final String username;
  final String photoPath;

  /*place type*/
  final String country;
  final String city;
  final String categories;
  final String type;

  /*place info*/
  final String postId;
  final String name;
  final String address;
  final double rating;

  /*visibility*/
  final String visibility;

  /*date*/
  final DateTime datePublished;
  final DateTime dateVisit;

  /*content*/
  final String title;
  final List<String> bodies;
  final List<String> imgsPath;

  /*likes*/
  final likes;

  const Post(
      {
        /*user info*/
        required this.uid,
        required this.username,
        required this.photoPath,

        /*place type*/
        required this.country,
        required this.city,
        required this.categories,
        required this.type,

        /*place info*/
        required this.postId,
        required this.name,
        required this.address,
        required this.rating,

        /*visibility*/
        required this.visibility,

        /*date*/
        required this.datePublished,
        required this.dateVisit,

        /*content*/
        required this.title,
        required this.bodies,
        required this.imgsPath,

        /*likes*/
        required this.likes,
      });

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
      /*user info*/
      uid: snapshot["uid"],
      username: snapshot["username"],
      photoPath: snapshot["photoPath"],

      /*place type*/
      country: snapshot["country"],
      city: snapshot["city"],
      categories: snapshot["categories"],
      type: snapshot["type"],

      /*place info*/
      postId: snapshot["postId"],
      name: snapshot["name"],
      address: snapshot["address"],
      rating: snapshot["rating"],

      /*visibility*/
      visibility: snapshot["visibility"],

      /*date*/
      datePublished: snapshot["datePublished"],
      dateVisit: snapshot["dateVisit"],

      /*content*/
      title: snapshot["title"],
      bodies: snapshot["bodies"],
      imgsPath: snapshot["imgsPath"],

      /*likes*/
      likes: snapshot["likes"],
    );
  }

  Map<String, dynamic> toJson() => {
    /*user info*/
    "uid": uid,
    "username": username,
    "photoPath": photoPath,

    /*place type*/
    "country": country,
    "city": city,
    "categories": categories,
    "type": type,

    /*place info*/
    "postId": postId,
    "name": name,
    "address": address,
    "rating": rating,

    /*visibility*/
    "visibility": visibility,

    /*date*/
    "datePublished": datePublished,
    "dateVisit": dateVisit,

    /*content*/
    "title": title,
    "bodies": bodies,
    "imgsPath": imgsPath,

    /*likes*/
    "likes": likes,
  };
}