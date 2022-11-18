import 'package:barcode_widget/barcode_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carwash/app/helper/alert.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import '../../../helper/printer_kasir.dart';
import '../../home/controllers/home_controller.dart';

class HomeFinish extends GetView<HomeController> {
  HomeFinish(this.level, this.kasir, this.cabang, this.namaCabang,
      this.alamatCabang, this.kotaCabang,
      {super.key});

  final homeC = Get.put(HomeController());
  final int level;
  final String kasir;
  final String cabang;
  final String namaCabang;
  final String alamatCabang;
  final String kotaCabang;

  FlutterTts flutterTts = FlutterTts();
  final assetsAudioPlayer = AssetsAudioPlayer();

  var date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Object?>>(
      stream: homeC.streamDataFinish(cabang, date),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // print(snapshot.hasData);
          // print(alamatCabang);
          // print(level);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          } else {
            var data = snapshot.data!.docs;
            List<Map<String, dynamic>> list = [];
            data.map((DocumentSnapshot doc) {
              list.add((doc.data() as Map<String, dynamic>));
            }).toList();
            // print(list);

            return DataTable2(
                columnSpacing: 10,
                horizontalMargin: 8,
                minWidth: 800,
                showBottomBorder: true,
                headingTextStyle: const TextStyle(color: Colors.white),
                headingRowColor: MaterialStateProperty.resolveWith(
                    (states) => Colors.lightBlue),
                columns: const [
                  DataColumn(
                    label: Text('No Transaksi'),
                    // size: ColumnSize.S,
                  ),
                  DataColumn(
                    label: Text('No Kendaraan'),
                  ),
                  DataColumn(
                    label: Text('Kendaraan'),
                  ),
                  DataColumn(
                    label: Text('Masuk'),
                  ),
                  DataColumn(
                    label: Text('Mulai'),
                  ),
                  DataColumn(
                    label: Text('Selesai'),
                  ),
                  DataColumn(
                    label: Text('Service'),
                  ),
                  DataColumn(
                    label: Text('Petugas'),
                  ),
                  DataColumn(
                    label: Text('Status'),
                  ),
                  DataColumn(
                    label: Text('Action'),
                  ),
                ],
                rows: List<DataRow>.generate(list.length, (index) {
                  var serviceType = [];
                  for (int i = 0; i < list[index]["services"].length; i++) {
                    var serviceTypeData = {
                      "id_service": list[index]["services"][i]["id_service"],
                      "harga": list[index]["services"][i]["harga"]
                    };
                    serviceType.add(serviceTypeData);
                  }
                  var userLst = [];
                  for (int i = 0; i < list[index]["petugas"].length; i++) {
                    userLst.add(list[index]["petugas"][i]["nama_petugas"]);
                  }

                  return DataRow(cells: [
                    DataCell(Text(list[index]["no_trx"])),
                    DataCell(Text(list[index]["no_polisi"])),
                    DataCell(Text(list[index]["kendaraan"])),
                    DataCell(Text(list[index]["jam_masuk"] != ""
                        ? list[index]["jam_masuk"]
                        : "not set")),
                    DataCell(Text(list[index]["jam_mulai"] != ""
                        ? list[index]["jam_mulai"]
                        : "not set")),
                    DataCell(Text(list[index]["jam_selesai"] != ""
                        ? list[index]["jam_selesai"]
                        : "not set")),
                    DataCell(StreamBuilder<QuerySnapshot<Object?>>(
                      stream: homeC.servicesById(serviceType
                          .map((service) => service["id_service"])
                          .toList()),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var serviceId = snapshot.data!.docs;
                          var sr = [];
                          serviceId.map((DocumentSnapshot doc) {
                            sr.add((doc.data() as Map<String, dynamic>));
                          }).toList();

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CupertinoActivityIndicator(),
                            );
                          } else {
                            var nama = [];
                            var idServe = [];
                            for (var i in sr) {
                              nama.add(i["nama"]);
                              idServe.add(i["id"]);
                            }
                            homeC.servicepaid = idServe;
                            return Text(nama.join(', ').toString());
                          }
                        } else if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        }
                        return const Center(
                          child: CupertinoActivityIndicator(),
                        );
                      },
                    )),
                    DataCell(Text(userLst.isNotEmpty
                        ? userLst.join(', ').toString()
                        : 'not set')),
                    DataCell(Text(
                      list[index]["paid"] == 1 ? "PAID" : "UNPAID",
                      style: TextStyle(
                          color: list[index]["paid"] == 1
                              ? Colors.greenAccent[700]
                              : Colors.redAccent[700]),
                    )),
                    DataCell(Row(
                      children: [
                        if (level != 1)
                          IconButton(
                            onPressed: list[index]["paid"] != 1
                                ? () {
                                    var itemServ = [];
                                    for (int i = 0;
                                        i < list[index]["services"].length;
                                        i++) {
                                      itemServ.add(list[index]["services"][i]
                                          ["id_service"]);
                                    }

                                    bayar(
                                        data[index].id,
                                        kasir,
                                        list[index]["no_trx"],
                                        list[index]["kode_cabang"],
                                        namaCabang,
                                        alamatCabang,
                                        kotaCabang,
                                        list[index]["tanggal"],
                                        list[index]["no_polisi"],
                                        list[index]["kendaraan"],
                                        list[index]["jam_masuk"],
                                        list[index]["jam_selesai"],
                                        itemServ,
                                        userLst);
                                  }
                                : null,
                            icon: Icon(
                              list[index]["paid"] != 1
                                  ? Icons.payments_outlined
                                  : Icons.payments_outlined,
                              size: 30,
                              color: list[index]["paid"] != 1
                                  ? Colors.lightBlue
                                  : Colors.grey,
                            ),
                            splashRadius: 20,
                          )
                        else
                          Container(),
                        IconButton(
                          onPressed: list[index]["paid"] != 1
                              ? () {
                                  playSound(list[index]["id_jenis"],
                                      list[index]["no_polisi"]);
                                }
                              : null,
                          icon: Icon(
                            list[index]["paid"] != 1
                                ? Icons.speaker
                                : Icons.speaker,
                            size: 30,
                            color: list[index]["paid"] != 1
                                ? Colors.lightBlue
                                : Colors.grey,
                          ),
                          splashRadius: 20,
                        )
                      ],
                    )),
                  ]);
                }));
          }
        } else if (snapshot.hasError) {
          return const Center(child: Text('Belum ada data masuk'));
        }
        return const Center(child: CupertinoActivityIndicator());
      },
    );
  }

  bayar(id, kasir, noTrx, kodeCabang, namaCabang, alamatCabang, kotaCabang,
      tanggal, noPol, kendaraan, masuk, selesai, serviceItem, userLst) {
    Get.defaultDialog(
        radius: 5,
        title: 'Konfirmasi Pembayaran',
        content: StreamBuilder<QuerySnapshot<Object?>>(
            stream: homeC.servicesById(serviceItem),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var serviceId = snapshot.data!.docs;
                var sr = [];
                serviceId.map((DocumentSnapshot doc) {
                  sr.add((doc.data() as Map<String, dynamic>));
                }).toList();

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CupertinoActivityIndicator(),
                  );
                } else {
                  var nama = [];
                  var harga = [];
                  var hargat = [];
                  for (var i in sr) {
                    nama.add(i["nama"]);
                    hargat.add(i["harga"]);
                    harga.add(NumberFormat.simpleCurrency(
                            locale: 'in', decimalDigits: 0)
                        .format(i["harga"]));
                    int total = hargat.fold(
                        0, (hargat, element) => hargat + element as int);
                    homeC.totalHarga.value = total;
                    // totalharga.add(i["harga"]);
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BarcodeWidget(
                            barcode: Barcode.code128(),
                            data: noTrx,
                            height: 100,
                            width: 320,
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                                flex: 5,
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 10, 12, 10),
                                  child: const Text(
                                    "Petugas",
                                    style: TextStyle(fontSize: 17),
                                  ),
                                )),
                            Expanded(
                              flex: 8,
                              child: Row(
                                children: [
                                  Text(userLst.join(' \n'),
                                      style: const TextStyle(fontSize: 17)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                                flex: 5,
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 10, 12, 10),
                                  child: const Text(
                                    "Tanggal",
                                    style: TextStyle(fontSize: 17),
                                  ),
                                )),
                            Expanded(
                              flex: 8,
                              child: SizedBox(
                                  height: 21,
                                  child: Text(
                                      '${DateFormat('dd/MM/yyyy').format(DateTime.parse(tanggal))} $masuk',
                                      style: const TextStyle(fontSize: 17))),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                                flex: 5,
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 10, 12, 10),
                                  child: const Text(
                                    "Nomor Kendaraan",
                                    style: TextStyle(fontSize: 17),
                                  ),
                                )),
                            Expanded(
                              flex: 8,
                              child: SizedBox(
                                  height: 21,
                                  child: Text(noPol,
                                      style: const TextStyle(fontSize: 17))),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                                flex: 5,
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 10, 12, 10),
                                  child: const Text(
                                    "Jenis",
                                    style: TextStyle(fontSize: 17),
                                  ),
                                )),
                            Expanded(
                              flex: 8,
                              child: SizedBox(
                                  height: 21,
                                  child: Text(kendaraan,
                                      style: const TextStyle(fontSize: 17))),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                                flex: 5,
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 10, 12, 10),
                                  child: const Text(
                                    "Services",
                                    style: TextStyle(fontSize: 17),
                                  ),
                                )),
                            Expanded(
                                flex: 8,
                                child: Row(
                                  children: [
                                    Text('${nama.join(' -\n')} -'),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(harga.join('\n')),
                                  ],
                                )
                                //
                                ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                                flex: 5,
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 10, 12, 10),
                                  child: const Text(
                                    "Total",
                                    style: TextStyle(fontSize: 17),
                                  ),
                                )),
                            Expanded(
                              flex: 8,
                              child: SizedBox(
                                height: 21,
                                child: Text(
                                  NumberFormat.simpleCurrency(
                                          locale: 'in', decimalDigits: 0)
                                      .format(homeC.totalHarga.value)
                                      .toString(),
                                  style: const TextStyle(fontSize: 17),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        ElevatedButton(
                            onPressed: () {
                              checkOut(
                                  id,
                                  kasir,
                                  noTrx,
                                  kodeCabang,
                                  namaCabang,
                                  alamatCabang,
                                  kotaCabang,
                                  tanggal,
                                  noPol,
                                  kendaraan,
                                  masuk,
                                  selesai,
                                  nama,
                                  harga,
                                  userLst);
                            },
                            child: const Text(
                              'Checkout',
                              style: TextStyle(fontSize: 15),
                            ))
                      ],
                    ),
                  );
                }
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            }));
  }

  checkOut(id, kasir, noTrx, kodeCabang, namaCabang, alamatCabang, kotaCabang,
      tanggal, noPol, kendaraan, masuk, selesai, nama, harga, userLst) {
    Get.defaultDialog(
        radius: 5,
        title: 'Pembayaran',
        content: SizedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              Row(
                children: <Widget>[
                  Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: const Text(
                          "TOTAL",
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      )),
                  Expanded(
                    flex: 8,
                    child: SizedBox(
                      height: 50,
                      child: TextField(
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: NumberFormat.simpleCurrency(
                                    locale: 'in', decimalDigits: 0)
                                .format(homeC.totalHarga.value)
                                .toString(),
                            hintStyle: const TextStyle(color: Colors.black)),
                        cursorHeight: 20,
                        style: const TextStyle(fontSize: 20),
                        readOnly: true,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: const Text(
                          "Metode Pembayaran",
                          style: TextStyle(fontSize: 17),
                        ),
                      )),
                  Expanded(
                    flex: 8,
                    child: SizedBox(
                        height: 50,
                        child: Obx(
                          () => DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(8),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20))),
                            isExpanded: true,
                            hint: const Text('Select payment method'),
                            icon: const Icon(Icons.payment_sharp),
                            value: homeC.paySelected.value == ""
                                ? null
                                : homeC.paySelected.value,
                            // isDense: true,
                            onChanged: (String? data) {
                              homeC.paySelected.value = data!;
                            },
                            items: homeC.metodpay.map((value) {
                              return DropdownMenuItem<String>(
                                  value: value, child: Text(value));
                            }).toList(),
                          ),
                        )),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: const Text(
                          "Bayar",
                          style: TextStyle(fontSize: 17),
                        ),
                      )),
                  Expanded(
                    flex: 8,
                    child: SizedBox(
                      height: 50,
                      child: TextField(
                        controller: homeC.bayar,
                        style: const TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                            prefixText: 'Rp',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20))),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          homeC.pembayaran(value);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: const Text(
                          "Kembali",
                          style: TextStyle(fontSize: 17),
                        ),
                      )),
                  Expanded(
                    flex: 8,
                    child: SizedBox(
                        height: 50,
                        child: Obx(
                          () => TextField(
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: NumberFormat.simpleCurrency(
                                        locale: 'in', decimalDigits: 0)
                                    .format(homeC.kembali.value)
                                    .toString(),
                                hintStyle:
                                    const TextStyle(color: Colors.black)),
                            cursorHeight: 20,
                            style: const TextStyle(fontSize: 20),
                            readOnly: true,
                          ),
                        )),
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        if (homeC.bayar.text == "") {
                          showSnackbar("Error", "Pembayaran Rp.0");
                        }
                        homeC.updateTrx(
                            id,
                            homeC.paySelected.value,
                            homeC.totalHarga,
                            homeC.bayar.text,
                            homeC.kembali.value);
                        // var item = [];
                        // for (var i in srvc) {
                        // var nominal = harga.join(',');
                        homeC.byr = int.parse(homeC.bayar.text);
                        // for (var i in nominal) {
                        //   // homeC.cpi = NumberFormat.simpleCurrency(
                        //   //         locale: 'in', decimalDigits: 0)
                        //   //     .format(i) as int;
                        //   print(i);
                        // }
                        // print(homeC.cpi);

                        var data = {
                          "kasir": kasir,
                          "cabang": namaCabang,
                          "alamat": alamatCabang,
                          "kota": kotaCabang,
                          "no_trx": noTrx,
                          "tanggal": DateFormat('dd/MM/yyyy HH:mm:ss')
                              .format(DateTime.now()),
                          "nopol": noPol,
                          "kendaraan": kendaraan,
                          "service_name": nama.join('\n'),
                          "harga": harga.join('\n'),
                          "petugas": userLst.join('\n   '),
                          "grand_total": homeC.totalHarga.value,
                          "pembayaran": homeC.paySelected.value,
                          "bayar": homeC.byr,
                          "kembali": homeC.kembali.value
                        };

                        PrintKasirState(dataPrint: data).createPdf();
                        homeC.paySelected.value = "";
                        homeC.kembali.value = 0;
                        homeC.bayar.clear();
                        Get.back();
                        Get.back();
                      },
                      child: const Text('Bayar')),
                  ElevatedButton(
                      onPressed: () {
                        homeC.paySelected.value = "";
                        homeC.kembali.value = 0;
                        homeC.bayar.clear();
                        Get.back();
                      },
                      child: const Text('Batal')),
                ],
              )
            ],
          ),
        ));
  }

  playSound(int jenis, String text) async {
    var jK = "";
    if (jenis == 1) {
      jK = "Motor";
    } else {
      jK = "Mobil";
    }
    var nopol = text.split('');
    // print(nopol);
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.setLanguage("id-ID");
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.9);
    await assetsAudioPlayer.open(
      Audio("assets/audio/Airport.mp3"),
      showNotification: true,
      autoStart: true,
    );
    Future.delayed(const Duration(milliseconds: 1800), () async {
      await flutterTts
          .speak('Di informasikan, kepada pemilik $jK, dengan nomor polisi');
      await playNopol(nopol);
      Future.delayed(const Duration(milliseconds: 1800), () async {
        await playSoundEnglish(jenis, text);
        await assetsAudioPlayer.open(
          Audio("assets/audio/Airport.mp3"),
          showNotification: true,
          autoStart: true,
        );
      });
    });
  }

  playSoundEnglish(int jenis, String text) async {
    var jK = "";
    if (jenis == 1) {
      jK = "motorcycle";
    } else {
      jK = "Car";
    }
    var nopol = text.split('');
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.setLanguage("en-GB");
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.9);
    await flutterTts
        .speak("Informed, to the owner of $jK, with a police number");
    await playNopolEnglish(nopol);
  }

  playNopol(List<String> nopol) async {
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.setLanguage("id-ID");
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.9);
    await flutterTts.speak(nopol[0].toString());
    await flutterTts.speak(nopol[2].toString());
    await flutterTts.speak(nopol[3].toString());
    await flutterTts.speak(nopol[4].toString());
    await flutterTts.speak(nopol[5].toString());
    await flutterTts.speak(nopol[7].toString());
    await flutterTts.speak(nopol[8].toString());
    if (nopol.length > 10) {
      // print(nopol.length);
      await flutterTts.speak(nopol[9].toString());
      await flutterTts.speak(nopol[10].toString());
      await playNext();
    } else if (nopol.length > 9) {
      await flutterTts.speak(nopol[9].toString());
      await playNext();
    } else {
      await playNext();
    }
  }

  playNopolEnglish(List<String> nopol) async {
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.setLanguage("en-GB");
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.9);
    //  print(await flutterTts.getVoices);
    await flutterTts.speak(nopol.toString());
    await playNextEnglish();
  }

  playNext() async {
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.setLanguage("id-ID");
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.9);
    await flutterTts.speak("sudah selesai");
    await flutterTts.speak("Silahkan melakukan pembayaran");
    await flutterTts.speak("Periksa kembali barang bawaan anda");
    await flutterTts.speak("Semoga selamat sampai tujuan");

    await assetsAudioPlayer.open(
      Audio("assets/audio/Airport.mp3"),
      showNotification: true,
      autoStart: true,
    );
  }

  playNextEnglish() async {
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.setLanguage("en-GB");
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.9);
    await flutterTts.speak("it's finished");
    await flutterTts.speak("Please make payment");
    await flutterTts.speak("Check your belongings again");
    await flutterTts.speak("Have a safe trip.");
  }
}
