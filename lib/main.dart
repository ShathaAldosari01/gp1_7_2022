import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gp1_7_2022/screen/auth/signup/Questions/genderQuestion.dart';
import 'package:gp1_7_2022/screen/auth/signup/userInfo/name.dart';
import 'package:gp1_7_2022/screen/auth/signup/Questions/question1.dart';
import 'package:gp1_7_2022/screen/auth/signup/Questions/question2.dart';
import 'package:gp1_7_2022/screen/auth/signup/Questions/question3.dart';
import 'package:gp1_7_2022/screen/auth/signup/Questions/question4.dart';
import 'package:gp1_7_2022/screen/auth/signup/Questions/question5.dart';
import 'package:gp1_7_2022/screen/auth/signup/userInfo/photo/photo.dart';
import 'package:gp1_7_2022/screen/home/UserProfile/EditInfo/editBio.dart';
import 'package:gp1_7_2022/screen/home/UserProfile/EditInfo/editName.dart';
import 'package:gp1_7_2022/screen/home/UserProfile/EditInfo/editUsername.dart';
import 'package:gp1_7_2022/screen/home/UserProfile/Profile_Page.dart';
import 'package:firebase_core/firebase_core.dart';
/*pages */
import 'package:gp1_7_2022/screen/auth/signup_login.dart';
import 'package:gp1_7_2022/screen/auth/signup/userAuth/signup.dart';
import 'package:gp1_7_2022/screen/auth/Login/login.dart';
import 'package:gp1_7_2022/screen/auth/signup/userAuth/signupConfirmationCode.dart';
import 'package:gp1_7_2022/screen/auth/signup/userAuth/signupPassword.dart';
import 'package:gp1_7_2022/screen/auth/signup/userInfo/signupBirthday.dart';
import 'package:gp1_7_2022/screen/auth/signup/userInfo/signupUsername.dart';
import 'package:gp1_7_2022/screen/auth/Login/forget_password.dart';
import 'package:gp1_7_2022/screen/home/UserProfile/EditInfo/editProfile.dart';
import 'package:gp1_7_2022/screen/home/UserProfile/settings.dart';
import 'package:gp1_7_2022/screen/home/addPost/location.dart';
import 'package:gp1_7_2022/screen/home/addPost/AddPostPage.dart';
import 'package:gp1_7_2022/screen/home/navBar/home_page.dart';
import 'package:gp1_7_2022/screen/home/navBar/navigationBar.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(initialRoute: "/", routes: {
    "/": (context) => MainPage(),

    /*Signup_Login*/
    '/Signup_Login': (context) => Signup_Login(),

    /*log in */
    '/login': (context) => Login(),

    /*sign up*/
    "/signup": (context) => Signup(),

    /*user info*/
    '/signupBirthday': (context) => SignupBirthday(),
    '/signupUsername': (context) => SignupUsername(),
    '/name': (context) => name(),
    '/photo': (context) => Photo(),

    /*questions*/
    '/question1': (context) => question1(),
    '/question2': (context) => question2(),
    '/question3': (context) => question3(),
    '/question4': (context) => question4(),
    '/question5': (context) => question5(),
    '/gender': (context) => GenderQuestion(),

    /*profile*/
    '/Profile_Page': (context) =>
        Profile_page(uid: FirebaseAuth.instance.currentUser!.uid),
    '/settings': (context) => settings(),

    /*edit profile*/
    '/editProfile': (context) =>
        EditProfile(uid: FirebaseAuth.instance.currentUser!.uid),
    '/editName': (context) =>
        EditName(uid: FirebaseAuth.instance.currentUser!.uid),
    '/editUsername': (context) =>
        EditUsername(uid: FirebaseAuth.instance.currentUser!.uid),
    '/editBio': (context) =>
        EditBio(uid: FirebaseAuth.instance.currentUser!.uid),

    /*navigation bar */
    '/navigationBar': (context) => navigationBar(),

    /*add location*/
    '/location':(context)=>Location(),

  }));
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String uid = "";

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null) {
      uid = FirebaseAuth.instance.currentUser!.uid;
    }
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Something wont wrong!"));
          } else if (snapshot.hasData) {
            var current = FirebaseAuth.instance.currentUser;
            if (current != null) {
              if (current.emailVerified && current.uid != null) {
                return navigationBar();
              } else {
                String? x = FirebaseAuth.instance.currentUser!.email;
                String y = x ?? " ";
                return ConfirmationCode(email: y);
              }
            } else {
              return Signup_Login();
            }
          } else {
            return Signup_Login();
          }
        },
      ),
    );
  }
}
