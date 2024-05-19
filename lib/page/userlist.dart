import 'package:cobaapi/page/useradd.dart';
import 'package:cobaapi/page/userdetails.dart';
import 'package:flutter/material.dart';

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
  final Future<AnggotaDatas?> Function(BuildContext) getAnggotaFunction;
  final Function delAnggotaFunction;

  const UsersList({
    required this.getAnggotaFunction,
    required this.delAnggotaFunction,
  });

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  AnggotaDatas? anggotaDatas;

  @override
  void initState() {
    super.initState();
    _loadAnggota();
  }

  Future<void> _loadAnggota() async {
    final data = await widget.getAnggotaFunction(context);
    setState(() {
      anggotaDatas = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Anggota',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/user_data', (route) => false);
          },
          icon: Icon(
            Icons.arrow_back,
            size: 32,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadAnggota,
            icon: const Icon(
              Icons.refresh,
              size: 32,
            ),
          ),
          SizedBox(width: 16),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/add_user');
            },
            icon: const Icon(
              Icons.add,
              size: 32,
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
                  ? Text("Tak de Anggota la :(")
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
                                  widget.delAnggotaFunction(
                                      context, anggota.id);
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
