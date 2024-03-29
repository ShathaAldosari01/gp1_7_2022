import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../Widgets/refresh_widget.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../Widgets/follow_button.dart';
import '../../../config/palette.dart';
import '../../auth/signup/userInfo/photo/utils.dart';
import '../../services/firestore_methods.dart';
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

    reportController = TextEditingController();
    super.initState();

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

          tags = listData['Tags'] ?? [];
          postIds = listData['postIds'] ?? [];

          _isloaded = true;
        });
        getUserData(listData["uid"]);
      } else {
        print("no id???");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getUserData(uid) async {
    print("in getUserData");
    try {
      if (uid != null) {
        var userSnap =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

        setState(() {
          userData = userSnap.data()!;
          _isUserLoaded = true;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  deleteList(String ListID) async {
    try {
      await FireStoreMethods().deleteList(ListID);
      Navigator.pop(context);
      showSnackBar(context, "List was deleted successfully!");
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  Future updateListData() async {
    getListData();
  }

  var userId; //the user visiting the page
  var listData = {};
  var userData = {};
  bool _isloaded = false;
  bool _isUserLoaded = false;
  List<dynamic> tags = [];
  List<dynamic> postIds = [];

  //database
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /*reportController*/
  late TextEditingController reportController;

  @override
  void dispose() {
    reportController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /*size of screen*/
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        /*back page*/
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
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
                  icon: const Icon(Icons.arrow_back, color: Palette.textColor),
                  onPressed: () {
                    /*back page*/
                    Navigator.pop(context);
                  }),

              /*more*/
              InkWell(
                onTap: () {
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

        //fix overflowed error
        resizeToAvoidBottomInset: false,

        body: RefreshWidget(
          onRefresh: updateListData,
          child: ListView(children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /*cover img*/
                  _isloaded
                      ?
                  listData["Cover"] != ""
                      ?
                  /*show img*/
                  Container(
                    height: 100,
                    width: size.width,
                    child: Image(
                      image: NetworkImage(listData["Cover"]),
                      fit: BoxFit.cover,
                    ),
                  )
                      :
                  SizedBox()
                  /*loading*/
                      : Container(
                    margin: EdgeInsets.all(27),
                    child: CircularProgressIndicator(
                      backgroundColor: Palette.lightgrey,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Palette.midgrey),
                    ),
                  ),
                  /*end of cover img*/

                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      /*title*/
                      _isloaded
                          ? listData['Title'] != ""
                          ? Container(
                        margin: EdgeInsets.fromLTRB(10, 5, 2, 5),
                        child: Text(
                          "${listData['Title']}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                          : SizedBox()
                          : Container(
                        width: 100,
                        child: LinearProgressIndicator(
                          minHeight: 15,
                          backgroundColor: Palette.lightgrey,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Palette.midgrey),
                        ),
                      ),
                      /*end of title*/

                      /*Access*/
                      _isloaded
                          ? Icon(
                          listData["Access"]
                              ? Icons.public
                              : Icons.lock_outline,
                          color: Palette.textColor)
                          : Container(
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
                  _isUserLoaded
                      ? userData["username"] != ""
                      ? Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      userData["username"],
                      style: TextStyle(
                        fontSize: 18,
                        color: Palette.darkGray,
                      ),
                    ),
                  )
                      : SizedBox()
                      : Container(
                    width: 100,
                    child: LinearProgressIndicator(
                      minHeight: 15,
                      backgroundColor: Palette.lightgrey,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Palette.midgrey),
                    ),
                  ),
                  /*end of username*/

                  SizedBox(height: 15),

                  /*des*/
                  _isloaded
                      ? listData['Description'] != ""
                      ? Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 3),
                    child: Text(
                      listData['Description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Palette.darkGray,
                      ),
                    ),
                  )
                      : SizedBox()

                  /*loading*/
                      : Container(
                    width: 100,
                    child: LinearProgressIndicator(
                      minHeight: 15,
                      backgroundColor: Palette.lightgrey,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Palette.midgrey),
                    ),
                  ),
                  /*end of des*/

                  /*tags*/
                  _isloaded
                      ? tags.isNotEmpty
                      ? Container(
                    margin: EdgeInsets.symmetric(horizontal: 6),
                    child: Wrap(
                      children: tags.map((tag) {
                        if (tag.toString().length > 1)
                          tag = tag.substring(1);
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 3),
                          child: Container(
                            margin:
                            EdgeInsets.symmetric(horizontal: 4),
                            color: Colors.amber.withOpacity(0.3),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 4),
                              child: Text(
                                tag,
                                style: TextStyle(),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                      : SizedBox()
                      : Container(
                    width: 100,
                    child: LinearProgressIndicator(
                      minHeight: 15,
                      backgroundColor: Palette.lightgrey,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Palette.midgrey),
                    ),
                  ),
                  /*end of tags*/

                  SizedBox(height: 10),

                  /*edit/add button*/

                  _isloaded
                      ?

                  /* done button */
                  FirebaseAuth.instance.currentUser!.uid=="miostwrsWghrmT0qkc4Q0uhpA842"? SizedBox():
                  Container(
                    margin: EdgeInsets.symmetric(
                        vertical: 30, horizontal: 20),
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: 50.0,
                    /* button colors */
                    decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.all(Radius.circular(8.0)),
                        gradient: LinearGradient(colors: [
                          Palette.buttonColor,
                          Palette.nameColor,
                        ])),
                    /* button */
                    child: ButtonTheme(
                      height: 50.0,
                      minWidth: 350,
                      child: TextButton(
                        onPressed: () async {
                          /*go to edit list*/

                          if (listData["uid"] == userId)
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EditList(listData: listData)))
                                .then((_) {
                              // This block runs when you have returned back to the 1st Page from 2nd.
                              getListData();
                              setState(() {
                                // Call setState to refresh the page.
                              });
                            });

                          //remove list

                          else if (listData["users"].contains(userId)) {
                            //remove user from list
                            await _firestore
                                .collection("Lists")
                                .doc(widget.listId)
                                .update({
                              'users': FieldValue.arrayRemove([userId]),

                            });
                            //remove list from user
                            await _firestore
                                .collection("users")
                                .doc(userId)
                                .update({
                              'listIds':
                              FieldValue.arrayRemove([widget.listId]),
                            });
                            //remove tags to user for recommender
                            tags.forEach((tag) async {
                              await _firestore.collection("users").doc(userId).update({
                                'tags': FieldValue.arrayRemove([tag]),
                              });
                            });
                            getListData();
                          }

                          /*add*/

                          else {
                            //add user in list
                            await _firestore
                                .collection("Lists")
                                .doc(widget.listId)
                                .update({
                              'users': FieldValue.arrayUnion([userId]),
                            });
                            //add list in user
                            await _firestore
                                .collection("users")
                                .doc(userId)
                                .update({
                              'listIds':
                              FieldValue.arrayUnion([widget.listId]),
                            });
                            //add tags to user for recommender
                            tags.forEach((tag) async {
                              await _firestore.collection("users").doc(userId).update({
                                'tags': FieldValue.arrayUnion([tag]),
                              });
                            });
                            getListData();
                          }
                        },
                        child: Text(
                          listData["uid"] == userId
                              ? 'Edit List'
                              : listData["users"].contains(userId)
                              ? "Remove List"
                              : 'Save List',
                          style: TextStyle(
                            color: Palette.backgroundColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  )
                  /*end of button*/
                      : Container(
                    width: 100,
                    child: LinearProgressIndicator(
                      minHeight: 15,
                      backgroundColor: Palette.lightgrey,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Palette.midgrey),
                    ),
                  ),
                  const Divider(
                    color: Palette.darkGray,
                  ),

                  /*posts*/
                  _isloaded
                      ? postIds.isNotEmpty
                      ? FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('posts')
                        .where('postId', whereIn: postIds)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount:
                        (snapshot.data! as dynamic).docs.length,
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 1.5,
                          childAspectRatio: 0.6,
                        ),
                        itemBuilder: (context, index) {
                          DocumentSnapshot snap =
                          (snapshot.data! as dynamic).docs[index];

                          return Stack(
                            children: [
                              Column(
                                children: [
                                  Container(
                                    height: (size.width / 3) *
                                        (100 / 60) -
                                        5.6,
                                    color: Palette.backgroundColor,
                                    child:
                                    snap['imgsPath'][0] != "no"
                                        ? Image(
                                      image: NetworkImage(
                                          snap['imgsPath'][0]),
                                      fit: BoxFit.cover,
                                    )
                                        :
                                    Center(
                                      child: Container(
                                        color:
                                        Palette.buttonColor,
                                        margin: EdgeInsets
                                            .symmetric(
                                            horizontal: 4),
                                        padding: EdgeInsets
                                            .symmetric(
                                            vertical: 2,
                                            horizontal: 3),
                                        child: Text(
                                          snap['title'],
                                          textAlign:
                                          TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight:
                                            FontWeight.bold,
                                            color: Palette
                                                .textColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: userData.isNotEmpty
                                          ? (context) => UserPost(
                                        theUserData: userData,
                                        uid: snap['uid']
                                            .toString(),
                                        index: index,
                                        fromList: true,
                                        listInfo: listData,
                                      )
                                          : (context) => UserPost(
                                        theUserData: null,
                                        uid: snap['uid']
                                            .toString(),
                                        index: index,
                                        fromList: true,
                                        listInfo: listData,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  color:
                                  Colors.black.withOpacity(0.3),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      onMorePost(
                                        snap["postId"]
                                            .toString(),
                                        listData["uid"],
                                        widget.listId,
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets
                                          .fromLTRB(
                                          20, 4, 0, 20),
                                      child: Icon(
                                        Icons.more_vert_rounded,
                                        color: Palette
                                            .backgroundColor,
                                        size: 18,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                                mainAxisAlignment:
                                MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: userData.isNotEmpty
                                              ? (context) => UserPost(
                                              theUserData:
                                              userData,
                                              uid: snap['uid']
                                                  .toString(),
                                              index: index,
                                              fromList: true)
                                              : (context) => UserPost(
                                              theUserData: null,
                                              uid: snap['uid']
                                                  .toString(),
                                              index: index,
                                              fromList: true),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 7),
                                      child:
                                      snap['imgsPath'][0] != "no"
                                          ? Text(
                                        snap['title'],
                                        style: TextStyle(
                                            color: Palette
                                                .backgroundColor,
                                            fontWeight:
                                            FontWeight
                                                .bold),
                                      )
                                          :
                                      SizedBox(),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          );
                        },
                      );
                    },
                  )
                      : Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "No post has been save yet!",
                      style: TextStyle(color: Palette.darkGray),
                    ),
                  )
                  /*loading*/
                      : Container(
                    margin: EdgeInsets.all(27),
                    child: CircularProgressIndicator(
                      backgroundColor: Palette.lightgrey,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Palette.midgrey),
                    ),
                  ),
                  /*end post*/
                ],
              ),
            ),
          ]),
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
            height: 180 / 3 +6,
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

  Column onMorePressed(String ListId, luid) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        ListTile(
          leading: (FirebaseAuth.instance.currentUser!.uid == luid || FirebaseAuth.instance.currentUser!.uid=="miostwrsWghrmT0qkc4Q0uhpA842")
              ? Icon(Icons.delete)
              : Icon(Icons.flag),
          title: (FirebaseAuth.instance.currentUser!.uid == luid || FirebaseAuth.instance.currentUser!.uid=="miostwrsWghrmT0qkc4Q0uhpA842")
              ? Text("Delete list")
              : Text("Report list"),
          onTap: () {
            Navigator.pop(context);
            print("delete");
            if (FirebaseAuth.instance.currentUser!.uid == luid || FirebaseAuth.instance.currentUser!.uid=="miostwrsWghrmT0qkc4Q0uhpA842") {
              Alert(
                  context: context,
                  title: FirebaseAuth.instance.currentUser!.uid=="miostwrsWghrmT0qkc4Q0uhpA842"? "Are you sure you want to delete this list?":"Are you sure you want to delete your list?",
                  desc:FirebaseAuth.instance.currentUser!.uid=="miostwrsWghrmT0qkc4Q0uhpA842"?
                  "This list will be permanently deleted. You can't undo this action.":
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
                        deleteList(ListId);
                        //to do :
                        //it should be deleted in every user who save this list
                        //users > userid > listIds > delete listId
                        //List > delete listId
                      },
                    )
                  ]).show();
            } else {
              openDialog(ListId, true);
            }
          },
        )
      ],
    );
  }

  void onMorePost(String postId, puid, listId) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: Color(0xFF737373),
            height: 180 / 3 +22,
            child: Container(
              child: onMorePressedPost(postId, puid, listId),
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

  Column onMorePressedPost(String postId, puid, listId) {
    return Column(
      children: [
        ListTile(
          leading: (FirebaseAuth.instance.currentUser!.uid == puid)
              ? Icon(Icons.delete)
              : Icon(Icons.flag),
          title: (FirebaseAuth.instance.currentUser!.uid == puid)
              ? Text("Remove post from List")
              : Text("Report Post"),
          onTap: () async {
            Navigator.pop(context);

            if(FirebaseAuth.instance.currentUser!.uid == puid)
              Alert(
                  context: context,
                  title: "Remove",
                  desc: "Are you sure you want to remove the post from list?",
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
                        "Remove",
                        style: TextStyle(
                            color: Palette.backgroundColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        setState(() {
                          postIds.remove(postId);
                        });
                        try {
                          var uid = FirebaseAuth.instance.currentUser!.uid;
                          print(uid);
                          await _firestore
                              .collection("posts")
                              .doc(postId)
                              .update({
                            'listIds': FieldValue.arrayRemove([listId]),
                          });
                        } catch (e) {
                          print(e);
                        }

                        try {
                          var uid = FirebaseAuth.instance.currentUser!.uid;
                          print(uid);
                          await _firestore
                              .collection("Lists")
                              .doc(listId)
                              .update({
                            'postIds': FieldValue.arrayRemove([postId]),
                          });
                          showSnackBar(
                              context, "Post has been Removed successfully!");
                        } catch (e) {
                          print(e);
                        }
                      },
                    )
                  ]).show();
            else
              openDialog(postId, false);
          },
        )
      ],
    );
  }


  void reportList(String listId, String reason) async {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    String reportId = const Uuid().v1();
    try{
      String res = await FireStoreMethods().createReportList(uid, listId, reportId,reason, DateTime.now() );
      if(res== "success"){

        showSnackBar(context, "Report has been send successfully!");
      }else{
        showSnackBar(context, res);
      }
    }catch(e){
      showSnackBar(context, e.toString());
    }
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
      showSnackBar(context, e.toString());
    }
  }

  Future openDialog(String contentId, bool isList) {
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text(isList?"Report List":"Report Post" ),
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
                  if(isList)
                    reportList(contentId, reportController.text);
                  else
                    reportPost(contentId, reportController.text);
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

