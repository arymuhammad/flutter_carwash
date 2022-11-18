import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../helper/alert.dart';

class ServicesController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var id = 0;
  TextEditingController nama = TextEditingController();
  TextEditingController harga = TextEditingController();

  Stream<QuerySnapshot<Object?>> getServices() {
    CollectionReference services = firestore.collection("services");
    return services.orderBy("id", descending: false).snapshots();
  }

  @override
  void onClose() {
    super.onClose();
    nama.dispose();
    harga.dispose();
  }

  addService(int id, String nama, int harga) async {
    CollectionReference services = firestore.collection("services");
    try {
      await services.add({"id": id, "nama": nama, "harga": harga});
      Get.defaultDialog(
          barrierDismissible: false,
          radius: 5,
          title: 'Sukses',
          middleText: 'Berhasil menambahkan data',
          onConfirm: () {
            Get.back();
          },
          textConfirm: 'OK',
          confirmTextColor: Colors.white);
    } catch (e) {}
  }

  updateService(id, String nama, int harga) async {
    DocumentReference services = firestore.collection("services").doc(id);
    try {
      await services.update({"nama": nama, "harga": harga});
      Get.defaultDialog(
          barrierDismissible: false,
          radius: 5,
          title: 'Sukses',
          middleText: 'Data berhasil diupdate',
          onConfirm: () {
            Get.back();
          },
          textConfirm: 'OK',
          confirmTextColor: Colors.white);
    } catch (e) {}
  }

  deleteService(String id) async {
    DocumentReference service = firestore.collection("services").doc(id);
    try {
      await service.delete();
      Get.back();
      Get.defaultDialog(
        barrierDismissible: false,
        radius: 5,
        title: 'Sukses',
        middleText: 'Berhasil menghapus data',
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back();
        },
        textConfirm: 'OK',
      );
      await showSnackbar("Sukses", "Data Berhasil di Hapus");
    } catch (e) {}
  }
}
