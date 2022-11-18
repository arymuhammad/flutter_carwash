import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ota_update/ota_update.dart';

import '../../../helper/app_exceptions.dart';
import '../../../helper/alert.dart';

class HomeController extends GetxController {
  late OtaEvent currentEvent;
  var dataNoPol = [].obs;
  // final List<String> selected = ["", "1"].obs;
  // var selectedItem = ''.obs;
  var url = "";
  late TextEditingController noPol1 = TextEditingController();
  late TextEditingController noPol2 = TextEditingController();
  late TextEditingController noPol3 = TextEditingController();
  late TextEditingController bayar = TextEditingController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var selectedItem = "".obs;
  var selectedMerk = "".obs;
  var generateBarcode = 1.obs;
  var initService = [];
  var serviceItem = [].obs;
  var servicepaid = [];
  var totalHarga = 0.obs;
  var byr = 0;
  var cpi = 0;
  var kembali = 0.obs;
  var cabang = "".obs;
  var selectedPetugas = [].obs;
  var noUrutTrx = "".obs;
  List<String> metodpay = ["", "Cash", "BCA", "BRI", "BNI", "OVO", "DANA"];
  var paySelected = "".obs;
  var idTrx = 1;
  var tempStruk = {}.obs;
  var namaCabang = "";
  var alamatCabang = "";
  var kotaCabang = "";
  var noPolisi = [].obs;

