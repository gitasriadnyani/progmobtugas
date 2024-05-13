import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class ProfilePage extends StatelessWidget {
  final Dio _dio = Dio();
  final GetStorage _storage = GetStorage();
  final String _apiUrl = 'https://mobileapis.manpits.xyz/api';

  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil', style: TextStyle(fontFamily: 'Poppins')),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _getUser(),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final userData = snapshot.data;
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello, ${userData?['name']}!',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('Email: ${userData?['email']}',
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 20),
                  Text('Informasi Akun:',
                      style: Theme.of(context).textTheme.titleMedium),
                  Text('ID: ${userData?['id']}',
                      style: Theme.of(context).textTheme.bodyLarge),
                  // Tambahkan informasi lainnya seperti role, tanggal join, dsb. sesuai kebutuhan
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _getUser() async {
    try {
      final Response response = await _dio.get(
        '$_apiUrl/user',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      return response.data['data']; // Mengambil data dari dalam "data"
    } catch (e) {
      throw Exception('Failed to load user data');
    }
  }
}
