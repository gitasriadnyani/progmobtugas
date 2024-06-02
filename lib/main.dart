import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';

import 'package:cobaapi/transaction/detail_tabungan.dart';
import 'package:cobaapi/transaction/list_tabungan.dart';
import 'package:cobaapi/transaction/tambah_tabungan.dart';

import 'package:cobaapi/user/userdetails.dart';
import 'package:cobaapi/user/useredit.dart';
import 'package:cobaapi/user/useradd.dart';
import 'package:cobaapi/user/userlist.dart';

import 'package:cobaapi/page/login_page.dart';
import 'package:cobaapi/page/profile_page.dart';
import 'package:cobaapi/page/homepage.dart';
import 'package:cobaapi/page/signup_page.dart';

void main() async {
  await GetStorage.init();
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final Dio _dio = Dio();
  final GetStorage _storage = GetStorage();
  final String _apiUrl = 'https://mobileapis.manpits.xyz/api';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(loginFunction: _performLogin),
        '/homepage': (context) => Homepage(logoutFunction: _logout),
        '/signup': (context) => SignUpPage(registerFunction: _goRegis),
        '/profile': (context) => const ProfilePage(),
        '/anggota': (context) => ListUser(logoutFunction: _logout),
        '/add_anggota': (context) => const TambahUser(),
        '/detail_anggota': (context) => const DetailsUser(),
        '/edit_anggota': (context) => const EditUser(),
        '/tabungan': (context) => const TabunganAnggota(),
        '/detail_tabungan': (context) => const DetailsTabungan(),
        '/add_tabungan': (context) => const AddTabungan(),
      },
    );
  }

  //loginssss
  Future<void> _performLogin(
      BuildContext context, String email, String password) async {
    try {
      final response = await _dio.post(
        '$_apiUrl/login',
        data: {
          'email': email.trim(),
          'password': password.trim(),
        },
      );
      print(response.data);
      _storage.write('token', response.data['data']['token']);
      Navigator.pushReplacementNamed(context, '/homepage');
    } on DioError catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
      _showDialog(context, 'Peringatan', 'Login gagal. Coba lagi.');
    }
  }

  //register
  Future<void> _goRegis(
      BuildContext context, String name, String email, String password) async {
    try {
      final _response = await _dio.post(
        '$_apiUrl/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );
      print(_response.data);
      _storage.write('token', _response.data['data']['token']);
      Navigator.pushReplacementNamed(context, '/login');
    } on DioError catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    }
  }

  //yeayy logout
  Future<void> _logout(BuildContext context) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData.light().copyWith(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.pink[300],
              ),
            ),
            dialogBackgroundColor: Colors.white,
            textTheme: const TextTheme(
              titleLarge: TextStyle(
                color: Colors.black,
              ),
              bodyLarge: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          child: AlertDialog(
            title: Text('Konfirmasi Logout'),
            content: Text('Apakah Anda yakin ingin logout?'),
            actions: <Widget>[
              TextButton(
                child: Text("Batal"),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text("Logout"),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          ),
        );
      },
    );

    if (confirmed) {
      try {
        final response = await _dio.get(
          '$_apiUrl/logout',
          options: Options(
            headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
          ),
        );
        print(response.data);

        _storage.remove('token');
        Navigator.pushReplacementNamed(context, '/login');
      } on DioError catch (e) {
        print('${e.response} - ${e.response?.statusCode}');
      }
    }
  }

  //biasanya kalo ada warning, dari sini dah codenya
  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(
            // Ubah warna tombol OK
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.pink[300], // Warna teks tombol OK
              ),
            ),
          ),
          child: AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }
}
