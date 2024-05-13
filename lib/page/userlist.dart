import 'package:cobaapi/page/useradd.dart';
import 'package:cobaapi/page/userdetails.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';

class AnggotaDatas {
  final List<Anggota> anggotaDatas;

  AnggotaDatas({required this.anggotaDatas});
  factory AnggotaDatas.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final anggota = data?['anggotas'] as List<dynamic>?;

    return AnggotaDatas(
      anggotaDatas: anggota
              ?.map((anggotaData) =>
                  Anggota.fromJson(anggotaData as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Anggota {
  final int id;
  final int nomor_induk;
  final String nama;
  final String alamat;
  final String tgl_lahir;
  final String telepon;
  final String? image_url;
  final int? status_aktif;

  Anggota({
    required this.id,
    required this.nomor_induk,
    required this.nama,
    required this.alamat,
    required this.tgl_lahir,
    required this.telepon,
    required this.image_url,
    required this.status_aktif,
  });

  factory Anggota.fromJson(Map<String, dynamic> json) {
    return Anggota(
      id: json['id'],
      nomor_induk: json['nomor_induk'],
      nama: json['nama'],
      alamat: json['alamat'],
      tgl_lahir: json['tgl_lahir'],
      telepon: json['telepon'],
      image_url: json['image_url'],
      status_aktif: json['status_aktif'],
    );
  }
}

class UsersList extends StatefulWidget {
  const UsersList();

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  AnggotaDatas? anggotaDatas;
  final _dio = Dio();
  final _storage = GetStorage();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';

  Future<void> getAnggota() async {
    try {
      final _response = await _dio.get(
        '${_apiUrl}/anggota',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      Map<String, dynamic> responseData = _response.data;
      print(responseData);
      setState(() {
        anggotaDatas = AnggotaDatas.fromJson(responseData);
      });
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    }
  }

  Future<void> delAnggota(int id) async {
    try {
      final _response = await _dio.delete(
        '${_apiUrl}/anggota/${id}',
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
          });
      getAnggota();
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    getAnggota();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getAnggota();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text('Anggota',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Color.fromARGB(255, 0, 0, 0),
                )),
        actions: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(26, 94, 86, 149),
            ),
            child: IconButton(
              onPressed: () {
                getAnggota();
              },
              icon: Icon(
                Icons.refresh,
                size: 32,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(width: 16),
          // Navigasi ke halaman AddUser saat tombol "Add" diklik
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(26, 94, 86, 149),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddUser()),
                );
              },
              icon: Icon(
                Icons.add,
                size: 32,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 68),
              child: anggotaDatas == null || anggotaDatas!.anggotaDatas.isEmpty
                  ? Text("Belum ada anggota")
                  : ListView.builder(
                      itemCount: anggotaDatas!.anggotaDatas.length,
                      itemBuilder: (context, index) {
                        final anggota = anggotaDatas!.anggotaDatas[index];
                        return ListTile(
                          title: Text(anggota.nama),
                          subtitle: Row(
                            children: [
                              Icon(Icons.phone, size: 14),
                              SizedBox(width: 6),
                              Text(anggota.telepon),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UserDetail(anggota: anggota),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.arrow_forward),
                              ),
                              IconButton(
                                onPressed: () {
                                  delAnggota(anggota.id);
                                },
                                icon: Icon(Icons.delete_outline),
                                //     leading: const CircleAvatar(
                                // backgroundImage:
                                //     AssetImage('assets/images/anggota.jpeg'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari anggota',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
