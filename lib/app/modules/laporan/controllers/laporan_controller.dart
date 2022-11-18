import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LaporanController extends GetxController {
  var dateNow1 = DateFormat('yyyy-MM-dd').format(DateTime.now());
  var dateNow2 = DateFormat('yyyy-MM-dd').format(DateTime.now());
  var date1 = "".obs;
  var date2 = "".obs;
  var selectedItem = "".obs;
  var cabang = "";
  var tempSummService = [].obs;
  var tempJenisKendaraan = [].obs;
  var detailData = [].obs;
  TextEditingController dateInputAwal = TextEditingController();
  TextEditingController dateInputAkhir = TextEditingController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    getSummary(dateNow1.toString(), dateNow2.toString(), cabang, 1, 0);
  }

  Future<List<QueryDocumentSnapshot<Object?>>> getLaporan(
      date, date2, String? cabang, int? level) async {
    // print(cabang);

    if (level == 1) {
      if (cabang == "") {
        CollectionReference data = firestore.collection("transaksi");
        final snapshots = data.snapshots().map((snapshot) => snapshot.docs
            .where((doc) =>
                DateTime.parse(doc["tanggal"]) == DateTime.parse(date) &&
                DateTime.parse(doc["tanggal"]).isBefore(
                    DateTime.parse(date2).add(const Duration(days: 1))) &&
                doc["status"] == 2));
        return (await snapshots.first).toList();
      } else {
        // print(cabang);
        CollectionReference data = firestore.collection("transaksi");
        final snapshots = data.snapshots().map((snapshot) => snapshot.docs
            .where((doc) =>
                DateTime.parse(doc["tanggal"]).isAfter(DateTime.parse(date)) &&
                DateTime.parse(doc["tanggal"]).isBefore(
                    DateTime.parse(date2).add(const Duration(days: 1))) &&
                doc["status"] == 2 &&
                (doc.data() as Map<String, dynamic>)["kode_cabang"] == cabang));
        return (await snapshots.first).toList();
      }
    } else {
      CollectionReference data = firestore.collection("transaksi");
      final snapshots = data.snapshots().map((snapshot) => snapshot.docs.where(
          (doc) =>
              DateTime.parse(doc["tanggal"]).isAfter(DateTime.parse(date)) &&
              DateTime.parse(doc["tanggal"]).isBefore(
                  DateTime.parse(date2).add(const Duration(days: 1))) &&
              doc["status"] == 2 &&
              (doc.data() as Map<String, dynamic>)["kode_cabang"] == cabang));
      return (await snapshots.first).toList();
    }
  }

  Future<List<QueryDocumentSnapshot<Object?>>> getLaporanTotal(
      date, date2, String? cabang, int? level, int jenis) async {
    if (level == 1) {
      if (cabang == "") {
        CollectionReference data = firestore.collection("transaksi");
        final snapshots = data.snapshots().map((snapshot) => snapshot.docs
            .where((doc) =>
                DateTime.parse(doc["tanggal"]).isAfter(DateTime.parse(date)) &&
                DateTime.parse(doc["tanggal"]).isBefore(
                    DateTime.parse(date2).add(const Duration(days: 1))) &&
                doc["status"] == 2 &&
                doc["id_jenis"] == jenis));
        return (await snapshots.first).toList();
      } else {
        CollectionReference data = firestore.collection("transaksi");
        final snapshots = data.snapshots().map((snapshot) => snapshot.docs
            .where((doc) =>
                DateTime.parse(doc["tanggal"]).isAfter(DateTime.parse(date)) &&
                DateTime.parse(doc["tanggal"]).isBefore(
                    DateTime.parse(date2).add(const Duration(days: 1))) &&
                doc["status"] == 2 &&
                (doc.data() as Map<String, dynamic>)["kode_cabang"] == cabang &&
                doc["id_jenis"] == jenis));
        return (await snapshots.first).toList();
      }
    } else {
      CollectionReference data = firestore.collection("transaksi");
      final snapshots = data.snapshots().map((snapshot) => snapshot.docs.where(
          (doc) =>
              DateTime.parse(doc["tanggal"]).isAfter(DateTime.parse(date)) &&
              DateTime.parse(doc["tanggal"]).isBefore(
                  DateTime.parse(date2).add(const Duration(days: 1))) &&
              doc["status"] == 2 &&
              (doc.data() as Map<String, dynamic>)["kode_cabang"] == cabang &&
              doc["id_jenis"] == jenis));
      return (await snapshots.first).toList();
    }
  }

  Stream<QuerySnapshot<Object?>> servicesById(id) {
    CollectionReference services = firestore.collection("services");

    return services.where("id", whereIn: id).snapshots();
  }

  Stream<QuerySnapshot<Object?>> services() {
    CollectionReference services = firestore.collection("services");
    return services.orderBy("id", descending: false).snapshots();
  }

  Stream<QuerySnapshot<Object?>> streamCabang() {
    CollectionReference services = firestore.collection("cabang");
    return services.orderBy("kode_cabang", descending: false).snapshots();
  }

  Stream<QuerySnapshot<Object?>> streamJenisKendaraan() {
    CollectionReference jenis = firestore.collection("jenis_kendaraan");
    return jenis.snapshots();
  }

  Future<List<QueryDocumentSnapshot<Object?>>> getSummary(
      dateAwal, dateAkhir, cabang, level, idJenis) async {
    if (level == 1) {
      if (cabang == "") {
        if (idJenis == 0) {
          CollectionReference data = firestore.collection("transaksi");
          final snapshots = data.snapshots().map((snapshot) => snapshot.docs
              .where((doc) =>
                  DateTime.parse(doc["tanggal"]).isAfter(
                      DateTime.parse(dateAwal).add(const Duration(days: -1))) &&
                  DateTime.parse(doc["tanggal"]).isBefore(
                      DateTime.parse(dateAkhir).add(const Duration(days: 1))) &&
                  doc["status"] == 2));
          return (await snapshots.first).toList();
        } else {
          CollectionReference data = firestore.collection("transaksi");
          final snapshots = data.snapshots().map((snapshot) => snapshot.docs
              .where((doc) =>
                  DateTime.parse(doc["tanggal"]).isAfter(
                      DateTime.parse(dateAwal).add(const Duration(days: -1))) &&
                  DateTime.parse(doc["tanggal"]).isBefore(
                      DateTime.parse(dateAkhir).add(const Duration(days: 1))) &&
                  doc["status"] == 2 &&
                  doc["id_jenis"] == idJenis));
          return (await snapshots.first).toList();
        }
      } else {
        if (idJenis == 0) {
          CollectionReference data = firestore.collection("transaksi");
          final snapshots = data.snapshots().map((snapshot) => snapshot.docs
              .where((doc) =>
                  DateTime.parse(doc["tanggal"]).isAfter(
                      DateTime.parse(dateAwal).add(const Duration(days: -1))) &&
                  DateTime.parse(doc["tanggal"]).isBefore(
                      DateTime.parse(dateAkhir).add(const Duration(days: 1))) &&
                  doc["status"] == 2 &&
                  (doc.data() as Map<String, dynamic>)["kode_cabang"] ==
                      cabang));
          return (await snapshots.first).toList();
        } else {
          CollectionReference data = firestore.collection("transaksi");
          final snapshots = data.snapshots().map((snapshot) => snapshot.docs
              .where((doc) =>
                  DateTime.parse(doc["tanggal"]).isAfter(
                      DateTime.parse(dateAwal).add(const Duration(days: -1))) &&
                  DateTime.parse(doc["tanggal"]).isBefore(
                      DateTime.parse(dateAkhir).add(const Duration(days: 1))) &&
                  doc["status"] == 2 &&
                  (doc.data() as Map<String, dynamic>)["kode_cabang"] ==
                      cabang &&
                  doc["id_jenis"] == idJenis));
          return (await snapshots.first).toList();
        }
      }
    } else {
      if (idJenis == 0) {
        CollectionReference data = firestore.collection("transaksi");
        final snapshots = data.snapshots().map((snapshot) => snapshot.docs
            .where((doc) =>
                DateTime.parse(doc["tanggal"]).isAfter(
                    DateTime.parse(dateAwal).add(const Duration(days: -1))) &&
                DateTime.parse(doc["tanggal"]).isBefore(
                    DateTime.parse(dateAkhir).add(const Duration(days: 1))) &&
                doc["status"] == 2 &&
                (doc.data() as Map<String, dynamic>)["kode_cabang"] == cabang));
        return (await snapshots.first).toList();
      } else {
        CollectionReference data = firestore.collection("transaksi");
        final snapshots = data.snapshots().map((snapshot) => snapshot.docs
            .where((doc) =>
                DateTime.parse(doc["tanggal"]).isAfter(
                    DateTime.parse(dateAwal).add(const Duration(days: -1))) &&
                DateTime.parse(doc["tanggal"]).isBefore(
                    DateTime.parse(dateAkhir).add(const Duration(days: 1))) &&
                doc["status"] == 2 &&
                (doc.data() as Map<String, dynamic>)["kode_cabang"] == cabang &&
                doc["id_jenis"] == idJenis));
        return (await snapshots.first).toList();
      }
    }
  }

  // Future<List<QueryDocumentSnapshot<Object?>>> getSummaryByService(
  //     dateAwal, dateAkhir, cabang, level, idService) async {
  //   if (level == 1) {
  //     if (cabang == "") {
  //       CollectionReference data = firestore.collection("transaksi");
  //       return data.where("tanggal", isEqualTo: dateAwal).where("tanggal", isLessThanOrEqualTo: dateAkhir).where("status", isEqualTo: 2).get().then((QuerySnapshot) => null)
  //       // final snapshots = data.snapshots().map((snapshot) => snapshot.docs
  //       //     .where((doc) =>
  //       //         DateTime.parse(doc["tanggal"]).isAfter(
  //       //             DateTime.parse(dateAwal).add(const Duration(days: -1))) &&
  //       //         DateTime.parse(doc["tanggal"]).isBefore(
  //       //             DateTime.parse(dateAkhir).add(const Duration(days: 1))) &&
  //       //         doc["status"] == 2 &&
  //       //         (doc.data() as Map<String,dynamic>)["services"]).contains(""));
  //       // return (await snapshots.first).toList();
  //     } else {
  //       CollectionReference data = firestore.collection("transaksi");
  //       final snapshots = data.snapshots().map((snapshot) => snapshot.docs
  //           .where((doc) =>
  //               DateTime.parse(doc["tanggal"]).isAfter(
  //                   DateTime.parse(dateAwal).add(const Duration(days: -1))) &&
  //               DateTime.parse(doc["tanggal"]).isBefore(
  //                   DateTime.parse(dateAkhir).add(const Duration(days: 1))) &&
  //               doc["status"] == 2 &&
  //               (doc.data() as Map<String, dynamic>)["kode_cabang"] == cabang &&
  //               (doc.data() as Map<String,dynamic>)["services"]).where((element) => element["id_service"]==idService));
  //       return (await snapshots.first).toList();
  //     }
  //   } else {
  //     CollectionReference data = firestore.collection("transaksi");
  //     final snapshots = data.snapshots().map((snapshot) => snapshot.docs.where(
  //         (doc) =>
  //             DateTime.parse(doc["tanggal"]).isAfter(
  //                 DateTime.parse(dateAwal).add(const Duration(days: -1))) &&
  //             DateTime.parse(doc["tanggal"]).isBefore(
  //                 DateTime.parse(dateAkhir).add(const Duration(days: 1))) &&
  //             doc["status"] == 2 &&
  //             (doc.data() as Map<String, dynamic>)["kode_cabang"] == cabang  &&
  //               (doc.data() as Map<String,dynamic>)["services"]).where((element) => element["id_service"]==idService));
  //     return (await snapshots.first).toList();
  //   }
  // }
}
