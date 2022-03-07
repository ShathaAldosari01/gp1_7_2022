import 'package:flutter/material.dart';
import 'package:gp1_7_2022/screen/Profile_Page.dart';
/*pages */
import 'package:gp1_7_2022/screen/auth/signup_login.dart';
import 'package:gp1_7_2022/screen/auth/signup.dart';
import 'package:gp1_7_2022/screen/auth/login.dart';

void main() {
  runApp(
      MaterialApp(
          initialRoute: "/",
          routes: {
            "/": (context) => Signup_Login(),
            "/signup": (context)=> Signup(),
            '/login':(context)=>Login(),
            '/Profile_Page':(context) => Profile_page(),

          }
      )
  );
}
