import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/laporan_keuangan_controller.dart';

class LaporanKeuanganView extends GetView<LaporanKeuanganController> {
  const LaporanKeuanganView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LaporanKeuanganView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'LaporanKeuanganView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
