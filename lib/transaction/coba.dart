// ignore_for_file: prefer_const_constructors, avoid_print, deprecated_member_use, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, unused_local_variable

// import 'package:cobaapi/transaction/listtabungan.dart';
import 'package:cobaapi/user/userlist.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_application/view/transactionView/add_transaksi.dart';
// import 'package:flutter_application/view/userView/list_anggota.dart';
import 'package:get_storage/get_storage.dart';

class TransactionAnggotaList extends StatefulWidget {
  const TransactionAnggotaList({super.key});

  get memberId => null;

  @override
  State<TransactionAnggotaList> createState() => _TransactionAnggotaListState();
}

class _TransactionAnggotaListState extends State<TransactionAnggotaList> {
  AnggotaDatas? anggotaDatas;
  final _dio = Dio();
  final myStorage = GetStorage();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';

  Future<void> getAnggota() async {
    try {
      final _response = await _dio.get(
        '$_apiUrl/anggota',
        options: Options(
          headers: {'Authorization': 'Bearer ${myStorage.read('token')}'},
        ),
      );
      Map<String, dynamic> responseData = _response.data;
      setState(() {
        anggotaDatas = AnggotaDatas.fromJson(responseData);
      });
    } on DioError catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    }
  }

  void getJenisTransaksi(BuildContext context) async {
    const int MULTIPLIER_DEBIT = 1;
    const int MULTIPLIER_CREDIT = -1;

    try {
      final _response = await Dio().get(
        '$_apiUrl/jenistransaksi',
        options: Options(
          headers: {'Authorization': 'Bearer ${myStorage.read('token')}'},
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
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
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
                            transaction['trx_name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'ID: ${transaction['id']}',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          trailing: Text(
                            'Multiplier: ${transaction['trx_multiply'] == MULTIPLIER_DEBIT ? "Debit" : "Credit"}',
                            style: TextStyle(
                              color: Colors.grey,
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
                        child: Text(
                          'Tutup',
                          style: TextStyle(
                            color: Colors.pink,
                            fontWeight: FontWeight.bold,
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
    _fetchTransactions();
  }

  void _fetchTransactions() async {
    List<Map<String, dynamic>> _transactions = [];
    final _dio = Dio();
    final myStorage = GetStorage();
    const _apiUrl = 'https://mobileapis.manpits.xyz/api';

    try {
      final response = await Dio().get(
        '$_apiUrl/tabungan/${widget.memberId}',
        options: Options(
          headers: {'Authorization': 'Bearer ${myStorage.read('token')}'},
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _transactions = List<Map<String, dynamic>>.from(
              response.data['data']['tabungan']);
          print(response.data['data']['tabungan']);
        });
      } else {
        print('Failed to load transactions');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 68),
              child: anggotaDatas == null || anggotaDatas!.anggotaDatas.isEmpty
                  ? const Text("Belum ada anggota")
                  : ListView.builder(
                      itemCount: anggotaDatas!.anggotaDatas.length,
                      itemBuilder: (context, index) {
                        final anggota = anggotaDatas!.anggotaDatas[index];
                        return ListTile(
                          title: Text(anggota.nama),
                          subtitle: Row(
                            children: [
                              const Icon(Icons.phone, size: 14),
                              const SizedBox(width: 6),
                              Text(anggota.telepon),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.wallet,
                                    color: Colors.pink),
                                onPressed: () {
                                  _SaldoTabungan(context, anggota.id);
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.info, color: Colors.pink),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TransactionDetailPage(
                                              memberId: anggota.id),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.pink),
                                onPressed: () {
                                  // Navigate to add transaction page with anggota ID
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => AddTransactionPage(anggotaId: anggota.id),
                                  //   ),
                                  // );
                                },
                              ),
                            ],
                          ),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.account_circle,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          // Floating Action Button
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                getJenisTransaksi(context);
              },
              child: const Icon(Icons.list,
                  color: Colors.pink), // Ganti ikon dengan ikon yang sesuai
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: non_constant_identifier_names
void _SaldoTabungan(BuildContext context, int anggotaId) async {
  try {
    final _dio = Dio();
    final myStorage = GetStorage();
    const _apiUrl = 'https://mobileapis.manpits.xyz/api';
    final _response = await Dio().get(
      '$_apiUrl/saldo/$anggotaId',
      options: Options(
        headers: {'Authorization': 'Bearer ${myStorage.read('token')}'},
      ),
    );

    print(_response.data);

    if (_response.statusCode == 200) {
      final saldo = _response.data['data']['saldo'];

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Saldo Tabungan'),
            content: Text('Saldo Anda sebesar Rp $saldo'),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Tutup',
                  style: TextStyle(
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  } on DioException catch (e) {
    print('Dio error: $e');
  } catch (error) {
    print('Error: $error');
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
