import 'package:cobaapi/page/login_page.dart';
// import 'package:cobaapi/page/logout_page.dart';
import 'package:cobaapi/page/homepage.dart';
import 'package:cobaapi/page/profile_page.dart';
import 'package:cobaapi/page/signup_page.dart';
// import 'package:cobaapi/page/useredit.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginPage(),
          '/user_data': (context) => UserDataPage(),
          '/signup': (context) => SignUpPage(),
          '/profile': (context) => ProfilePage(),
          // '/edituser': (context) => EditUser(anggota: null,),
          // '/logout': (context) => LogoutPage(),
        },
      ),
    );
  }
}
