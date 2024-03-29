import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:uuid/uuid.dart';

import '../../../../config/palette.dart';
import '../../../Widgets/refresh_widget.dart';
import '../../auth/signup/userInfo/photo/utils.dart';
import '../../services/firestore_methods.dart';
import '../Lists/addList.dart';
import '../UserProfile/Profile_Page.dart';
import 'ImageDisplayer.dart';
import 'comment_controller.dart';
import 'comment_screen.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Future<void> _toggleFavorite(isFavorited, favoriteCount, postID) async {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      DocumentSnapshot snap =
      await _firestore.collection('posts').doc(postID).get();
      List likes = (snap.data()! as dynamic)['likes'];

      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postID).update({
          'likes': FieldValue.arrayRemove([uid])
        });

      } else {
        await _firestore.collection('posts').doc(postID).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      print("try 1");
      print(e.toString());
    }

  }

  CommentController commentController = Get.put(CommentController());

  //to open link
  var uid = FirebaseAuth.instance.currentUser!.uid;
  var homePosts;
  var userData = [];
  var theUserData = {};
  bool _isTheUserLoaded = false;
  String phoneNumber = "";
  List<bool> _isloaded = [];
  var isContentShow = [];
  //database
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    getTheData();

    reportController = TextEditingController();
    super.initState();
  }

  /* get data method */
  getTheData() async {
    try {
      if (uid != null) {
        var userSnap =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

        /*end*/
        if (userSnap.data() != null) {
          theUserData = userSnap.data()!;
          theUserData['following'].add(uid);
          setState(() {
            _isTheUserLoaded = true;
            homePosts = FirebaseFirestore.instance
                .collection('posts')
                .orderBy("datePublished", descending: true)
                .where('uid', whereIn: theUserData['following'])
                .snapshots();
          });
        } //else
        // Navigator.of(context).popAndPushNamed('/Signup_Login');
      }
    } catch (e) {
      print("try 2");
      print(e.toString());
    }
  }

  /* get data method */
  getData(puid, index) async {
    try {
      if (puid != null) {
        var userSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(puid)
            .get();

        if (userSnap.data() != null) {
          userData[index] = (userSnap.data()!);
          setState(() {
            _isloaded[index] = true;
          });
          print("done");
        }
      }
    } catch (e) {
      print("try 3");
      print(e.toString());
    }
  }

  deletePost(String postId) async {
    try {
      String msg = await FireStoreMethods().deletePost(postId);
      if(msg =='success')
        showSnackBar(context, "post was deleted successfully!");
      print(msg);
    } catch (err) {
      print("try 4");
      print(err.toString());
    }
  }

  Future loadPost() async {
    setState(() {
      _isloaded = [];
      userData = [];
    });
    getTheData();
    setState(() {
      homePosts = FirebaseFirestore.instance
          .collection('posts')
          .orderBy("datePublished", descending: true)
          .where('uid', whereIn: theUserData['following'])
          .snapshots();
    });
    StreamBuilder(
        stream: homePosts,
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: Palette.lightgrey,
                valueColor: AlwaysStoppedAnimation<Color>(Palette.midgrey),
              ),
            );
          }

          int len = snapshot.data?.docs.length ?? 0;
          for (int i = 0; i < len; i++) {
            _isloaded.add(false);
            userData.add('');
          }
          for (int i = 0; i < len; i++) {
            if (!_isloaded[i]) {
              getData(snapshot.data!.docs[i].data()['uid'], i);
            }
          }

          return SizedBox();
        });
  }

  buildProfile(String profilePhoto, int index) {
    return SizedBox(
      width: 50,
      height: 50,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Profile_page(
                uid: userData[index]['uid'].toString(),
              ),
            ),
          );
        },
        child: Stack(children: [
          profilePhoto != "no"
              ? Positioned(
            child: Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image(
                    image: NetworkImage(profilePhoto),
                    fit: BoxFit.cover,
                  ),
                )),
          )
              :
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.8),
            radius: 25,
            child: Icon(
              Icons.account_circle_sharp,
              color: Colors.grey,
              size: 50,
            ),
          )
        ]),
      ),
    );
  }

  /*reportController*/
  late TextEditingController reportController;

  @override
  void dispose() {
    reportController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Palette.backgroundColor,
      appBar: AppBar(
        backgroundColor: Color(0x44000000),
        foregroundColor: Palette.textColor,
        elevation: 0,
        //no shadow
        automaticallyImplyLeading: false,
        //no arrow

        centerTitle: true,
        title: Text(
          "Following",
          style: TextStyle(color: Palette.backgroundColor),
        ),
      ),

      //fix overflowed error
      resizeToAvoidBottomInset: false,

      body: !_isTheUserLoaded
          ? Center(
        child: Container(
          margin: EdgeInsets.all(32),
          child: CircularProgressIndicator(
            backgroundColor: Palette.lightgrey,
            valueColor: AlwaysStoppedAnimation<Color>(Palette.midgrey),
          ),
        ),
      )
          : RefreshWidget(
        onRefresh: loadPost,
        child: StreamBuilder(
            stream: homePosts,
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Palette.lightgrey,
                    valueColor: AlwaysStoppedAnimation<Color>(Palette.midgrey),
                  ),
                );
              }

              int len = snapshot.data?.docs.length ?? 0;
              for (int i = 0; i < len; i++) {
                _isloaded.add(false);
                userData.add('');
              }
              for (int i = 0; i < len; i++) {
                if (!_isloaded[i]) {
                  getData(snapshot.data!.docs[i].data()['uid'], i);
                }
              }

              if (snapshot.data == null) {
                return Center(
                  child: Container(
                    child: Text(
                      "No posts yet!",
                      style: TextStyle(
                        color: Palette.textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              } else {
                int len = snapshot.data?.docs.length ?? 0;
                for (int i = 0; i < len; i++) {
                  isContentShow.add([]);
                }
                return PageView.builder(
                  //to make the page scroll
                  itemCount: snapshot.data?.docs.length ?? 0,
                  controller:
                  PageController(initialPage: 0, viewportFraction: 1),
                  scrollDirection: Axis.vertical, //to scroll vertically
                  itemBuilder: (context, index) {
                    int len =
                        snapshot.data!.docs[index].data()['counter'] + 1;
                    for (int i = 0; i < len; i++) {
                      isContentShow[index].add(true);
                    }
                    return PageView.builder(
                      //to make the page scroll
                      itemCount:
                      snapshot.data!.docs[index].data()['counter'] +
                          1,
                      controller: PageController(
                          initialPage: 0, viewportFraction: 1),
                      scrollDirection:
                      Axis.horizontal, //to scroll horizontally
                      itemBuilder: (context, indexIn) {

                        return indexIn == 0
                            ? InkWell(
                          onTap: () {
                            isContentShow[index][indexIn] =
                            !isContentShow[index][indexIn];
                          },
                          child: Stack(
                            children: [
                              /*image*/
                              ImageDisplayer(
                                paths: snapshot.data!.docs[index]
                                    .data()['imgsPath']
                                    .cast<String>(),
                                title: snapshot.data!.docs[index]
                                    .data()['title'],
                                index: indexIn,
                                isCover: snapshot.data!.docs[index]
                                    .data()['isCoverPage']
                                    .cast<bool>(),
                              ),
                              isContentShow[index][indexIn]
                                  ? Column(
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(children: [
                                          Expanded(
                                            child: Container(
                                              margin: EdgeInsets.fromLTRB(2, 80, 2, 0),
                                              color: Palette.backgroundColor,
                                              height: 3,
                                            ),
                                          ),
                                          for (int i = 0; i < snapshot.data!.docs[index].data()['counter']; i++)
                                            Expanded(
                                              child:
                                              Container(
                                                margin: EdgeInsets.fromLTRB(2, 80, 2, 0),
                                                color: Palette.darkGray,
                                                height: 3,
                                              ),
                                            )
                                        ]),
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: size.width - 49,
                                                  color: Colors.black.withOpacity(0.3),
                                                  padding: EdgeInsets.only(left: 15),
                                                  child: Row(
                                                    children: [
                                                      /*left*/
                                                      Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          /*title*/
                                                          snapshot.data!.docs[index].data()['imgsPath'][0] != "no"
                                                              ? Container(
                                                            width: size.width - 168, // to avoid over... problem
                                                            child: Text(
                                                              snapshot.data!.docs[index].data()['title'].toString(),
                                                              textAlign: TextAlign.left,
                                                              style: TextStyle(fontSize: 18, color: Palette.backgroundColor, fontWeight: FontWeight.bold),
                                                            ),
                                                          )
                                                              :
                                                          SizedBox(),
                                                          /*end of title*/

                                                          SizedBox(height: 5),

                                                          /*username*/
                                                          _isloaded[index]
                                                              ? InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => Profile_page(
                                                                    uid: userData[index]['uid'].toString(),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets.all(3),
                                                              color:  uid == userData[index]['uid'].toString()?Palette.link.withOpacity(0.5):Palette.link.withOpacity(0),
                                                              child: Text(
                                                                "@" + userData[index]['username'].toString(),
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: Palette.backgroundColor,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                              : Container(
                                                            width: 100,
                                                            child: LinearProgressIndicator(
                                                              minHeight: 15,
                                                              backgroundColor: Colors.black.withOpacity(0.3),
                                                              valueColor: AlwaysStoppedAnimation<Color>(Palette.midgrey),
                                                            ),
                                                          ),
                                                          /*end of username*/

                                                          SizedBox(height: 5),

                                                          /*location*/
                                                          Row(
                                                            mainAxisSize: MainAxisSize.max,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets.fromLTRB(0, 2, 2, 2),
                                                                child: const Icon(
                                                                  Icons.corporate_fare,
                                                                  size: 15,
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                              Container(
                                                                width: size.width - 90,
                                                                child: SizedBox(
                                                                  width: size.width - 90,
                                                                  child: Text(
                                                                    snapshot.data!.docs[index].data()['name'].toString(),
                                                                    style: const TextStyle(
                                                                      fontSize: 15,
                                                                      color: Colors.white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          /*end of location*/
                                                        ],
                                                      ),
                                                      /*end of left*/
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child:
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      /*right icons*/
                                                      Container(
                                                        color: Colors.black.withOpacity(0.3),
                                                        child: Column(
                                                          children: [
                                                            /**/
                                                            /*profile img*/
                                                            _isloaded[index]?
                                                            buildProfile(userData[index]['photoPath'].toString(), index) : Container(
                                                              margin: EdgeInsets.all(32),
                                                              child: CircularProgressIndicator(
                                                                backgroundColor: Palette.lightgrey,
                                                                valueColor:
                                                                AlwaysStoppedAnimation<Color>(Palette.midgrey),
                                                              ),
                                                            ),
                                                            /*end of profile img*/


                                                            //like
                                                            Row(
                                                              children: [
                                                                Container(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                  child: IconButton(
                                                                      padding: EdgeInsets.zero,
                                                                      constraints: BoxConstraints(),
                                                                      alignment: Alignment.centerRight,
                                                                      icon: (snapshot.data!.docs[index].data()['likes'].contains(FirebaseAuth.instance.currentUser!.uid)
                                                                          ? const Icon(Icons.favorite, size: 30)
                                                                          : const Icon(Icons.favorite_border, size: 30)),
                                                                      color: Palette.backgroundColor,
                                                                      onPressed: (){
                                                                        bool isFavorited = !snapshot.data!.docs[index].data()['likes'].contains(FirebaseAuth.instance.currentUser!.uid);
                                                                        int favoriteCount = snapshot.data!.docs[index].data()['likes'].length;
                                                                        String postID = snapshot.data!.docs[index].data()['postId'].toString();
                                                                        _toggleFavorite(isFavorited, favoriteCount, postID);
                                                                      }
                                                                  ),
                                                                ),
                                                                SizedBox(width: 5)
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              child: Text (snapshot.data!.docs[index].data()['likes'].length.toString(),
                                                                style: TextStyle(
                                                                    fontSize: 16,
                                                                    color: Palette.backgroundColor
                                                                ),),
                                                            ),
                                                            //end of like


                                                            SizedBox(
                                                              height: 7,
                                                            ),

                                                            /*comment*/
                                                            InkWell(
                                                              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  CommentScreen(postId:  snapshot.data!.docs[index].data()['postId'].toString() ,postUid:  snapshot.data!.docs[index].data()['uid'].toString() ,),),),
                                                              child: Icon(
                                                                Icons.comment,
                                                                size: 30,
                                                                color: Palette.backgroundColor,
                                                              ),
                                                            ),

                                                            SizedBox(
                                                              height: 4,
                                                            ),

                                                            //num of comment
                                                            SizedBox(
                                                              child: Text(snapshot.data!.docs[index].data()['numOfComments'].toString(),
                                                                style: TextStyle(
                                                                    fontSize: 16,
                                                                    color: Palette.backgroundColor
                                                                ),
                                                              ),
                                                            ),
                                                            /*end of comment*/

                                                            SizedBox(
                                                              height: 7,
                                                            ),

                                                            /*list*/
                                                            InkWell(
                                                              onTap: (){
                                                                addPostToList(snapshot.data!.docs[index].data()["postId"].toString() );
                                                              },
                                                              child: isSaved(snapshot.data!.docs[index].data()["listIds"],theUserData['listIds'])?
                                                              Icon(
                                                                Icons.playlist_add_check,
                                                                size: 30,
                                                                color: Palette.backgroundColor,
                                                              ):Icon(
                                                                Icons.playlist_add,
                                                                size: 30,
                                                                color: Palette.backgroundColor,
                                                              ),
                                                            ),

                                                            SizedBox(
                                                              height: 4,
                                                            ),

                                                            SizedBox(
                                                              child: Text (snapshot.data!.docs[index].data()['listIds'].length.toString(),
                                                                style: TextStyle(
                                                                    fontSize: 16,
                                                                    color: Palette.backgroundColor
                                                                ),),
                                                            ),
                                                            /*end of list*/

                                                            SizedBox(
                                                              height: 7,
                                                            ),



                                                            SizedBox(
                                                              height: 7,
                                                            ),


                                                            /*more*/
                                                            InkWell(
                                                              onTap: (){
                                                                onMore(snapshot.data!.docs[index].data()["postId"].toString(), snapshot.data!.docs[index].data()['uid'].toString(), snapshot.data!.docs[index].data()['datePublished'].toDate());
                                                              },
                                                              child: Icon(
                                                                Icons.more_horiz,
                                                                size: 30,
                                                                color: Palette.backgroundColor,
                                                              ),
                                                            ),
                                                            /*end of more*/

                                                          ],
                                                        ),
                                                      ),
                                                      /*end of right icons */
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              color: Colors
                                                  .black
                                                  .withOpacity(
                                                  0.3),
                                              child: Row(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal:
                                                        15),
                                                    child:
                                                    Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      children: [
                                                        SizedBox(
                                                            height: 5),
                                                        /*category */
                                                        InkWell(
                                                          onTap:
                                                              () {
                                                          },
                                                          child:
                                                          Container(
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.max,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.fromLTRB(0, 2, 2, 2),
                                                                  child: const Icon(
                                                                    Icons.folder_open,
                                                                    size: 15,
                                                                    color: Colors.white,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  snapshot.data!.docs[index].data()['type'].toString(),
                                                                  style: const TextStyle(
                                                                    fontSize: 15,
                                                                    color: Colors.white,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        /*end of category*/

                                                        SizedBox(
                                                            height: 5),

                                                        /*country*/
                                                        Row(
                                                          mainAxisSize:
                                                          MainAxisSize.max,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.fromLTRB(0, 2, 2, 2),
                                                              child: const Icon(
                                                                Icons.place_outlined,
                                                                size: 15,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: size.width - 151,
                                                              child: SizedBox(
                                                                // width: size.width - 300,
                                                                child: Text(
                                                                  snapshot.data!.docs[index].data()['country'].toString(),
                                                                  style: const TextStyle(
                                                                    fontSize: 15,
                                                                    color: Colors.white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        /*end of country*/
                                                      ],
                                                    ),
                                                  ),

                                                  /*right*/
                                                  Container(
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal:
                                                        7,
                                                        vertical:
                                                        7),
                                                    child:
                                                    Column(
                                                      // mainAxisSize: MainAxisSize.min,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      children: [
                                                        SizedBox(
                                                            height: 5),
                                                        /*rating*/
                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                          children: [
                                                            for (var i = 0; i < snapshot.data!.docs[index].data()['rating']; i++)
                                                              Icon(
                                                                Icons.star,
                                                                color: Palette.backgroundColor,
                                                                size: 18,
                                                              ),
                                                            for (var i = 0; i < (5 - snapshot.data!.docs[index].data()['rating']); i++)
                                                              Icon(
                                                                Icons.star_border,
                                                                color: Palette.backgroundColor,
                                                                size: 18,
                                                              ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                            height: 5),

                                                        /*date */
                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                          children: [
                                                            const Icon(
                                                              Icons.date_range,
                                                              size: 15,
                                                              color: Colors.white,
                                                            ),
                                                            SizedBox(width: 2),
                                                            SizedBox(
                                                              child: Text(
                                                                DateFormat('MMM yyyy').format(snapshot.data!.docs[index].data()['dateVisit'].toDate()),
                                                                style: const TextStyle(
                                                                  fontSize: 15,
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        /*end of date*/

                                                        SizedBox(
                                                            height: 60),
                                                      ],
                                                    ),
                                                  ),
                                                  /*end of right*/
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                                  : SizedBox(),
                            ],
                          ),
                        )
                            : InkWell(
                          onTap: () {
                            isContentShow[index][indexIn] =
                            !isContentShow[index][indexIn];
                          },
                          child: Stack(
                            children: [
                              /*image*/
                              ImageDisplayer(
                                paths: snapshot.data!.docs[index]
                                    .data()['imgsPath']
                                    .cast<String>(),
                                title: snapshot.data!.docs[index]
                                    .data()['title'],
                                index: indexIn,
                                isCover: snapshot.data!.docs[index]
                                    .data()['isCoverPage']
                                    .cast<bool>(),
                              ),
                              isContentShow[index][indexIn]
                                  ? Column(
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Row(children: [
                                    for (int i = 0;
                                    i <
                                        snapshot
                                            .data!
                                            .docs[
                                        index]
                                            .data()[
                                        'counter'] +
                                            1;
                                    i++)
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets
                                              .fromLTRB(2, 80,
                                              2, 0),
                                          color: i != indexIn
                                              ? Palette
                                              .darkGray
                                              : Palette
                                              .backgroundColor,
                                          height: 3,
                                        ),
                                      )
                                  ]),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize:
                                      MainAxisSize.max,
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .end,
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .end,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .end,
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .start,
                                          children: [
                                            Container(
                                              color: Colors
                                                  .black
                                                  .withOpacity(
                                                  0.3),
                                              padding: EdgeInsets
                                                  .only(
                                                  left:
                                                  15),
                                              child: Row(
                                                children: [
                                                  /*left*/
                                                  Container(
                                                    width:
                                                    size.width -
                                                        64,
                                                    child:
                                                    Column(
                                                      mainAxisSize:
                                                      MainAxisSize.min,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                      children: [
                                                        SizedBox(
                                                            height: 5),

                                                        /*username*/

                                                        InkWell(
                                                          onTap:
                                                              () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) => Profile_page(
                                                                  uid: userData[index]['uid'].toString(),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child:
                                                          Container(
                                                            color:  uid == userData[index]['uid'].toString()?Palette.link.withOpacity(0.5):Palette.link.withOpacity(0),
                                                            child: Text(
                                                              "@" + userData[index]['username'].toString(),
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: Palette.backgroundColor,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        /*end of username*/

                                                        SizedBox(
                                                            height: 5),

                                                        /*username*/
                                                        Text(
                                                          snapshot.data!.docs[index].data()['bodies'][indexIn - 1].toString(),
                                                          style:
                                                          TextStyle(
                                                            fontSize: 15,
                                                            color: Palette.backgroundColor,
                                                          ),
                                                        ),
                                                        /*end of username*/

                                                        SizedBox(
                                                          height:
                                                          70,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  /*end of left*/
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .end,
                                                children: [
                                                  /*right icons */
                                                  Container(
                                                    color: Colors.black.withOpacity(0.3),
                                                    child: Column(
                                                      children: [
                                                        /*profile img*/
                                                        buildProfile(userData[index]['photoPath'].toString(), index),

                                                        SizedBox(
                                                          height: 7,
                                                        ),

                                                        //like
                                                        Row(
                                                          children: [
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                              child: IconButton(
                                                                  padding: EdgeInsets.zero,
                                                                  constraints: BoxConstraints(),
                                                                  alignment: Alignment.centerRight,
                                                                  icon: (snapshot.data!.docs[index].data()['likes'].contains(FirebaseAuth.instance.currentUser!.uid)
                                                                      ? const Icon(Icons.favorite, size: 30)
                                                                      : const Icon(Icons.favorite_border, size: 30)),
                                                                  color: Palette.backgroundColor,
                                                                  onPressed: (){
                                                                    bool isFavorited = !snapshot.data!.docs[index].data()['likes'].contains(FirebaseAuth.instance.currentUser!.uid);
                                                                    int favoriteCount = snapshot.data!.docs[index].data()['likes'].length;
                                                                    String postID = snapshot.data!.docs[index].data()['postId'].toString();
                                                                    _toggleFavorite(isFavorited, favoriteCount, postID);
                                                                  }
                                                              ),
                                                            ),
                                                            SizedBox(width: 5)
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          child: Text (snapshot.data!.docs[index].data()['likes'].length.toString(),
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Palette.backgroundColor
                                                            ),),
                                                        ),
                                                        //end of like

                                                        SizedBox(
                                                          height: 7,
                                                        ),

                                                        /*comment*/
                                                        InkWell(
                                                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  CommentScreen(postId:  snapshot.data!.docs[index].data()['postId'].toString() ,postUid:  snapshot.data!.docs[index].data()['uid'].toString() ,),),),
                                                          child: Icon(
                                                            Icons.comment,
                                                            size: 30,
                                                            color: Palette.backgroundColor,
                                                          ),
                                                        ),

                                                        SizedBox(
                                                          height: 4,
                                                        ),

                                                        Text(
                                                          snapshot.data!.docs[index].data()['numOfComments'].toString(),
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color: Palette.backgroundColor
                                                          ),
                                                        ),
                                                        /*end of comment*/

                                                        SizedBox(
                                                          height: 7,
                                                        ),

                                                        /*list*/
                                                        InkWell(
                                                          onTap: (){
                                                            addPostToList(snapshot.data!.docs[index].data()["postId"].toString() );
                                                          },
                                                          child: isSaved(snapshot.data!.docs[index].data()["listIds"],theUserData['listIds'])?
                                                          Icon(
                                                            Icons.playlist_add_check,
                                                            size: 30,
                                                            color: Palette.backgroundColor,
                                                          ):Icon(
                                                            Icons.playlist_add,
                                                            size: 30,
                                                            color: Palette.backgroundColor,
                                                          ),
                                                        ),

                                                        SizedBox(
                                                          height: 4,
                                                        ),

                                                        SizedBox(
                                                          child: Text (snapshot.data!.docs[index].data()['listIds'].length.toString(),
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Palette.backgroundColor
                                                            ),),
                                                        ),
                                                        /*end of list*/

                                                        SizedBox(
                                                          height: 7,
                                                        ),


                                                        SizedBox(
                                                          height: 7,
                                                        ),


                                                        /*more*/
                                                        InkWell(
                                                          onTap: (){
                                                            onMore(snapshot.data!.docs[index].data()["postId"].toString(), snapshot.data!.docs[index].data()['uid'].toString(),  snapshot.data!.docs[index].data()['datePublished'].toDate());
                                                          },
                                                          child: Icon(
                                                            Icons.more_horiz,
                                                            size: 30,
                                                            color: Palette.backgroundColor,
                                                          ),
                                                        ),
                                                        /*end of more*/

                                                        SizedBox(
                                                          height: 117,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  /*end of right icons */
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                                  : SizedBox(),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              }
            }),
      ),
    );
  }

  // For adding post to list
  void addPostToList(String postId) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return  BottomSheet(
            onClosing: () {},
            builder: (BuildContext context) {
              bool b = false;
              return StatefulBuilder(
                builder: (BuildContext context, setState) =>
                    Container(
                      color: Color(0xFF737373),
                      height: (180 / 3) + 22 + 200,
                      child: Container(
                        child: addPostToListPressed(
                            postId, theUserData['listIds'], FirebaseAuth.instance.currentUser!.uid),
                        decoration: BoxDecoration(
                          color: Palette.backgroundColor,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(10),
                            topRight: const Radius.circular(10),
                          ),
                        ),
                      ),
                    ),
              );
            },
          );
        });
  }

  ListView addPostToListPressed(String postId, listIds, uid) {
    // var x = retrieveListData(listIds, uid);
    return ListView(
      children: [
        Container(
            margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Save post to...",
                  style: TextStyle(
                    color: Palette.textColor,
                    fontSize: 18,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddList(pid: postId),
                      ),
                    );
                  },
                  child: Text(
                    "+ NEW LIST",
                    style: TextStyle(
                      color: Palette.link,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                )
              ],
            )),

        //retrieve list from database
        FutureBuilder(
            future: retrieveListData(listIds, uid),
            builder: (context, snapchat) {
              if (snapchat.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Center(child: CircularProgressIndicator(
                    backgroundColor: Palette.lightgrey,
                    valueColor: AlwaysStoppedAnimation<Color>(Palette.midgrey),
                  )),
                );
              }
              if (snapchat.hasData) {
                var data = snapchat.data!;
                List<Cut> listIdTitle = [];

                try {
                  dynamic listOfLists = data;

                  listOfLists.forEach((list) {
                    print(list["uid"]);
                    bool isInList = list["postIds"].contains(postId);
                    listIdTitle.add(Cut(id: list["ListID"], title: list["Title"], isInList: isInList));
                  });

                }catch(e){
                  print("try 22");
                  print(e.toString());
                }


                return StatefulBuilder(
                    builder: (BuildContext context, setState) => Column(
                      children: listIdTitle.map((e) {
                        return ListTile(
                          onTap: () {
                            print("before");
                            print(e.isInList);
                            /*update to the the database*/
                            if(e.isInList)
                              removePostToDatabase(postId, e.id, e.title);
                            else
                              addPostToDatabase(postId, e.id, e.title);
                            setState(() {
                              e.isInList = !e.isInList;
                            });
                            print("after");
                            print(e.isInList);
                          },
                          leading: Checkbox(
                              value: e.isInList,
                              onChanged: (bool? value) {
                                if(e.isInList)
                                  removePostToDatabase(postId, e.id, e.title);
                                else
                                  addPostToDatabase(postId, e.id, e.title);
                                setState(() {
                                  e.isInList = value!;
                                });
                              }),
                          title: Text(
                            e.title,
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        );
                      }).toList(),
                    )
                );;
              } else {
                return SizedBox();
              }
            })
      ],
    );
  }

  void onMore(String postId, puid, date) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: Color(0xFF737373),
            height: 180 / 3 + 22,
            child: Container(
              child: onMorePressed(postId, puid, date),
              decoration: BoxDecoration(
                color: Palette.backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(10),
                  topRight: const Radius.circular(10),
                ),
              ),
            ),
          );
        });
  }

  Column onMorePressed(String postId, puid, date) {
    return Column(
      children: [
        Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: RichText(
              text: TextSpan(
                text: 'Date posted: ',
                style: TextStyle(
                  color: Palette.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                children: <TextSpan>[
                  TextSpan(
                      text: DateFormat('dd/MM/yyyy').format(date).toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Palette.textColor,
                        fontWeight: FontWeight.normal,
                      )),
                ],
              ),
            )),
        ListTile(
          leading: (FirebaseAuth.instance.currentUser!.uid == puid)
              ? Icon(Icons.delete)
              : Icon(Icons.flag),
          title: (FirebaseAuth.instance.currentUser!.uid == puid)
              ? Text("Delete post")
              : Text("Report post"),
          onTap: () {
            Navigator.pop(context);
            print("delete");
            if (FirebaseAuth.instance.currentUser!.uid == puid) {
              Alert(
                  context: context,
                  title: "Are you sure you want to delete your post?",
                  desc:
                  "Your post will be permanently deleted. You can't undo this action.",
                  buttons: [
                    DialogButton(
                      color: Palette.grey,
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                            color: Palette.backgroundColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    DialogButton(
                      color: Palette.red,
                      child: const Text(
                        "Delete",
                        style: TextStyle(
                            color: Palette.backgroundColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        deletePost(postId);
                        setState(() {});
                      },
                    )
                  ]).show();
            } else {
              openDialog(postId);
            }
          },
        )
      ],
    );
  }

  Future retrieveListData(listIds, uid) async {
    var listData = [];
    int counter = 0;

    try {
      if (uid != null && listIds.isNotEmpty) {
        for (int i = 0; i < listIds.length; i++) {
          var snap = await FirebaseFirestore.instance
              .collection('Lists')
              .doc(listIds[i])
              .get();

          if (snap.data() != null) {
            if (snap.data()!["uid"] == uid) {
              listData.add(snap.data()!);
            }
          }
        }
      }
    } catch (e) {
      print("try 5");
      print(e.toString());
    }

    return listData;
  }

  // Widget buildSingleCheckBox ( )

  Widget buildChekbox(
      String title, String listId, String postId, bool isClicked) =>
      ListTile(
        onTap: () {
          setState(() {
            isClicked = !isClicked;
          });
        },
        leading: Checkbox(
            value: isClicked,
            onChanged: (value) {
              setState(() {
                isClicked = !value!;
              });
              //add post id to the list postids
            }),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      );

  void addPostToDatabase(String postId, String listId, String title) async{
    /*todo add to database*/
    try {
      var uid = FirebaseAuth.instance.currentUser!.uid;
      print(uid);
      await _firestore.collection("posts").doc(postId).update({
        'listIds': FieldValue.arrayUnion([listId]),
      });
    } catch (e) {
      print("try 6");
      print(e);
    }

    try {
      var uid = FirebaseAuth.instance.currentUser!.uid;
      print(uid);
      await _firestore.collection("Lists").doc(listId).update({
        'postIds': FieldValue.arrayUnion([postId]),
      });
      Navigator.pop(context);
      showSnackBar(context, "Post has been added to "+title+" successfully!");
    } catch (e) {
      print("try 7");
      print(e);
    }
  }

  void removePostToDatabase(String postId, String listId, String title) async{

    print("postId");
    print(postId);
    print("listId");
    print(listId);

    try {
      var uid = FirebaseAuth.instance.currentUser!.uid;
      print(uid);
      await _firestore.collection("posts").doc(postId).update({
        'listIds': FieldValue.arrayRemove([listId]),
      });
      Navigator.pop(context);
      showSnackBar(context, "Post has been removed from "+title+"  successfully!");
    } catch (e) {
      print(listId);
      print(postId);
      print("try 8");
      print("something went wrong in removing post from list in post");
      print(e);
    }

    try {
      var uid = FirebaseAuth.instance.currentUser!.uid;
      print(uid);
      await _firestore.collection("Lists").doc(listId).update({
        'postIds': FieldValue.arrayRemove([postId]),
      });
    } catch (e) {
      print(listId);
      print(postId);
      print("try 9");
      print("something went wrong in removing post from list in list");
      print(e);
    }
  }



  isSaved( postListIds, userListIds) {
    //if post listIds in user listIds then true
    bool isSave = false;
    if(postListIds!= null && userListIds!= null){

      for (var ulid in userListIds) {
        /*check if the post id exist? */
        isSave = postListIds.contains(ulid);
        if(isSave){
          break;
        }
      }

    }

    return isSave;

  }


  void reportPost(String postId, String reason) async {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    String reportId = const Uuid().v1();
    try{
      String res = await FireStoreMethods().createReportPost(uid, postId, reportId,reason, DateTime.now() );
      if(res== "success"){

        showSnackBar(context, "Report has been send successfully!");
      }else{
        showSnackBar(context, res);
      }
    }catch(e){
      print("try 10");
      showSnackBar(context, e.toString());
    }
  }

  Future openDialog(String postId) {
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Report Post"),
            content: Container(
              height:96,
              child: Column(
                children: [
                  Text(
                    'Let us know more by adding a comment.',
                    style: TextStyle(
                        color: Palette.darkGray
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: reportController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Comment",
                    ),
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Palette.grey,
                  ),
                ) ,
                onPressed: (){
                  reportController.clear();
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text(
                  "Report",
                  style: TextStyle(
                    color: Palette.link,
                  ),
                ) ,
                onPressed: (){
                  reportPost(postId, reportController.text);
                  reportController.clear();
                  Navigator.pop(context);
                },
              )
            ],
          );
        }
    );
  }


}

class Cut {
  String id;
  String title;
  bool isInList;

  Cut({required this.id, required this.title, required this.isInList});
}

