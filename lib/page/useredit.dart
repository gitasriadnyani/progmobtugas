import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';

class EditUser extends StatefulWidget {
  const EditUser({Key? key, required anggota}) : super(key: key);

  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nomorIndukController = TextEditingController();
  TextEditingController _namaController = TextEditingController();
  TextEditingController _alamatController = TextEditingController();
  TextEditingController _tglLahirController = TextEditingController();
  TextEditingController _noTeleponController = TextEditingController();

  Anggota? anggota;
  final _dio = Dio();
  final _storage = GetStorage();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';
  int id = 0;
  DateTime? _tglLahir;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null) {
      id = args as int;
      getDetail();
    }
  }

  Future<void> getDetail() async {
    try {
      final _response = await _dio.get(
        '$_apiUrl/anggota/$id',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      Map<String, dynamic> responseData = _response.data;
      setState(() {
        anggota = Anggota.fromJson(responseData);
        _nomorIndukController.text = anggota?.nomor_induk.toString() ?? '';
        _namaController.text = anggota?.nama ?? '';
        _alamatController.text = anggota?.alamat ?? '';
        _tglLahirController.text = anggota?.tgl_lahir ?? '';
        _noTeleponController.text = anggota?.telepon ?? '';
        //  _tglLahir = DateFormat("yyyy-MM-dd").parse(anggota?.tgl_lahir ?? '');
      });
    } on DioError catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    }
  }

  void goEditUser() async {
    try {
      final _response = await _dio.put(
        '$_apiUrl/anggota/$id',
        data: {
          'nomor_induk': _nomorIndukController.text,
          'nama': _namaController.text,
          'alamat': _alamatController.text,
          'tgl_lahir': _tglLahirController.text,
          'telepon': _noTeleponController.text,
          'status_aktif': anggota?.status_aktif
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_storage.read('token')}',
          },
        ),
      );
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Anggota berhasil diedit!"),
              content: Text('Yeay!'),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
    } on DioError catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Oops!"),
              content: Text(e.response?.data['message'] ?? 'An error occurred'),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/anggota',
                    );
                  },
                ),
              ],
            );
          });
    }
  }

  Future<void> _selectDate() async {
    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: _tglLahir ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (_picked != null) {
      setState(() {
        _tglLahir = _picked;
        _tglLahirController.text =
            "${_picked.year}-${_picked.month}-${_picked.day}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Anggota'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: _nomorIndukController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tolong masukkan nomor induk.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nomor Induk',
                      hintText: 'Masukkan nomor induk',
                      prefixIcon:
                          Icon(Icons.perm_identity, color: Color(0xFF5E5695)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _namaController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tolong masukkan nama.';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Nama',
                      hintText: 'Masukkan nama',
                      prefixIcon: Icon(Icons.face, color: Color(0xFF5E5695)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _alamatController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tolong masukkan alamat.';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Alamat',
                      hintText: 'Masukkan alamat',
                      prefixIcon: Icon(Icons.house, color: Color(0xFF5E5695)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tglLahirController,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Lahir',
                      hintText: 'Masukkan tanggal lahir',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () {
                      _selectDate();
                    },
                    validator: (value) {
                      if (_tglLahir == null) {
                        return 'Tolong masukkan tanggal lahir';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noTeleponController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tolong masukkan nomor telepon.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nomor Telepon',
                      hintText: 'Masukkan nomor telepon',
                      prefixIcon: Icon(Icons.phone, color: Color(0xFF5E5695)),
                    ),
                  ),
                  const SizedBox(height: 70),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        goEditUser();
                      }
                    },
                    child: Text('Edit Anggota'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
    final data = json['data'] as Map<String, dynamic>?;

    if (data != null) {
      final anggotaData = data['anggota'] as Map<String, dynamic>?;

      if (anggotaData != null) {
        return Anggota(
          id: anggotaData['id'],
          nomor_induk: anggotaData['nomor_induk'],
          nama: anggotaData['nama'],
          alamat: anggotaData['alamat'],
          tgl_lahir: anggotaData['tgl_lahir'],
          telepon: anggotaData['telepon'],
          image_url: anggotaData['image_url'],
          status_aktif: anggotaData['status_aktif'],
        );
      }
    }

    throw Exception('Failed to parse Anggota from JSON');
  }
}
