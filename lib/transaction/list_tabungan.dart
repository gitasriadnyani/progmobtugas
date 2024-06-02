import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class TabunganAnggota extends StatefulWidget {
  const TabunganAnggota({super.key});

  @override
  State<TabunganAnggota> createState() => _TransaksiAnggotaState();
}

class _TransaksiAnggotaState extends State<TabunganAnggota> {
  AnggotaDatas? anggotaDatas;
  final _dio = Dio();
  final _storage = GetStorage();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';

  Future<void> getAnggota() async {
    try {
      final _response = await _dio.get(
        '$_apiUrl/anggota',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      Map<String, dynamic> responseData = _response.data;
      print(responseData);
      setState(() {
        anggotaDatas = AnggotaDatas.fromJson(responseData);
      });
      await getSaldoAnggota();
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> getSaldoAnggota() async {
    if (anggotaDatas != null) {
      for (var anggota in anggotaDatas!.anggotaDatas) {
        try {
          final _response = await _dio.get(
            '$_apiUrl/saldo/${anggota.id}',
            options: Options(
              headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
            ),
          );
          Map<String, dynamic> responseData = _response.data;
          setState(() {
            anggota.saldo = responseData['data']['saldo'];
          });
        } on DioException catch (e) {
          print('${e.response} - ${e.response?.statusCode}');
        } catch (e) {
          print('Error: $e');
        }
      }
    }
  }

  void getJenisTransaksi(BuildContext context) async {
    const int multiplyDebit = 1;

    try {
      final _response = await Dio().get(
        '$_apiUrl/jenistransaksi',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      print(_response.data);
      if (_response.statusCode == 200) {
        final jenisTransaksi = _response.data['data']['jenistransaksi'];
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 68, 59, 59)
                          .withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Jenis Transaksi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: jenisTransaksi.length,
                      itemBuilder: (context, index) {
                        final transaction = jenisTransaksi[index];
                        return ListTile(
                          title: Text(
                            '${transaction['id']} - ${transaction['trx_name']}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                            ),
                          ),
                          subtitle: Text(
                            transaction['trx_multiply'] == multiplyDebit
                                ? "Debit"
                                : "Kredit",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20.0),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[100],
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 80),
                        ),
                        child: const Text(
                          'Oke',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    } on DioError catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    getAnggota();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tabungan',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/homepage', (route) => false);
          },
          icon: const Icon(
            Icons.arrow_back,
            size: 32,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              getJenisTransaksi(context);
            },
            icon: const Icon(
              Icons.list,
              size: 32,
            ),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: anggotaDatas == null || anggotaDatas!.anggotaDatas.isEmpty
            ? const Text(
                "Belum ada tabungan :)",
                style: TextStyle(fontFamily: 'Poppins'),
              )
            : ListView.builder(
                itemCount: anggotaDatas!.anggotaDatas.length,
                itemBuilder: (context, index) {
                  final anggota = anggotaDatas!.anggotaDatas[index];
                  return ListTile(
                    title: Text(
                      anggota.nama,
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    subtitle: Row(
                      children: [
                        // const Icon(Icons.attach_money, size: 14),
                        SizedBox(width: 6),
                        Text(
                          NumberFormat.currency(locale: 'id_ID', symbol: 'Rp.')
                              .format(anggota.saldo),
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/detail_tabungan',
                              arguments: {
                                'id': anggota.id,
                                'nama': anggota.nama,
                                'saldo': anggota.saldo,
                              },
                            );
                          },
                          icon: const Icon(Icons.more_vert),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/add_tabungan',
                              arguments: anggota.id,
                            );
                          },
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  );
                },
              ),
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
  final int nomor_induk;
  final String nama;
  final String alamat;
  final String tgl_lahir;
  final String telepon;
  final int? status_aktif;
  int saldo;

  Anggota({
    required this.id,
    required this.nomor_induk,
    required this.nama,
    required this.alamat,
    required this.tgl_lahir,
    required this.telepon,
    required this.status_aktif,
    required this.saldo,
  });

  factory Anggota.fromJson(Map<String, dynamic> json) {
    return Anggota(
      id: json['id'],
      nomor_induk: json['nomor_induk'],
      nama: json['nama'],
      alamat: json['alamat'],
      tgl_lahir: json['tgl_lahir'],
      telepon: json['telepon'],
      status_aktif: json['status_aktif'],
      saldo: 0,
    );
  }
}

class TransactionDetailPage extends StatelessWidget {
  final int memberId;

  const TransactionDetailPage({super.key, required this.memberId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Transaksi'),
      ),
      body: Center(
        child: Text('Detail Transaksi untuk anggota ID: $memberId'),
      ),
    );
  }
}
