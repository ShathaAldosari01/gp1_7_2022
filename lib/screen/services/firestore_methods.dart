import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/post.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //upload post
  Future<String> uploadPost(
      /*user info*/
      String uid,


      /*place type*/
      String country,
      String city,
      List<String> categories,
      String type,
      String locationId,

      /*place info*/
      String postId,
      String name,
      String address,
      double rating,

      /*visibility*/
      String visibility,

      /*date*/
      DateTime dateVisit,

      /*content*/
      String title,
      List<String> bodies,
      List<String> imgsPath,
      List<bool> isCoverPage,
      int counter,

      ) async{
    String res = "some error occurred";
    try{

      Post post = Post(
        /*user info*/
        uid: uid,


        /*place type*/
        country: country,
        city: city,
        categories: categories,
        type: type,
        locationId: locationId,

        /*place info*/
        postId: postId,
        name: name,
        address: address,
        rating: rating,

        /*visibility*/
        visibility: visibility,

        /*date*/
        datePublished: DateTime.now(),
        dateVisit: dateVisit,

        /*content*/
        title: title,
        bodies: bodies,
        imgsPath: imgsPath,
        isCoverPage: isCoverPage,
        counter: counter,

        /*likes*/
        likes: [],
      );

      _firestore.collection("posts").doc(postId).set(
        post.toJson(),
      );
      res = "success";
    }catch(err){
      res = err.toString();
    }
    return res;
  }

  // Delete Post
  Future<String> deletePost(String postId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> followUser(
      String uid,
      String followId
      ) async {
    try {
      DocumentSnapshot snap = await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if(following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }

    } catch(e) {
      print(e.toString());
    }
  }
}