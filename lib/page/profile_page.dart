// profile_page.dart
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final Future<dynamic> Function(BuildContext) getUserFunction;

  const ProfilePage({Key? key, required this.getUserFunction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserFunction(context),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final userData = snapshot.data['data'] as Map<String, dynamic>;
          final email = userData['email'];
          final name = userData['name'];

          return Scaffold(
            appBar: AppBar(
              title: Text('Profile'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Email: $email'),
                  Text('Name: $name'),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
