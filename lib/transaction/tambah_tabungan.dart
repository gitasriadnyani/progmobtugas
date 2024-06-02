import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class AddTabungan extends StatefulWidget {
  const AddTabungan({super.key});

  @override
  State<AddTabungan> createState() => _AddTabunganState();
}

class _AddTabunganState extends State<AddTabungan> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _transactionNominalController =
      TextEditingController();

  List<Map<String, dynamic>> _transactionTypes = [];
  int? id;
  int? _selectedTransactionID;

  final _dio = Dio();
  final _storage = GetStorage();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';

  bool _isInitialized = false;

  Future<void> fetchJenisTransaksi() async {
    try {
      final _response = await _dio.get(
        '$_apiUrl/jenistransaksi',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      Map<String, dynamic> responseData = _response.data;
      if (responseData['success']) {
        setState(() {
          _transactionTypes = List<Map<String, dynamic>>.from(
              responseData['data']['jenistransaksi']);
        });
      }
    } catch (e) {
      print('Error fetching transaction types: $e');
    }
  }

  Future<void> addSaving() async {
    try {
      final _response = await _dio.post(
        '$_apiUrl/tabungan',
        data: {
          'anggota_id': id,
          'trx_id': _selectedTransactionID,
          'trx_nominal': int.parse(_transactionNominalController.text)
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_storage.read('token')}'
          },
        ),
      );
      Map<String, dynamic> responseData = _response.data;
      print(responseData);
      setState(() {
        if (responseData['success']) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Tabungan berhasil ditambahkan!",
                      style: TextStyle(fontFamily: 'Poppins')),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("OK",
                          style: TextStyle(fontFamily: 'Poppins')),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/tabungan', (route) => false);
                      },
                    ),
                  ],
                );
              });
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(responseData['message'],
                      style: const TextStyle(fontFamily: 'Poppins')),
                  content: const Text('Wait...',
                      style: TextStyle(fontFamily: 'Poppins')),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("OK",
                          style: TextStyle(fontFamily: 'Poppins')),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/tabungan', (route) => false);
                      },
                    ),
                  ],
                );
              });
        }
      });
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title:
                  const Text("Oops!", style: TextStyle(fontFamily: 'Poppins')),
              content: Text(e.response?.data['message'] ?? 'An error occurred',
                  style: const TextStyle(fontFamily: 'Poppins')),
              actions: <Widget>[
                TextButton(
                  child:
                      const Text("OK", style: TextStyle(fontFamily: 'Poppins')),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        id = args;
      }
      _isInitialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchJenisTransaksi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          title: const Text(
            'Tambah Tabungan',
            style: TextStyle(fontFamily: 'Poppins'),
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
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 10),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DropdownButtonFormField<int>(
                      value: _selectedTransactionID,
                      onChanged: (value) {
                        setState(() {
                          _selectedTransactionID = value;
                        });
                      },
                      items: _transactionTypes.map((transaction) {
                        return DropdownMenuItem<int>(
                          value: transaction['id'],
                          child: Text(transaction['trx_name'],
                              style: const TextStyle(fontFamily: 'Poppins')),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Pilih Jenis Transaksi',
                        labelStyle: TextStyle(fontFamily: 'Poppins'),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null
                          ? 'Silakan pilih jenis transaksi'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _transactionNominalController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CurrencyFormatter(),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Nominal Transaksi',
                        labelStyle: TextStyle(fontFamily: 'Poppins'),
                        // prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silakan masukkan nominal transaksi';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Nominal harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 50),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState?.save();
                                addSaving();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink[100],
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text(
                              'Tambah Tabungan',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}

class CurrencyFormatter extends TextInputFormatter {
  final NumberFormat _numberFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp.');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final num? parsed = int.tryParse(newValue.text);
    if (parsed == null) {
      return oldValue;
    }

    final String newString = _numberFormat
        .format(parsed)
        .substring(0, _numberFormat.format(parsed).length - 3);
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}
