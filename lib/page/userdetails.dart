import 'package:flutter/material.dart';
import 'package:cobaapi/page/useredit.dart';

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDetailItem('Nomor Induk', anggota.nomor_induk.toString()),
            _buildDetailItem('Nama', anggota.nama),
            _buildDetailItem('Alamat', anggota.alamat),
            _buildDetailItem('Tanggal Lahir', anggota.tgl_lahir),
            _buildDetailItem('Telepon', anggota.telepon),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditUser(anggota: anggota),
                    ),
                  );
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.pink[100]!),
                    minimumSize: MaterialStateProperty.all(const Size(0, 50))),
                child: const Text('Edit',
                    style: TextStyle(fontSize: 16, fontFamily: 'Poppins')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
