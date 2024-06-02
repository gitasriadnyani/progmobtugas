import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';

class ListUser extends StatefulWidget {
  final Function(BuildContext) logoutFunction;
  ListUser({required this.logoutFunction});

  @override
  State<ListUser> createState() => _ListUserState();
}

class _ListUserState extends State<ListUser> {
  AnggotaDatas? anggotaDatas;
  AnggotaDatas? filteredAnggotaDatas;
  final _dio = Dio();
  final _storage = GetStorage();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';
  int currentIndex = 1;

  //nama text editing controllernya
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getAnggota();
    //ngefilter anggota
    _searchController.addListener(_filterAnggota);
  }

  Future<void> getAnggota() async {
    try {
      final _response = await _dio.get(
        '$_apiUrl/anggota',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      final responseData = _response.data;
      setState(() {
        anggotaDatas = AnggotaDatas.fromJson(responseData);
        filteredAnggotaDatas = anggotaDatas;
      });
    } on DioError catch (e) {
      print('Error: ${e.response?.statusCode} - ${e.message}');
    }
  }

  //function filter search anggotanya, jadi hurufnya ga harus kapital atau kecil
  void _filterAnggota() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredAnggotaDatas = AnggotaDatas(
        anggotaDatas: anggotaDatas!.anggotaDatas.where((anggota) {
          final nameLower = anggota.nama.toLowerCase();
          final phoneLower = anggota.telepon.toLowerCase();
          return nameLower.contains(query) || phoneLower.contains(query);
        }).toList(),
      );
    });
  }

  Future<void> delAnggota(int id) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Hiks, ini beneran mau di hapus?'),
          actions: <Widget>[
            TextButton(
              child: Text("Batal"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.pink[300],
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text("Hapus"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.pink[300],
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed) {
      try {
        await _dio.delete(
          '$_apiUrl/anggota/$id',
          options: Options(
            headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
          ),
        );
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Anggota sudah dihapus.'),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.pink[300],
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    getAnggota(); // Refresh the list after deletion
                  },
                ),
              ],
            );
          },
        );
      } on DioError catch (e) {
        print('${e.response} - ${e.response?.statusCode}');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(
                  'Gagal menghapus anggota: ${e.response?.data['message'] ?? 'Terjadi kesalahan'}'),
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Anggota',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/add_anggota');
            },
            icon: const Icon(
              Icons.person_add_alt_rounded,
              size: 32,
            ),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          //ini search nya
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Anggota',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              //di filter anggotanya
              child: filteredAnggotaDatas == null ||
                      filteredAnggotaDatas!.anggotaDatas.isEmpty
                  ? Text("Tak de Anggota la :(")
                  : ListView.builder(
                      itemCount: filteredAnggotaDatas!.anggotaDatas.length,
                      itemBuilder: (context, index) {
                        final anggota =
                            filteredAnggotaDatas!.anggotaDatas[index];
                        return ListTile(
                          title: Text(anggota.nama,
                              style: TextStyle(fontFamily: 'Poppins')),
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
                                  Navigator.pushNamed(
                                    context,
                                    '/detail_anggota',
                                    arguments: anggota.id,
                                  );
                                },
                                icon: Icon(Icons.more_vert),
                              ),
                              SizedBox(width: 8),
                              IconButton(
                                onPressed: () {
                                  delAnggota(anggota.id);
                                },
                                icon: Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List Anggota',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
        selectedItemColor: Colors.pink[300],
        selectedLabelStyle: TextStyle(fontFamily: 'Poppins'),
        unselectedLabelStyle: TextStyle(fontFamily: 'Poppins'),
        onTap: (int index) async {
          setState(() {
            currentIndex = index;
          });
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/homepage');
          } else if (index == 2) {
            widget.logoutFunction(context);
          }
        },
      ),
    );
  }
}

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
  final int nomorInduk;
  final String nama;
  final String alamat;
  final String tglLahir;
  final String telepon;
  final String? imageUrl;
  final int? statusAktif;

  Anggota({
    required this.id,
    required this.nomorInduk,
    required this.nama,
    required this.alamat,
    required this.tglLahir,
    required this.telepon,
    this.imageUrl,
    this.statusAktif,
  });

  factory Anggota.fromJson(Map<String, dynamic> json) {
    return Anggota(
      id: json['id'],
      nomorInduk: json['nomor_induk'],
      nama: json['nama'],
      alamat: json['alamat'],
      tglLahir: json['tgl_lahir'],
      telepon: json['telepon'],
      statusAktif: json['status_aktif'],
    );
  }
}
