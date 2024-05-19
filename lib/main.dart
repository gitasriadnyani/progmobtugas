import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import 'package:cobaapi/page/login_page.dart';
import 'package:cobaapi/page/userlist.dart';
import 'package:cobaapi/page/homepage.dart';
import 'package:cobaapi/page/profile_page.dart';
import 'package:cobaapi/page/signup_page.dart';
import 'package:cobaapi/page/useradd.dart';

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
        '/user_data': (context) =>
            UserDataPage(getUserFunction: _getUser, logoutFunction: _logout),
        '/signup': (context) => SignUpPage(registerFunction: _goRegis),
        '/profile': (context) => ProfilePage(getUserFunction: _getUser),
        '/user_list': (context) => UsersList(
              getAnggotaFunction: getAnggota,
              delAnggotaFunction: delAnggota,
            ),
        '/add_user': (context) => AddUser()
      },
    );
  }

  //mengambil data anggota
  Future<AnggotaDatas?> getAnggota(BuildContext context) async {
    try {
      final _response = await _dio.get(
        '$_apiUrl/anggota',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      Map<String, dynamic> responseData = _response.data;
      print(responseData);
      return AnggotaDatas.fromJson(responseData);
    } on DioError catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
      return null;
    }
  }

  //menghapus anggota (satu doang)
  Future<void> delAnggota(BuildContext context, int id) async {
    try {
      final _response = await _dio.delete(
        '$_apiUrl/anggota/$id',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Anggota sudah dihapus.'),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      Navigator.pushReplacementNamed(context, '/user_list');
    } on DioError catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    }
  }

  //loginssss
  Future<void> _performLogin(
      BuildContext context, String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      _showDialog(context, 'Peringatan', 'Mohon isi semua data dengan benar');
      return;
    }

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
      Navigator.pushReplacementNamed(context, '/user_data');
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

  //ngambil data user (cuma masih belum jalan gatau gabisa bisa)
  Future<void> _getUser(BuildContext context) async {
    try {
      final response = await _dio.get(
        '$_apiUrl/user',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      print(response.data);
      return response.data;
    } on DioError catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    }
  }

  //yeayy logout
  Future<void> _logout(BuildContext context) async {
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

  //biasanya kalo ada warning, dari sini dah codenya
  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
        );
      },
    );
  }
}
