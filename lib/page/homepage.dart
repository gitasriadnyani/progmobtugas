import 'package:cobaapi/page/profile_page.dart';
import 'package:cobaapi/page/userlist.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';

class UserDataPage extends StatelessWidget {
  final Dio _dio = Dio();
  final GetStorage _storage = GetStorage();
  final String _apiUrl = 'https://mobileapis.manpits.xyz/api';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simpan Pinjam', style: TextStyle(fontFamily: 'Poppins')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfilePage()));
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UsersList()),
                );
              },
              child: const Text(
                'Get Anggota',
                style: TextStyle(
                  fontFamily: 'Poppins',
                ),
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
            try {
              final _response = await _dio.get(
                '$_apiUrl/user',
                options: Options(
                  headers: {
                    'Authorization': 'Bearer ${_storage.read('token')}'
                  },
                ),
              );
              print(_response.data);
            } on DioError catch (e) {
              print('${e.response} - ${e.response?.statusCode}');
            }
          } else if (index == 2) {
            try {
              final _response = await _dio.get(
                '$_apiUrl/logout',
                options: Options(
                  headers: {
                    'Authorization': 'Bearer ${_storage.read('token')}'
                  },
                ),
              );
              print(_response.data);
              _storage.remove('token');
              Navigator.pushReplacementNamed(context, '/login');
            } on DioError catch (e) {
              print('${e.response} - ${e.response?.statusCode}');
            }
          }
        },
      ),
    );
  }
}
