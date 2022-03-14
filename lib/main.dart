import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gp1_7_2022/screen/auth/signup/name.dart';
import 'package:gp1_7_2022/screen/home/Profile_Page.dart';
import 'package:firebase_core/firebase_core.dart';
/*pages */
import 'package:gp1_7_2022/screen/auth/signup_login.dart';
import 'package:gp1_7_2022/screen/auth/signup/signup.dart';
import 'package:gp1_7_2022/screen/auth/Login/login.dart';
import 'package:gp1_7_2022/screen/auth/signup/signupConfirmationCode.dart';
import 'package:gp1_7_2022/screen/auth/signup/signupPassword.dart';
import 'package:gp1_7_2022/screen/auth/signup/signupBirthday.dart';
import 'package:gp1_7_2022/screen/auth/signup/signupUsername.dart';
import 'package:gp1_7_2022/screen/auth/Login/forget_password.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
      MaterialApp(
          initialRoute: "/",
          routes: {
            "/": (context) => MainPage(),
            "/signup": (context)=> Signup(),
            '/login':(context)=>Login(),
            '/Profile_Page':(context) => Profile_page(),
            // '/confirmationCode':(context) => ConfirmationCode(),
            // '/signupPassword':(context) => signupPassword(),
            '/signupBirthday':(context) => SignupBirthday(),
            '/signupUsername':(context) => SignupUsername(),
           '/forget_password':(context) => forget_password(),
            '/name':(context) => name(),
          }
      )
  );
}
class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(snapshot.connectionState==ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }else if(snapshot.hasError){
            return const Center(child: Text("Something went wrong!"));
          }else if(snapshot.hasData){
            if(FirebaseAuth.instance.currentUser!.emailVerified){
              return const Profile_page();
            }else{
              String? x = FirebaseAuth.instance.currentUser!.email;
              String y= x??" ";
              return  ConfirmationCode(email: y);
            }
          } else{
            return const Signup_Login();

          }
        },
      ),
    );
  }
}

