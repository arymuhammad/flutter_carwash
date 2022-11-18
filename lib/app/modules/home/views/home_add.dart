import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carwash/app/helper/printer.dart';
import 'package:carwash/app/modules/home/controllers/home_controller.dart';

import 'package:get/get.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../controllers/auth_controller.dart';

class HomeAdd extends GetView<HomeController> {
  HomeAdd({super.key, required this.user});
  final homeC = Get.put(HomeController());
  final authC = Get.put(AuthController());
  final String user;
  // var noUrutTrx = 1;
  var date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  var dateNow = DateFormat('ddMMyy').format(DateTime.now());
  TextEditingController mk = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _autocompleteKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // print(dateNow);
    return WillPopScope(
      onWillPop: () async {
        bool willLeave = false;
        await Get.defaultDialog(
            radius: 5,
            title: 'Peringatan',
            content: Container(
              child: const Text('Anda yakin ingin keluar dari aplikasi ini?'),
            ),
            confirm: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent[700]),
                child: const Text('TIDAK')),
            cancel: ElevatedButton(
                onPressed: () {
                  willLeave = true;
                  Get.back();
                },
                child: const Text('IYA')));
        return willLeave;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
          centerTitle: true,
          leading: const Icon(Icons.account_circle),
          // Builder(
          //   builder: (BuildContext context) {
          //     return IconButton(
          //       icon: const Icon(Icons.print_rounded),
          //       onPressed: () {
          //         Get.to(() => const PrintSetting());
          //       },
          //       tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          //     );
          //   },
          // ),
          actions: [
            PopupMenuButton<int>(
              itemBuilder: (context) => [
                // PopupMenuItem 1
                PopupMenuItem(
                  value: 1,
                  // row with 2 children
                  child: Row(
                    children: const [
                      Icon(Icons.file_download_outlined, color: Colors.black),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Update App")
                    ],
                  ),
                ),
                // PopupMenuItem 2
                PopupMenuItem(
                  value: 2,
                  // row with two children
                  child: Row(
                    children: const [
                      Icon(Icons.print_rounded, color: Colors.black),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Printer Setting")
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 3,
                  // row with two children
                  child: Row(
                    children: const [
                      Icon(Icons.logout_outlined, color: Colors.black),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Log Out")
                    ],
                  ),
                ),
              ],
              offset: const Offset(0, 1),
              color: Colors.white,
              elevation: 2,
              // on selected we show the dialog box
              onSelected: (value) {
                // if value 1 show dialog
                if (value == 1) {
                  homeC.tryOtaUpdate();
                  // if value 2 show dialog
                } else if (value == 2) {
                  Get.to(() => const PrintSetting());
                } else if (value == 3) {
                  Get.defaultDialog(
                    barrierDismissible: false,
                    radius: 5,
                    title: 'Peringatan',
                    content: Column(
                      children: [
                        const Text('Anda yakin ingin Logout?'),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  authC.isLoading.value = false;
                                  authC.logout();
                                  Fluttertoast.showToast(
                                      msg: "Sukses, Anda berhasil Logout.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.greenAccent[700],
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                  Get.back();
                                },
                                child: const Text('Ya')),
                            ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: const Text('Tidak')),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            // IconButton(
            //     onPressed: () {
            //       Get.defaultDialog(
            //         barrierDismissible: false,
            //         radius: 5,
            //         title: 'Peringatan',
            //         content: Column(
            //           children: [
            //             const Text('Anda yakin ingin Logout?'),
            //             const SizedBox(
            //               height: 20,
            //             ),
            //             Row(
            //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //               children: [
            //                 ElevatedButton(
            //                     onPressed: () {
            //                       authC.isLoading.value = false;
            //                       authC.logout();
            //                       Fluttertoast.showToast(
            //                           msg: "Sukses, Anda berhasil Logout.",
            //                           toastLength: Toast.LENGTH_SHORT,
            //                           gravity: ToastGravity.BOTTOM,
            //                           timeInSecForIosWeb: 1,
            //                           backgroundColor: Colors.greenAccent[700],
            //                           textColor: Colors.white,
            //                           fontSize: 16.0);
            //                       Get.back();
            //                     },
            //                     child: const Text('Ya')),
            //                 ElevatedButton(
            //                     onPressed: () {
            //                       Get.back();
            //                     },
            //                     child: const Text('Tidak')),
            //               ],
            //             ),
            //           ],
            //         ),
            //       );
            //     },
            //     icon: const Icon(Icons.logout_outlined)),
            // IconButton(
            //     onPressed: () {
            //       homeC.tryOtaUpdate();
            //     },
            //     icon: const Icon(Icons.file_download_outlined))
          ],
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30, left: 10),
                  child: StreamBuilder(
                      stream: homeC.streamDataUser(user),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var email = snapshot.data!.docs;
                          var cabang = [];
                          email.map((DocumentSnapshot doc) {
                            return cabang
                                .add((doc.data() as Map<String, dynamic>));
                          }).toList();
                          return StreamBuilder(
                              stream: homeC.streamDataProgressAdd(
                                  cabang[0]["kode_cabang"], date),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  var lengthTrx = snapshot.data!.docs;

                                  snapshot.data!.docs
                                      .map((DocumentSnapshot doc) {
                                    homeC.noPolisi.add((doc.data()
                                        as Map<String, dynamic>)["no_polisi"]);
                                  }).toList();
                                  // print(trx);
                                  // print(int.parse(trx
                                  //         .substring(trx.indexOf('-00') + 1)) +
                                  //     1);
                                  // if (trx ==
                                  //     '$cabang$dateNow-00${homeC.generateBarcode.value}') {
                                  // print("true");
                                  homeC.idTrx = lengthTrx.length + 1;
                                  // print(lengthTrx.length);
                                  // print(cabang);
                                  // }
                                  // var no = int.parse(
                                  //     trx.substring(trx.indexOf('-00') + 1));
                                  homeC.noUrutTrx.value =
                                      '${cabang[0]["kode_cabang"]}${cabang[0]["kode_user"]}';
                                  return BarcodeWidget(
                                      barcode: Barcode.code128(),
                                      data:
                                          '${cabang[0]["kode_cabang"]}${cabang[0]["kode_user"]}$dateNow-00${homeC.idTrx != 0 ? homeC.idTrx : 1}',
                                      height: 100,
                                      width: 320,
                                      style: const TextStyle(fontSize: 20));
                                } else if (snapshot.hasError) {
                                  // print(snapshot.error);
                                  return Text('${snapshot.error}');
                                }
                                return const Center(
                                  child: CupertinoActivityIndicator(),
                                );
                              });
                        } else if (snapshot.hasError) {
                          // print(snapshot.error);
                          return Text('${snapshot.error}');
                        }
                        return const Center(
                          child: CupertinoActivityIndicator(),
                        );
                      }),
                ),
                const SizedBox(
                  height: 50,
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
                          height: 20,
                          child: Text(
                              DateFormat('dd/MM/yyyy HH:mm:ss')
                                  .format(DateTime.now())
                                  .toString(),
                              style: const TextStyle(fontSize: 17))),
                    ),
                  ],
                ),
                // const SizedBox(
                //   height: 5,
                // ),
                Row(
                  children: <Widget>[
                    Expanded(
                        flex: 5,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                          child: const Text(
                            "Cabang",
                            style: TextStyle(fontSize: 17),
                          ),
                        )),
                    Expanded(
                      flex: 8,
                      child: SizedBox(
                          height: 20,
                          child: StreamBuilder<QuerySnapshot<Object?>>(
                              stream: homeC.streamDataUser(user),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  var email = snapshot.data!.docs;
                                  var cabang = "";
                                  email.map((DocumentSnapshot doc) {
                                    return cabang = ((doc.data() as Map<String,
                                        dynamic>)["kode_cabang"]);
                                  }).toList();
                                  // print(cabang);
                                  homeC.cabang.value = cabang;

                                  return StreamBuilder(
                                      stream: homeC.streamCabang(cabang),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          var dt = snapshot.data!.docs;
                                          var dtCabang = [];
                                          dt.map((DocumentSnapshot docs) {
                                            dtCabang.add((docs.data()
                                                as Map<String, dynamic>));
                                          }).toList();
                                          return Text(
                                              '${dtCabang[0]["nama_cabang"]} (${dtCabang[0]["kode_cabang"]})',
                                              style: const TextStyle(
                                                  fontSize: 17));
                                        } else if (snapshot.hasError) {
                                          return Text('${snapshot.error}');
                                        }
                                        return const Center(
                                          child: CupertinoActivityIndicator(),
                                        );
                                      });
                                } else if (snapshot.hasError) {
                                  return Text('${snapshot.error}');
                                }
                                return const Center(
                                    child: CupertinoActivityIndicator());
                              })),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                StreamBuilder<QuerySnapshot<Object?>>(
                    stream: homeC.jenisKendaraan(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CupertinoActivityIndicator(),
                        );
                      }
                      // var length = snapshot.data!.docs.length;
                      // DocumentSnapshot ds = snapshot.data!.docs[length - 1];
                      // var _queryCat = snapshot.data!.docs;
                      return Row(
                        children: <Widget>[
                          Expanded(
                              flex: 5,
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 10, 12, 10),
                                child: const Text(
                                  "Jenis Kendaraan",
                                  style: TextStyle(fontSize: 17),
                                ),
                              )),
                          Expanded(
                            flex: 8,
                            child: SizedBox(
                              height: 60,
                              child: Obx(
                                () => DropdownButtonFormField(
                                  decoration: const InputDecoration(
                                      // contentPadding: EdgeInsets.all(8),
                                      border: OutlineInputBorder()),
                                  value: homeC.selectedItem.value == ""
                                      ? null
                                      : homeC.selectedItem.value,
                                  onChanged: (String? data) {
                                    homeC.selectedItem.value = data!;
                                    // print(homeC.selectedItem);
                                  },
                                  items: snapshot.data!.docs
                                      .map((DocumentSnapshot document) {
                                    return DropdownMenuItem<String>(
                                        value:
                                            '${(document.data() as Map<String, dynamic>)['id']}',
                                        child: Text(
                                          (document.data()
                                              as Map<String, dynamic>)['jenis'],
                                        ));
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                          // ),
                        ],
                      );
                    }),
                const SizedBox(
                  height: 10,
                ),
                Obx(
                  () => StreamBuilder<QuerySnapshot<Object?>>(
                      stream: homeC.merk(homeC.selectedItem.value != ""
                          ? int.parse(homeC.selectedItem.value)
                          : 1),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<String> merkKendaraan = <String>[];
                          var dataMerk = snapshot.data!.docs;

                          dataMerk.map((DocumentSnapshot doc) {
                            merkKendaraan.add(
                                (doc.data() as Map<String, dynamic>)['nama']);
                          }).toList();

                          return Column(
                            children: [
                              Row(
                                children: <Widget>[
                                  Expanded(
                                      flex: 5,
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            12, 10, 12, 10),
                                        child: const Text(
                                          "Merk Kendaraan",
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      )),
                                  Expanded(
                                    flex: 8,
                                    child: SizedBox(
                                        height: 50,
                                        child: RawAutocomplete(
                                          key: _autocompleteKey,
                                          focusNode: _focusNode,
                                          textEditingController: mk,
                                          optionsBuilder:
                                              (TextEditingValue textValue) {
                                            if (textValue.text == '') {
                                              return const Iterable<
                                                  String>.empty();
                                            } else {
                                              List<String> matches = <String>[];
                                              matches.addAll(merkKendaraan);

                                              matches.retainWhere((s) {
                                                return s.toLowerCase().contains(
                                                    textValue.text
                                                        .toLowerCase());
                                              });
                                              return matches;
                                            }
                                          },
                                          onSelected: (String selection) {
                                            homeC.selectedMerk.value =
                                                selection;
                                          },
                                          fieldViewBuilder: (BuildContext
                                                  context,
                                              mk,
                                              FocusNode focusNode,
                                              VoidCallback onFieldSubmitted) {
                                            return TextField(
                                              decoration: const InputDecoration(
                                                  border: OutlineInputBorder()),
                                              controller: mk,
                                              focusNode: focusNode,
                                              onSubmitted: (String value) {},
                                            );
                                          },
                                          optionsViewBuilder: (BuildContext
                                                  context,
                                              void Function(String) onSelected,
                                              Iterable<String> options) {
                                            return Material(
                                                child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    child: Column(
                                                      children:
                                                          options.map((opt) {
                                                        return InkWell(
                                                            onTap: () {
                                                              onSelected(opt);
                                                            },
                                                            child: Container(
                                                              // color: const Colors.red,
                                                              width: double
                                                                  .infinity,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(10),
                                                              child: Text(opt),
                                                            ));
                                                      }).toList(),
                                                    )));
                                          },
                                        )),
                                  ),
                                  // ),
                                ],
                              )
                            ],
                          );
                        } else if (snapshot.hasError) {
                          // print(snapshot.error);
                          return Text('${snapshot.error}');
                        }
                        return const Center(
                          child: CupertinoActivityIndicator(),
                        );
                      }),
                ),

                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                        flex: 5,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                          child: const Text(
                            "Nomor Kendaraan",
                            style: TextStyle(fontSize: 17),
                          ),
                        )),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 55,
                        child: TextField(
                            textCapitalization: TextCapitalization.characters,
                            maxLength: 2,
                            textInputAction: TextInputAction.next,
                            controller: homeC.noPol1,
                            decoration: const InputDecoration(
                                counterText: '', border: OutlineInputBorder())),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: 55,
                        child: TextField(
                            textAlign: TextAlign.center,
                            maxLength: 4,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                            controller: homeC.noPol2,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              counterText: '',
                            )),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 55,
                        child: TextField(
                            maxLength: 3,
                            textCapitalization: TextCapitalization.characters,
                            textInputAction: TextInputAction.done,
                            controller: homeC.noPol3,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              counterText: '',
                            )),
                      ),
                    ),
                    // ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Obx(
          () => Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: FloatingActionButton(
              onPressed: homeC.tempStruk.isNotEmpty
                  ? () async {
                      Map<String, dynamic> printStruk = {};
                      printStruk.addAll(homeC.tempStruk.cast());
                      // print(printStruk);
                      await PrintSettingState(dataPrint: printStruk)
                          .printStruk();
                      homeC.tempStruk.clear();
                    }
                  : null,
              backgroundColor:
                  homeC.tempStruk.isNotEmpty ? Colors.blue : Colors.grey,
              tooltip: 'Copy Struk',
              child: const Icon(
                Icons.receipt_long,
                color: Colors.white,
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // backgroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(50), // NEW
                ),
                onPressed: () async {
                  var jenis = homeC.selectedItem.value;
                  var noTrx =
                      '${homeC.noUrutTrx.value}$dateNow-00${homeC.idTrx != 0 ? homeC.idTrx : 1}';
                  var merk = homeC.selectedMerk.value;
                  var nopol =
                      '${homeC.noPol1.text}-${homeC.noPol2.text}-${homeC.noPol3.text}';
                  if (merk.isEmpty &&
                      homeC.noPol1.text == "" &&
                      homeC.noPol2.text == "" &&
                      homeC.noPol3.text == "" &&
                      homeC.selectedItem.isEmpty) {
                    Fluttertoast.showToast(
                        msg: "Gagal, Anda belum mengisi data.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.redAccent[700],
                        textColor: Colors.white,
                        fontSize: 16.0);
                  } else if (homeC.selectedMerk.isEmpty) {
                    Fluttertoast.showToast(
                        msg: "Gagal, Merk tidak boleh kosong.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.redAccent[700],
                        textColor: Colors.white,
                        fontSize: 16.0);
                  } else if (homeC.noPol1.text.isEmpty &&
                      homeC.noPol2.text.isEmpty &&
                      homeC.noPol3.text.isEmpty) {
                    Fluttertoast.showToast(
                        msg: "Gagal, Nomor Kendaraan tidak boleh kosong.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.redAccent[700],
                        textColor: Colors.white,
                        fontSize: 16.0);
                  } else if (homeC.noPolisi.contains(nopol)) {
                    Fluttertoast.showToast(
                        msg: "Gagal, Nomor Kendaraan sudah terdaftar.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.redAccent[700],
                        textColor: Colors.white,
                        fontSize: 16.0);
                  } else {
                    await homeC.addTrx(homeC.idTrx, noTrx, homeC.cabang.value,
                        jenis, nopol, date, merk);
                    homeC.generateBarcode.value++;
                    homeC.selectedMerk.value = "";
                    mk.clear();

                    Fluttertoast.showToast(
                        msg: "Berhasil, Data Terkirim.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.greenAccent[700],
                        textColor: Colors.white,
                        fontSize: 16.0);
                    // homeC.selectedMer
                    Map<String, dynamic> struk = {};
                    var dataPrint = {
                      "no_trx": noTrx,
                      "tanggal": DateFormat("yyy-MM-dd HH:mm:ss")
                          .format(DateTime.now())
                          .toString(),
                      "user": user,
                      "jeniskendaraan": merk,
                      "no_polisi": nopol
                    };
                    struk.addAll(dataPrint);
                    homeC.tempStruk.addAll(dataPrint);
                    // print(struk);
                    PrintSettingState(dataPrint: struk).printStruk();
                  }
                },
                child: const Text(
                  'Simpan',
                  style: TextStyle(fontSize: 20),
                ))),
      ),
    );
  }
}