  Stream<QuerySnapshot<Object?>> streamData() {
    CollectionReference transaksi = firestore.collection("transaksi");
    return transaksi
        .where("status", isNotEqualTo: 2)
        .orderBy("status", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Object?>> streamDataMobil() {
    CollectionReference transaksi = firestore.collection("transaksi");
    return transaksi
        .where("status", isNotEqualTo: 2)
        .where("id_jenis", isEqualTo: 2)
        .orderBy("status", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Object?>> streamDataMotor() {
    CollectionReference transaksi = firestore.collection("transaksi");
    return transaksi
        .where("status", isNotEqualTo: 2)
        .where("id_jenis", isEqualTo: 1)
        .orderBy("status", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Object?>> streamDataProgressAdd(user, date) {
    CollectionReference transaksi = firestore.collection("transaksi");
    // if (user == "") {
    //   return transaksi
    //       .where("tanggal", isEqualTo: date)
    //       .orderBy("id", descending: false)
    //       .snapshots();
    // } else {
    return transaksi
        .where("tanggal", isEqualTo: date)
        .where("kode_cabang", isEqualTo: user)
        .orderBy("id", descending: false)
        .snapshots();
    // }
  }

  Stream<QuerySnapshot<Object?>> streamDataProgress(user, date) {
    CollectionReference transaksi = firestore.collection("transaksi");
    if (user == "") {
      return transaksi
          .where("status", isEqualTo: 0)
          .where("tanggal", isEqualTo: date)
          .orderBy("id", descending: false)
          .snapshots();
    } else {
      return transaksi
          .where("status", isEqualTo: 0)
          .where("tanggal", isEqualTo: date)
          .where("kode_cabang", isEqualTo: user)
          .orderBy("id", descending: false)
          .snapshots();
    }
  }

  Stream<QuerySnapshot<Object?>> streamDataUser(String? email) {
    CollectionReference transaksi = firestore.collection("users");
    return transaksi.where("email", isEqualTo: email).snapshots();
  }

  Stream<QuerySnapshot<Object?>> streamDataPetugas(cabang) {
    CollectionReference transaksi = firestore.collection("users");
    if (cabang == "") {
      return transaksi.where("level", isEqualTo: 3).snapshots();
    } else {
      return transaksi
          .where("level", isEqualTo: 3)
          .where("kode_cabang", isEqualTo: cabang)
          .snapshots();
    }
  }

  Stream<QuerySnapshot<Object?>> streamDataFinish(user, date) {
    CollectionReference transaksi = firestore.collection("transaksi");
    if (user == "") {
      return transaksi
          .where("status", isNotEqualTo: 0)
          .where("tanggal", isEqualTo: date)
          .snapshots();
    } else {
      return transaksi
          .where("status", isNotEqualTo: 0)
          .where("kode_cabang", isEqualTo: user)
          .where("tanggal", isEqualTo: date)
          .snapshots();
    }
  }

  Stream<QuerySnapshot<Object?>> streamStatus() {
    CollectionReference transaksi = firestore.collection("transaksi");
    return transaksi.where('status', isEqualTo: 1).snapshots();
  }

  Stream<QuerySnapshot<Object?>> jenisKendaraan() {
    CollectionReference jenis = firestore.collection("jenis_kendaraan");
    return jenis.orderBy("id", descending: false).snapshots();
  }

  Stream<QuerySnapshot<Object?>> merk(id) {
    CollectionReference merk = firestore.collection("merk");
    return merk.where("id_jenis", isEqualTo: id).snapshots();
  }

  Stream<QuerySnapshot<Object?>> services() {
    CollectionReference services = firestore.collection("services");
    return services.orderBy("id", descending: false).snapshots();
  }

  Stream<QuerySnapshot<Object?>> servicesById(id) {
    CollectionReference services = firestore.collection("services");

    return services.where("id", whereIn: id).snapshots();
  }

  updateStatus(int angka, String id) async {
    DocumentReference transaksi = firestore.collection("transaksi").doc(id);
    try {
      if (angka == 0) {
        await transaksi.update(
            {"jam_mulai": DateFormat("HH:mm:ss").format(DateTime.now())});
      } else {
        await transaksi.update({
          "jam_selesai": DateFormat("HH:mm:ss").format(DateTime.now()),
          "paid": 0,
          "status": 1
        });
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  updateService(
      String id, List<dynamic> serviceName, List<dynamic> petugas) async {
    DocumentReference service = firestore.collection("transaksi").doc(id);
    try {
      await service.update({
        "services": [
          // {
          for (var i in serviceName) {"id_service": i}
          // }
        ],
        "petugas": [
          // {
          for (var i in petugas) {"nama_petugas": i}
          // }
        ]
      });
      Get.back();
      await showSnackbar("Sukses", "Data Berhasil di Update");
      // ignore: empty_catches
    } catch (e) {}
  }

  // Stream<QuerySnapshot<Object?>> subMerk(String idMerk) {
  //   CollectionReference subMerk = firestore.collection("sub_merk");
  //   return subMerk.where('id_merk', isEqualTo: idMerk).snapshots();
  // }

  addTrx(int id, String trx, String cabang, String jenis, String nopol,
      String date, String merk) async {
    CollectionReference transaksi = firestore.collection("transaksi");
    var idservice = 0;
    if (int.parse(jenis) == 1) {
      idservice = 5;
    } else if (int.parse(jenis) == 2) {
      idservice = 1;
    }

    try {
      await transaksi.add({
        "id": id,
        "no_trx": trx,
        "kode_cabang": cabang,
        "id_jenis": int.parse(jenis),
        "no_polisi": nopol,
        "tanggal": date,
        "kendaraan": merk,
        "jam_masuk": DateFormat('HH:mm:ss').format(DateTime.now()),
        "jam_mulai": "",
        "jam_selesai": "",
        "petugas": "",
        "status": 0,
        "services": [
          {"id_service": idservice}
        ]
      });

      Get.defaultDialog(
        barrierDismissible: false,
        radius: 5,
        title: 'Sukses',
        middleText: 'Berhasil menambahkan data',
        onConfirm: () {
          noPol1.clear();
          noPol2.clear();
          noPol3.clear();
          selectedMerk.value = "";
          selectedItem.value = "";
          Get.back();
          Get.back();
        },
        textConfirm: 'OK',
      );
      // ignore: empty_catches
    } catch (e) {}
  }
  // updateUserCabang(idUser, List<dynamic> users) async {
  //   CollectionReference user = firestore.collection("users");
  //   WriteBatch batch = FirebaseFirestore.instance.batch();
  //   try {
  //     await user.where("email", whereIn: users).get().then((querySnapshot) {
  //       querySnapshot.docs.forEach((document) {
  //         batch.update(document.reference, {"kode_cabang": idUser});
  //       });
  //       return batch.commit();
  //     });
  //     // Get.back();
  //     // await showSnackbar("Sukses", "Data Berhasil di Update user cabang");
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  void pembayaran(String bayar) async {
    var result = int.parse(bayar) - totalHarga.value;
    kembali.value = result;
  }

  handleError(error) {
    hideLoading();
    if (error is BadRequestException) {
      var message = error.message;
      // DialogHelper().showErroDialog(description: message);
      Get.defaultDialog(
          barrierDismissible: false,
          radius: 5,
          title: 'Error',
          content: Text(message.toString()),
          confirm: ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
              onPressed: () {
                // fetchdataMaster();
                // Get.back();
              }));
    } else if (error is FetchDataException) {
      var message = error.message;
      // DialogHelper().showErroDialog(description: message);
      Get.defaultDialog(
          radius: 5,
          barrierDismissible: false,
          title: 'Error',
          content: Text(message.toString()),
          cancel: ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
              onPressed: () {
                // fetchdataMaster();
                // Get.back();
              }),
          confirm: ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Periksa'),
              onPressed: () async {
                // await Get.to(() => SettingsView());

                // await Future.delayed(const Duration(milliseconds: 10), () {
                //   Get.back();
                //   isLoading.value = true;
                //   fetchdataMaster();
                // });
              }));
    } else if (error is ApiNotRespondingException) {
      // DialogHelper()
      //     .showErroDialog(description: 'Oops! It took longer to respond.');
      Get.defaultDialog(
          barrierDismissible: false,
          radius: 5,
          title: 'Error',
          content: const Text('Oerver terlalu lama merespon.'),
          confirm: ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
              onPressed: () {
                // fetchdataMaster();
                // Get.back();
              }),
          cancel: ElevatedButton.icon(
              icon: const Icon(Icons.wifi_protected_setup_rounded),
              onPressed: () async {
                // await Get.to(() => SettingsView());
                // await Future.delayed(const Duration(milliseconds: 10), () {
                //   Get.back();

                //   isLoading.value = true;
                //   fetchdataMaster();
                // });
              },
              label: const Text('Cek koneksi')));
    }
  }

  showLoading([String? message]) {
    // DialogHelper.showLoading(message);
    Get.defaultDialog(
        title: '',
        content: const Center(
          child: CircularProgressIndicator(),
        ));
  }

  hideLoading() {
    // DialogHelper.hideLoading();
  }

  @override
  void onClose() {
    noPol1.dispose();
    noPol2.dispose();
    noPol3.dispose();
    super.onClose();
  }

  void updateTrx(
      id, String paySelect, RxInt totalHarga, String bayar, int kembali) async {
    DocumentReference trx = firestore.collection("transaksi").doc(id);
    try {
      await trx.update({
        "metode_pembayaran": paySelected.toString(),
        "grand_total": totalHarga.toInt(),
        "bayar": int.parse(bayar),
        "kembali": kembali,
        "paid": 1,
        "status": 2
      });
      Get.back();
      await showSnackbar("Sukses", "Data Berhasil di Update");
      // ignore: empty_catches
    } catch (e) {}
  }

  Stream<QuerySnapshot<Object?>> streamCabang(kode) {
    CollectionReference cabang = firestore.collection("cabang");
    return cabang.where("kode_cabang", isEqualTo: kode).snapshots();
  }

  Future<void> tryOtaUpdate() async {
    try {
      //LINK CONTAINS APK OF FLUTTER HELLO WORLD FROM FLUTTER SDK EXAMPLES
      Get.defaultDialog(
          title: 'UPDATE APP',
          radius: 5,
          barrierDismissible: false,
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Divider(),
              Text('Mengunduh Pembaruan'),
              Text('Harap Menunggu'),
              SizedBox(
                height: 10,
              ),
              LinearProgressIndicator(
                minHeight: 10,
              ),
              SizedBox(
                height: 5,
              ),
            ],
          ));
      OtaUpdate()
          .execute(
        'http://103.112.139.155/apk/carwash.apk',
        destinationFilename: 'carwash.apk',
        //FOR NOW ANDROID ONLY - ABILITY TO VALIDATE CHECKSUM OF FILE:
        // sha256checksum:
        //     'd6da28451a1e15cf7a75f2c3f151befad3b80ad0bb232ab15c20897e54f21478',
      )
          .listen(
        (OtaEvent event) {
          currentEvent = event;
        },
      );
      // ignore: avoid_catches_without_on_clauses, empty_catches
    } catch (e) {}
  }
}
