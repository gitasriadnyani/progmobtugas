import 'package:cobaapi/page/useredit.dart';
import 'package:flutter/material.dart';

class UserDetail extends StatelessWidget {
  final anggota;

  const UserDetail({required this.anggota});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Anggota'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nomor Induk: ${anggota.nomor_induk}'),
            SizedBox(height: 10),
            Text('Nama: ${anggota.nama}'),
            SizedBox(height: 10),
            Text('Alamat: ${anggota.alamat}'),
            SizedBox(height: 10),
            Text('Tanggal Lahir: ${anggota.tgl_lahir}'),
            SizedBox(height: 10),
            Text('Telepon: ${anggota.telepon}'),
            ElevatedButton(
              onPressed: () {
                // Navigasi ke halaman EditUser dengan membawa data anggota
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditUser(anggota: anggota),
                  ),
                );
              },
              child: Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }
}
