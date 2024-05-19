import 'package:cobaapi/page/profile_page.dart';
import 'package:cobaapi/page/userlist.dart';
import 'package:flutter/material.dart';

class UserDataPage extends StatelessWidget {
  final Function(BuildContext) getUserFunction;
  final Function(BuildContext) logoutFunction;

  UserDataPage({required this.getUserFunction, required this.logoutFunction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simpan Pinjam',
            style: TextStyle(fontFamily: 'Poppins')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/user_list');
              },
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.pink[100]!),
                  minimumSize: MaterialStateProperty.all(const Size(0, 50))),
              child: const Text(
                'Get Anggota',
                style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
        selectedItemColor: Colors.pink[100],
        selectedLabelStyle:
            TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontFamily: 'Poppins'),
        onTap: (int index) async {
          if (index == 1) {
            getUserFunction(context);
          } else if (index == 2) {
            logoutFunction(context);
          }
        },
      ),
    );
  }
}
