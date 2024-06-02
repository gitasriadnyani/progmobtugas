import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class DetailsTabungan extends StatefulWidget {
  const DetailsTabungan({super.key});

  @override
  State<DetailsTabungan> createState() => _DetailsTabunganState();
}

class _DetailsTabunganState extends State<DetailsTabungan> {
  late final int id;
  late final String nama;
  late final int saldo;

  final _dio = Dio();
  final _storage = GetStorage();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';
  List<Map<String, dynamic>> _transactions = [];
  Map<int, String> _transactionTypes = {};
  bool _isInitialized = false;

  Future<void> getDetails() async {
    try {
      final _response = await _dio.get(
        '$_apiUrl/tabungan/$id',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      Map<String, dynamic> responseData = _response.data;
      if (responseData['success']) {
        setState(() {
          _transactions =
              List<Map<String, dynamic>>.from(responseData['data']['tabungan']);
        });
      }
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                "Oops!",
                style: TextStyle(fontFamily: 'Poppins'),
              ),
              content: Text(
                e.response?.data['message'] ?? 'An error occurred',
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    "OK",
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }

  Future<void> getJenisTransaksi() async {
    try {
      final _response = await _dio.get(
        '$_apiUrl/jenistransaksi',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      Map<String, dynamic> responseData = _response.data;
      print(responseData);
      if (responseData['success']) {
        setState(() {
          _transactionTypes = {
            for (var item in responseData['data']['jenistransaksi'])
              item['id']: item['trx_name']
          };
        });
      }
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized && ModalRoute.of(context)?.settings.arguments != null) {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      id = arguments['id'] as int;
      nama = arguments['nama'];
      saldo = arguments['saldo'];
      getDetails();
      _isInitialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    getJenisTransaksi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Row(
          children: [
            SizedBox(width: 8),
            Text(
              'Detail Tabungan',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ],
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/tabungan', (route) => false);
          },
          icon: const Icon(
            Icons.arrow_back,
            size: 32,
          ),
        ),
        actions: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(26, 94, 86, 149),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add_tabungan', arguments: id);
              },
              icon: const Icon(
                Icons.add,
                size: 32,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(26, 94, 86, 149),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _transactions.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak Ada Tabungan :) \nAyo Nabung!!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = _transactions[index];
                          final transactionType =
                              _transactionTypes[transaction['trx_id']] ??
                                  'Unknown';
                          return ListTile(
                            title: Text(
                              NumberFormat.currency(
                                      locale: 'id_ID', symbol: 'Rp.')
                                  .format(transaction['trx_nominal']),
                              style: TextStyle(fontFamily: 'Poppins'),
                            ),
                            trailing: Text(
                              transactionType,
                              style: TextStyle(fontFamily: 'Poppins'),
                            ),
                            subtitle: Text(
                              DateFormat('dd MMMM yyyy – kk:mm').format(
                                  DateTime.parse(transaction['trx_tanggal'])),
                              style: TextStyle(fontFamily: 'Poppins'),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
