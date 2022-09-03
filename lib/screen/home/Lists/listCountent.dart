import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gp1_7_2022/screen/home/navBar/lists.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../Widgets/follow_button.dart';
import '../../../config/palette.dart';
import '../UserProfile/user-post-view.dart';
import 'editList.dart';

class ListCountent extends StatefulWidget {
  final listId;
  const ListCountent({Key? key, required this.listId}) : super(key: key);

  @override
  State<ListCountent> createState() => _ListCountentState();
}

class _ListCountentState extends State<ListCountent> {

  @override
  void initState() {
    /*get data*/
    getListData();
    userId = FirebaseAuth.instance.currentUser!.uid;
    super.initState();
  }

  getListData() async {
    try {
      if (widget.listId != null) {
        var userSnap = await FirebaseFirestore.instance
            .collection('Lists')
            .doc(widget.listId)
            .get();

        setState(() {
          listData = userSnap.data()!;
          _isloaded = true;
          tags = listData['Tags'];
        });
        getUserData(listData["uid"]);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getUserData(uid) async {
    try {
      if (uid != null) {
        var userSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        setState(() {
          userData = userSnap.data()!;
          _isUserLoaded = true;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  var userId;//the user visiting the page
  var listData = {};
  var userData = {};
  bool _isloaded  =false;
  bool _isUserLoaded = false;
  var tags = [];

  //database
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    /*size of screen*/
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        //appBar style
        elevation: 0.5,
        backgroundColor: Palette.backgroundColor,
        automaticallyImplyLeading: false, //no arrow,

        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /* make own arrow*/
            IconButton(
                icon: const Icon(
                    Icons.arrow_back,
                    color: Palette.textColor
                ),
                onPressed: () {
                  /*back page*/
                  Navigator.pop(context);
                }),

            /*more*/
            InkWell(
              onTap: (){
                onMore(widget.listId, listData["uid"]);
              },
              child: Icon(
                Icons.more_vert,
                size: 30,
                color: Palette.textColor,
              ),
            ),
            /*end of more*/

          ],
        ),
      ),

      body:Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*cover img*/
            _isloaded?
              listData["Cover"]!=""?
              /*show img*/
              Container(
                height: 100,
                width: size.width,
                child: Image(
                  image:
                  NetworkImage(listData["Cover"]),
                  fit: BoxFit.cover,
                ),
              )
              :SizedBox()
            /*loading*/
            :Container(
              margin: EdgeInsets.all(27),
              child: CircularProgressIndicator(
                backgroundColor: Palette.lightgrey,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Palette.midgrey),
              ),
            ),
            /*end of cover img*/

            SizedBox(height: 5,),

            Row(
              children: [
                /*title*/
                _isloaded?
                Container(
                  margin: EdgeInsets.fromLTRB(10, 5,2,5),
                  child: Text(
                    "${listData['Title']}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )

                : Container(
                  width: 100,
                  child: LinearProgressIndicator(
                    minHeight: 15,
                    backgroundColor: Palette.lightgrey,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(
                        Palette.midgrey),
                  ),
                ),
                /*end of title*/

                /*Access*/
                _isloaded?
                   Icon(
                       listData["Access"]?
                       Icons.public
                       :Icons.lock_outline,
                      color: Palette.textColor
                  )
                :Container(
                  margin: EdgeInsets.all(10),
                  child: CircularProgressIndicator(
                    backgroundColor: Palette.lightgrey,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Palette.midgrey),
                  ),
                ),
                /*end of access*/

              ],
            ),

            /*username of the owner of the list*/
            _isUserLoaded?
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    userData["username"],
                    style: TextStyle(
                      fontSize: 18,
                      color: Palette.darkGray,
                    ),
                  ),
                )

            :Container(
              width: 100,
              child: LinearProgressIndicator(
                minHeight: 15,
                backgroundColor: Palette.lightgrey,
                valueColor:
                AlwaysStoppedAnimation<Color>(
                    Palette.midgrey),
              ),
            ),
            /*end of username*/

            SizedBox(height: 15),

            /*des*/
            _isloaded?
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 10, 3),
              child: Text(
                listData['Description'],
                style: TextStyle(
                  fontSize: 14,
                  color: Palette.darkGray,
                ),
              ),
            )

            :Container(
              width: 100,
              child: LinearProgressIndicator(
                minHeight: 15,
                backgroundColor: Palette.lightgrey,
                valueColor:
                AlwaysStoppedAnimation<Color>(
                    Palette.midgrey),
              ),
            ),
            /*end of des*/

            /*tags*/
            _isloaded?
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 6),
                  child: Wrap(
                    children: tags.map((tag) {
                      tag = tag.substring(1);
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 3),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          color: Colors.amber.withOpacity(0.3),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            child: Text(
                              tag,
                              style: TextStyle(

                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )
            :Container(
              width: 100,
              child: LinearProgressIndicator(
                minHeight: 15,
                backgroundColor: Palette.lightgrey,
                valueColor:
                AlwaysStoppedAnimation<Color>(
                    Palette.midgrey),
              ),
            ),
            /*end of tags*/

            SizedBox(height: 10),

            /*edit/add button*/
            _isloaded?
              FollowButton(
                text: listData["uid"]==userId
                    ?'Edit List'
                    :listData["users"].contains(userId)?"Remove List":'Save List',
                // todo: check if the user already add the list if so it should say remove list
                //the way to do so is by adding list of users how add the list and check if the user are one of them.
                backgroundColor: Colors.white,
                textColor: Colors.black,
                borderColor: Colors.grey,
                function: () async {
                  /*go to edit list*/
                  if (listData["uid"]==userId)
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditList(
                                listData: listData)));
                  /*add list*/

                  else
                    //remove?
                    if (listData["users"].contains(userId)){
                      //remove user from list
                      await _firestore.collection("Lists").doc(widget.listId).update({
                        'users': FieldValue.arrayRemove([userId]),
                      });
                      //remove list from user
                      await _firestore.collection("users").doc(userId).update({
                        'listIds': FieldValue.arrayRemove([widget.listId]),
                      });

                    /*add*/
                    }else{
                      //add user in list
                      await _firestore.collection("Lists").doc(widget.listId).update({
                        'users': FieldValue.arrayUnion([userId]),
                      });
                      //add list in user
                      await _firestore.collection("users").doc(userId).update({
                        'listIds': FieldValue.arrayUnion([widget.listId]),
                      });
                    }
                },
                horizontal: (size.width / 2) - 50,
                vertical: 9,
              )
            :Container(
              width: 100,
              child: LinearProgressIndicator(
                minHeight: 15,
                backgroundColor: Palette.lightgrey,
                valueColor:
                AlwaysStoppedAnimation<Color>(
                    Palette.midgrey),
              ),
            ),
            /*end of button*/

            /*posts*/
            // _isloaded?
            // FutureBuilder(
            //   future: FirebaseFirestore.instance
            //       .collection('posts')
            //       // .orderBy("datePublished", descending: true)
            //       .where('uid',  whereIn: listData["postIds"])
            //       .get(),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const Center(
            //         child: CircularProgressIndicator(),
            //       );
            //     }
            //
            //     return GridView.builder(
            //       physics: NeverScrollableScrollPhysics(),
            //       shrinkWrap: true,
            //       itemCount: (snapshot.data! as dynamic).docs.length,
            //       gridDelegate:
            //       const SliverGridDelegateWithFixedCrossAxisCount(
            //         crossAxisCount: 3,
            //         crossAxisSpacing: 5,
            //         mainAxisSpacing: 1.5,
            //         childAspectRatio: 0.6,
            //       ),
            //       itemBuilder: (context, index) {
            //         DocumentSnapshot snap =
            //         (snapshot.data! as dynamic).docs[index];
            //
            //         return Stack(
            //           children: [
            //             Column(
            //               children: [
            //                 Container(
            //                   height: (size.width / 3) * (100 / 60) - 5.6,
            //                   color: Palette.backgroundColor,
            //                   child: snap['imgsPath'][0] != "no"
            //                       ? Image(
            //                     image:
            //                     NetworkImage(snap['imgsPath'][0]),
            //                     fit: BoxFit.cover,
            //                   )
            //                       : Center(
            //                     child: Container(
            //                       color: Palette.buttonColor,
            //                       margin: EdgeInsets.symmetric(
            //                           horizontal: 4),
            //                       padding: EdgeInsets.symmetric(
            //                           vertical: 2, horizontal: 3),
            //                       child: Text(
            //                         snap['title'],
            //                         textAlign: TextAlign.center,
            //                         style: TextStyle(
            //                           fontSize: 18,
            //                           fontWeight: FontWeight.bold,
            //                           color: Palette.textColor,
            //                         ),
            //                       ),
            //                     ),
            //                   ),
            //                 ),
            //               ],
            //             ),
            //             InkWell(
            //               onTap: () {
            //                 Navigator.push(
            //                   context,
            //                   MaterialPageRoute(
            //                     builder: userData.isNotEmpty
            //                         ? (context) => UserPost(
            //                         theUserData: userData,
            //                         uid: snap['uid'].toString(),
            //                         index: index)
            //                         : (context) => UserPost(
            //                         theUserData: null,
            //                         uid: snap['uid'].toString(),
            //                         index: index),
            //                   ),
            //                 );
            //               },
            //               child: Container(
            //                 color: Colors.black.withOpacity(0.3),
            //               ),
            //             ),
            //             Row(
            //               mainAxisAlignment: MainAxisAlignment.end,
            //               children: [
            //                 InkWell(
            //                   onTap: () {
            //                     onMorePost(
            //                         snap["postId"].toString(),
            //                         listData["uid"]);
            //                   },
            //                   child: Container(
            //                     padding:
            //                     const EdgeInsets.fromLTRB(20, 4, 0, 20),
            //                     child: Icon(
            //                       Icons.more_vert_rounded,
            //                       color: Palette.backgroundColor,
            //                       size: 18,
            //                     ),
            //                   ),
            //                 )
            //               ],
            //             ),
            //             Column(
            //               crossAxisAlignment: CrossAxisAlignment.stretch,
            //               mainAxisAlignment: MainAxisAlignment.end,
            //               children: [
            //                 InkWell(
            //                   onTap: () {
            //                     Navigator.push(
            //                       context,
            //                       MaterialPageRoute(
            //                         builder: userData.isNotEmpty
            //                             ? (context) => UserPost(
            //                             theUserData: userData,
            //                             uid: snap['uid'].toString(),
            //                             index: index)
            //                             : (context) => UserPost(
            //                             theUserData: null,
            //                             uid: snap['uid'].toString(),
            //                             index: index),
            //                       ),
            //                     );
            //                   },
            //                   child: Container(
            //                     padding: EdgeInsets.symmetric(
            //                         horizontal: 6, vertical: 7),
            //                     child: snap['imgsPath'][0] != "no"
            //                         ? Text(
            //                       snap['title'],
            //                       style: TextStyle(
            //                           color: Palette.backgroundColor,
            //                           fontWeight: FontWeight.bold),
            //                     )
            //                         : SizedBox(),
            //                   ),
            //                 ),
            //               ],
            //             )
            //           ],
            //         );
            //       },
            //     );
            //   },
            // )
            // /*loading*/
            // :Container(
            //   margin: EdgeInsets.all(27),
            //   child: CircularProgressIndicator(
            //     backgroundColor: Palette.lightgrey,
            //     valueColor: AlwaysStoppedAnimation<Color>(
            //         Palette.midgrey),
            //   ),
            // ),
            /*end post*/

          ],
        ),
      ),

    );
  }

  void onMore(String listId, luid) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: Color(0xFF737373),
            height: 180 / 3 + 22,
            child: Container(
              child: onMorePressed(listId, luid),
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

  Column onMorePressed(String listId, luid) {
    return Column(
      children: [
        SizedBox(height: 10,),
        ListTile(
          leading: (FirebaseAuth.instance.currentUser!.uid == luid)
              ? Icon(Icons.delete)
              : Icon(Icons.flag),
          title: (FirebaseAuth.instance.currentUser!.uid == luid)
              ? Text("Delete list")
              : Text("Report list"),
          onTap: () {
            Navigator.pop(context);
            print("delete");
            if (FirebaseAuth.instance.currentUser!.uid == luid) {
              Alert(
                  context: context,
                  title: "Are you sure you want to delete your list?",
                  desc:
                  "Your list will be permanently deleted. You can't undo this action.",
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
                        // deleteList(listId);
                        //to do :
                        //it should be deleted in every user who save this list
                        //users > userid > listIds > delete listId
                        //List > delete listId
                      },
                    )
                  ]).show();
            } else {
              Alert(
                context: context,
                title: "Report List",
                desc:
                "Report list will be implemented next release stay tuned!",
              ).show();
            }
          },
        )
      ],
    );
  }

  void onMorePost(String postId, puid) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: Color(0xFF737373),
            height: 180 / 3 + 22,
            child: Container(
              child: onMorePressedPost(postId, puid),
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

  Column onMorePressedPost(String postId, puid) {
    return Column(
      children: [
        ListTile(
          leading: (FirebaseAuth.instance.currentUser!.uid == puid)
              ? Icon(Icons.delete)
              : Icon(Icons.flag),
          title: (FirebaseAuth.instance.currentUser!.uid == puid)
              ? Text("Delete post from List")
              : Text("Report post"),
          onTap: () {
            Navigator.pop(context);
            print("delete");
            if (FirebaseAuth.instance.currentUser!.uid == puid) {
              Alert(
                  context: context,
                  title: "Are you sure you want to delete this post from the list?",
                  desc:
                  "The post will be permanently deleted from your list. You can't undo this action.",
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
                        //delete post from list todo
                      },
                    )
                  ]).show();
            } else {
              Alert(
                context: context,
                title: "Report Post",
                desc:
                "Report post will be implemented next release stay tuned!",
              ).show();
            }
          },
        )
      ],
    );
  }
}

