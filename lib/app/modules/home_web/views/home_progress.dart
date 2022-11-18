import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carwash/app/modules/master/controllers/master_controller.dart';
import 'package:get/get.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import '../../../helper/alert.dart';
import '../../home/controllers/home_controller.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';

class HomeProgress extends GetView<HomeController> {
  HomeProgress(this.cabang, {super.key});
  final String cabang;
  var date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final homeC = Get.put(HomeController());
  final masterC = Get.put(MasterController());

  FlutterTts flutterTts = FlutterTts();
  final assetsAudioPlayer = AssetsAudioPlayer();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Object?>>(
      stream: homeC.streamDataProgress(cabang, date),
      builder: (context, snapshot) {
        // print(snapshot.hasData);
        if (snapshot.hasData) {
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
            // print(list.length);
            if (list.isEmpty) {
              return DataTable2(
                  columnSpacing: 1,
                  horizontalMargin: 8,
                  minWidth: 600,
                  showBottomBorder: true,
                  headingTextStyle: const TextStyle(color: Colors.white),
                  headingRowColor: MaterialStateProperty.resolveWith(
                      (states) => Colors.lightBlue),
                  columns: const [
                    DataColumn2(
                      label: Text('No Transaksi'),
                      size: ColumnSize.L,
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
                    DataColumn2(label: Text('Action'), size: ColumnSize.M),
                  ],
                  rows: List<DataRow>.generate(1, (index) {
                    return const DataRow(cells: [
                      DataCell(Text('')),
                      DataCell(Text('')),
                      DataCell(Text('')),
                      DataCell(Text('')),
                      DataCell(Text('')),
                      DataCell(Text('')),
                      DataCell(Text('')),
                      DataCell(Text('')),
                      DataCell(Text('')),
                    ]);
                  }));
            }
            return DataTable2(
                columnSpacing: 10,
                horizontalMargin: 8,
                minWidth: 800,
                showBottomBorder: true,
                headingTextStyle: const TextStyle(color: Colors.white),
                headingRowColor: MaterialStateProperty.resolveWith(
                    (states) => Colors.lightBlue),
                columns: const [
                  DataColumn2(
                    label: Text('No Transaksi'),
                    size: ColumnSize.L,
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
                  DataColumn2(label: Text('Action'), fixedWidth: 100),
                ],
                rows: List<DataRow>.generate(list.length, (index) {
                  var serviceType = [];
                  for (int i = 0; i < list[index]["services"].length; i++) {
                    var serviceTypeData = {
                      "id_service": list[index]["services"][i]["id_service"]
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
                        : "-:-:-")),
                    DataCell(Text(list[index]["jam_selesai"] != ""
                        ? list[index]["jam_selesai"]
                        : "-:-:-")),
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
                            for (var i in sr) {
                              nama.add(i["nama"]);
                            }

                            return Text(nama.isNotEmpty
                                ? nama.join(', ').toString()
                                : "not set");
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
                    DataCell(Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            editData(
                              data[index].id,
                              list[index]["no_trx"],
                              list[index]["tanggal"],
                              list[index]["no_polisi"],
                              list[index]["kendaraan"],
                              list[index]["jam_masuk"],
                              serviceType
                                  .map((service) => service["id_service"])
                                  .toList(),
                              userLst,
                            );
                          },
                          icon: const Icon(
                            Icons.edit_note_sharp,
                            size: 30,
                            color: Colors.lightBlue,
                          ),
                          splashRadius: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 0.0, right: 0),
                          child: IconButton(
                            onPressed: () async {
                              if (list[index]["jam_mulai"] == "") {
                                if (userLst.isEmpty) {
                                  showSnackbar(
                                      "Error", "Petugas belum dipilih!");
                                } else {
                                  homeC.updateStatus(0, data[index].id);
                                }
                              } else if (list[index]["jam_selesai"] == "") {
                                homeC.updateStatus(1, data[index].id);

                                playSound(list[index]["id_jenis"],
                                    list[index]["no_polisi"]);
                                // Future.delayed(const Duration(milliseconds: 350),
                                //     () {
                                //   playSoundEnglish(
                                //       list[index]["id_jenis"],
                                //       list[index]["no_polisi"]);
                                // });
                              }
                            },
                            icon: Icon(
                              list[index]["jam_mulai"] == ""
                                  ? Icons.play_circle_outline
                                  : Icons.stop_circle_outlined,
                              size: 30,
                              color: Colors.lightBlue,
                            ),
                            splashRadius: 20,
                          ),
                        ),
                      ],
                    )),
                  ]);
                }));
          }
        } else if (snapshot.hasError) {
          return const Center(child: Text('Belum ada data masuk'));
        }
        return const Center(
          child: CupertinoActivityIndicator(),
        );
      },
    );
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

  void editData(id, notrx, tanggal, nopol, kendaraan, masuk,
      List<dynamic> service, List<dynamic> petugas) {
    Get.defaultDialog(
        radius: 5,
        title: 'Detail Data',
        content: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: notrx,
                  height: 100,
                  width: 320,
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: const Text(
                          "Tanggal",
                          style: TextStyle(fontSize: 17),
                        ),
                      )),
                  Expanded(
                    flex: 8,
                    child: SizedBox(
                        height: 18,
                        child: Text(
                            DateFormat('dd/MM/yyyy')
                                .format(DateTime.parse(tanggal))
                                .toString(),
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
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: const Text(
                          "No Kendaraan",
                          style: TextStyle(fontSize: 17),
                        ),
                      )),
                  Expanded(
                    flex: 8,
                    child: SizedBox(
                        height: 18,
                        child:
                            Text(nopol, style: const TextStyle(fontSize: 17))),
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
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: const Text(
                          "Nama Kendaraan",
                          style: TextStyle(fontSize: 17),
                        ),
                      )),
                  Expanded(
                    flex: 8,
                    child: SizedBox(
                        height: 18,
                        child: Text(kendaraan,
                            style: const TextStyle(fontSize: 17))),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: const Text(
                          "Jam masuk",
                          style: TextStyle(fontSize: 17),
                        ),
                      )),
                  Expanded(
                    flex: 8,
                    child: SizedBox(
                        height: 18,
                        child:
                            Text(masuk, style: const TextStyle(fontSize: 17))),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              StreamBuilder<QuerySnapshot<Object?>>(
                stream: homeC.services(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CupertinoActivityIndicator(),
                    );
                  } else {
                    var dataService = snapshot.data!.docs;
                    var temp = [];

                    dataService.map((DocumentSnapshot doc) {
                      temp.add((doc.data() as Map<String, dynamic>));
                    }).toList();
                    // print(temp);
                    return MultiSelectFormField(
                        autovalidate: AutovalidateMode.disabled,
                        chipBackGroundColor: Colors.blue,
                        chipLabelStyle: const TextStyle(color: Colors.white),
                        dialogTextStyle:
                            const TextStyle(fontWeight: FontWeight.bold),
                        checkBoxActiveColor: Colors.blue,
                        checkBoxCheckColor: Colors.white,
                        dialogShapeBorder: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0))),
                        title: const Text(
                          "Pilih Service",
                          style: TextStyle(fontSize: 16),
                        ),
                        hintWidget: const Text(''),
                        validator: (value) {
                          if (value == null || value.length == 0) {
                            return showSnackbar("Error", "Select Services");
                          }

                          return null;
                        },
                        dataSource: [
                          for (var i in temp)
                            {
                              // print(i)

                              "display": i["nama"],
                              "value": i["id"],
                            }
                        ],
                        textField: 'display',
                        valueField: 'value',
                        okButtonLabel: 'OK',
                        cancelButtonLabel: 'CANCEL',
                        initialValue: homeC.initService,
                        onSaved: (value) {
                          if (value == null) return;
                          // setState(() {
                          homeC.serviceItem.value = value;
                          homeC.initService = value;
                          // print(homeC.serviceItem);
                        });
                  }
                },
              ),
              const SizedBox(
                height: 5,
              ),
              StreamBuilder<QuerySnapshot<Object?>>(
                  stream: masterC.streamDataKaryawanByCabang(cabang),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var dataUser = snapshot.data!.docs;
                      var tempUser = [];

                      dataUser.map((DocumentSnapshot doc) {
                        tempUser.add((doc.data() as Map<String, dynamic>));
                      }).toList();
                      return MultiSelectFormField(
                          autovalidate: AutovalidateMode.disabled,
                          chipBackGroundColor: Colors.blue,
                          chipLabelStyle: const TextStyle(color: Colors.white),
                          dialogTextStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                          checkBoxActiveColor: Colors.blue,
                          checkBoxCheckColor: Colors.white,
                          dialogShapeBorder: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0))),
                          title: const Text(
                            "Pilih Petugas",
                            style: TextStyle(fontSize: 16),
                          ),
                          hintWidget: const Text(''),
                          validator: (value) {
                            if (value == null || value.length == 0) {
                              return showSnackbar("Error", "Pilih Petugas");
                            }

                            return null;
                          },
                          dataSource: [
                            for (var i in tempUser)
                              {
                                // print(i)

                                "display": i["nama"],
                                "value": i["nama"],
                              }
                          ],
                          textField: 'display',
                          valueField: 'value',
                          okButtonLabel: 'OK',
                          cancelButtonLabel: 'CANCEL',
                          initialValue: const [],
                          onSaved: (value) {
                            if (value == null) return;
                            // setState(() {
                            homeC.selectedPetugas.value = value;
                            // print(homeC.serviceItem);
                          });
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }
                    return const Center(
                      child: CupertinoActivityIndicator(),
                    );
                    // print(cabang);
                  }),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: ElevatedButton(
                        onPressed: () {
                          var servicess = [];
                          if (homeC.serviceItem.isEmpty) {
                            servicess = service;
                          } else {
                            servicess = homeC.serviceItem;
                          }

                          if (homeC.selectedPetugas.isEmpty) {
                            homeC.selectedPetugas.value = petugas;
                          } else {
                            homeC.selectedPetugas;
                          }
                          homeC.updateService(
                              id, servicess, homeC.selectedPetugas);
                          Get.back();
                          homeC.selectedPetugas.clear();
                          homeC.serviceItem.clear();
                        },
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(40, 40)),
                        child: const Text(
                          'Update',
                          style: TextStyle(fontSize: 15),
                        ),
                      )),
                  Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(45, 40)),
                        child: const Text(
                          'Batal',
                          style: TextStyle(fontSize: 15),
                        ),
                      )),
                ],
              ),
            ],
          ),
        ));
  }
}
