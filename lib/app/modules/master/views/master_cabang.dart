import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carwash/app/helper/alert.dart';
import 'package:get/get.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';

import '../controllers/master_controller.dart';

class MasterCabang extends GetView<MasterController> {
  MasterCabang({super.key});

  final masterC = Get.put(MasterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Object?>>(
        stream: masterC.streamDataCabang(),
        builder: (context, snapshot) {
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
              // print(list);
              return DataTable2(
                  columnSpacing: 1,
                  horizontalMargin: 8,
                  minWidth: 600,
                  showBottomBorder: true,
                  headingTextStyle: const TextStyle(color: Colors.white),
                  headingRowColor: MaterialStateProperty.resolveWith(
                      (states) => Colors.lightBlue),
                  columns: const [
                    DataColumn(
                      label: Text('No '),
                      // size: ColumnSize.S,
                    ),
                    DataColumn(
                      label: Text('Cabang'),
                    ),
                    DataColumn(
                      label: Text('Kota'),
                    ),
                    DataColumn(
                      label: Text('Alamat'),
                    ),
                    DataColumn(
                      label: Text('No Telp'),
                    ),
                    DataColumn(
                      label: Text('Users'),
                    ),
                    DataColumn(
                      label: Text('Karyawan'),
                    ),
                    DataColumn(
                      label: Text('Action'),
                    ),
                  ],
                  rows: List<DataRow>.generate(list.length, (index) {
                    var users = [];
                    var karyawans = [];
                    // var userCab = [];
                    // for (int i = 0; i < list[index]["users"].length; i++) {
                    //   var user = list[index]["users"][i]["nama"];
                    //   userCab.add(user);
                    // }

                    // var karyawanCab = [];
                    // for (int i = 0; i < list[index]["karyawan"].length; i++) {
                    //   var emp = list[index]["karyawan"][i]["nama"];
                    //   karyawanCab.add(emp);
                    // }
                    // print(karyawanCab);
                    // masterC.user.value = userCab;
                    if (list[index]["id"] == "") {
                      masterC.noUrut = masterC.noUrut;
                    } else {
                      masterC.noUrut = list.length + 1;
                    }

                    return DataRow(cells: [
                      DataCell(Text(list[index]["kode_cabang"])),
                      DataCell(Text(list[index]["nama_cabang"])),
                      DataCell(Text(list[index]["kota"])),
                      DataCell(Text(list[index]["alamat"] != ""
                          ? list[index]["alamat"]
                          : "alamat belum di isi")),
                      DataCell(Text(list[index]["telp"] != ""
                          ? list[index]["telp"]
                          : "Telpon belum di isi")),
                      DataCell(StreamBuilder(
                          stream: masterC.streamDataUserByCabang(
                              list[index]["kode_cabang"]),
                          builder: ((context, snapshot) {
                            if (snapshot.hasData) {
                              var users = [];
                              snapshot.data!.docs
                                  .map((e) => users.add((e.data()
                                      as Map<String, dynamic>)["nama"]))
                                  .toList();

                              return Text(users.isNotEmpty
                                  ? users.join(', ')
                                  : "Belum ada user");
                            } else if (snapshot.hasError) {
                              return Text('${snapshot.error}');
                            }
                            return const Center(
                              child: CupertinoActivityIndicator(),
                            );
                          }))),
                      DataCell(StreamBuilder(
                          stream: masterC.streamDataKaryawanByCabang(
                              list[index]["kode_cabang"]),
                          builder: ((context, snapshot) {
                            if (snapshot.hasData) {
                              snapshot.data!.docs
                                  .map((e) => karyawans.add((e.data()
                                      as Map<String, dynamic>)["nama"]))
                                  .toList();

                              return Text(karyawans.isNotEmpty
                                  ? karyawans.join(', ')
                                  : "Belum ada karyawan");
                            } else if (snapshot.hasError) {
                              return Text('${snapshot.error}');
                            }
                            return const Center(
                              child: CupertinoActivityIndicator(),
                            );
                          }))),
                      DataCell(Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              editData(
                                  data[index].id,
                                  list[index]["kode_cabang"],
                                  list[index]["nama_cabang"],
                                  list[index]["kota"],
                                  list[index]["alamat"],
                                  list[index]["telp"]);
                            },
                            icon: const Icon(
                              Icons.edit_note_sharp,
                              size: 30,
                              color: Colors.lightBlue,
                            ),
                            splashRadius: 20,
                          ),
                          IconButton(
                            onPressed: () {
                              Get.defaultDialog(
                                  radius: 5,
                                  title: 'Peringatan',
                                  content: Column(
                                    children: [
                                      const Text(
                                          'Anda yakin ingin menghapus data ini?'),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          ElevatedButton(
                                              onPressed: () {
                                                masterC.deleteCabang(
                                                    data[index].id);
                                                masterC.removeUserCabang(users);
                                                masterC.removeKaryawanCabang(
                                                    karyawans);
                                              },
                                              child: const Text('Hapus')),
                                          ElevatedButton(
                                              onPressed: () {
                                                Get.back();
                                              },
                                              child: const Text('Batal')),
                                        ],
                                      )
                                    ],
                                  ));
                            },
                            icon: const Icon(
                              Icons.delete,
                              size: 30,
                              color: Colors.lightBlue,
                            ),
                            splashRadius: 20,
                          ),
                        ],
                      )),
                    ]);
                  }));
            }
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            addCabang();
          },
          child: const Icon(Icons.add)),
    );
  }

  editData(id, kode, nama, kota, alamat, telpon) {
    Get.defaultDialog(
        radius: 5,
        title: 'Edit Data Cabang',
        content: Column(
          children: [
            Row(
              children: <Widget>[
                Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: const Text(
                        "Nama Cabang",
                        style: TextStyle(fontSize: 17),
                      ),
                    )),
                Expanded(
                  flex: 8,
                  child: SizedBox(
                      height: 20,
                      child: Text(nama, style: const TextStyle(fontSize: 17))),
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
                        "Kota",
                        style: TextStyle(fontSize: 17),
                      ),
                    )),
                Expanded(
                  flex: 8,
                  child: SizedBox(
                      height: 20,
                      child: Text(kota, style: const TextStyle(fontSize: 17))),
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
                        "Alamat",
                        style: TextStyle(fontSize: 17),
                      ),
                    )),
                Expanded(
                  flex: 8,
                  child: SizedBox(
                      height: 110,
                      width: 76,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          TextFormField(
                              controller: masterC.alamatCabang..text = alamat,
                              maxLines: 3,
                              style: const TextStyle(fontSize: 17)),
                        ],
                      )),
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
                        "No Telpon",
                        style: TextStyle(fontSize: 17),
                      ),
                    )),
                Expanded(
                  flex: 8,
                  child: SizedBox(
                      height: 48,
                      width: 46,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          TextFormField(
                              controller: masterC.telpCabang..text = telpon,
                              style: const TextStyle(fontSize: 17)),
                        ],
                      )),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: ElevatedButton(
                      onPressed: () {
                        var namaCab = "";
                        var kotaCab = "";
                        var alamatCab = "";
                        var telponCab = "";
                        // if (masterC.namaCabang.text == "" &&
                        //     masterC.kotaCabang.text == "") {
                        //   namaCab = nama;
                        //   kotaCab = kota;
                        // } else {
                        //else if (masterC.namaCabang.text != "") {
                        //   namaCab = masterC.namaCabang.text;
                        //   kotaCab = kota;
                        //   alamatCab = alamat;
                        //   telponCab = telpon;
                        // } else if (masterC.kotaCabang.text != "") {
                        //   namaCab = nama;
                        //   kotaCab = masterC.kotaCabang.text;
                        //   alamatCab = alamat;
                        //   telponCab = telpon;
                        // } else if (masterC.alamatCabang.text != "") {
                        //   namaCab = nama;
                        //   kotaCab = kota;
                        //   alamatCab = masterC.alamatCabang.text;
                        //   telponCab = telpon;
                        // } else if (masterC.telpCabang.text != "") {
                        //   namaCab = nama;
                        //   kotaCab = kota;
                        //   alamatCab = alamat;
                        //   telponCab = masterC.telpCabang.text;
                        // } else {
                        // namaCab = masterC.namaCabang.text;
                        // kotaCab = masterC.kotaCabang.text;
                        namaCab = nama;
                        kotaCab = kota;
                        alamatCab = masterC.alamatCabang.text;
                        telponCab = masterC.telpCabang.text;
                        // }

                        // print(masterC.karyawanList);

                        masterC.updateDataCabang(
                            id, namaCab, kotaCab, alamatCab, telponCab);
                        // masterC.updateUserCabang(kode, users);
                        // masterC.updateKaryawanCabang(kode, karyawan);
                        // print(kode);
                        masterC.namaCabang.clear();
                        masterC.kotaCabang.clear();
                        masterC.alamatCabang.clear();
                        masterC.telpCabang.clear();
                        Get.back();
                      },
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
                      child: const Text(
                        'Batal',
                        style: TextStyle(fontSize: 15),
                      ),
                    )),
              ],
            ),
          ],
        ));
  }

  void addCabang() {
    Get.defaultDialog(
        radius: 5,
        title: 'Tambah Cabang Baru',
        content: Column(
          children: [
            const Divider(),
            TextField(
              controller: masterC.namaCabang,
              decoration: InputDecoration(
                  label: const Text('Nama Cabang'),
                  prefixIcon: const Icon(Icons.business_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30))),
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
              controller: masterC.kotaCabang,
              decoration: InputDecoration(
                  label: const Text('kota'),
                  prefixIcon: const Icon(Icons.map_sharp),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30))),
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
              controller: masterC.alamatCabang,
              decoration: InputDecoration(
                  label: const Text('Alamat'),
                  prefixIcon: const Icon(Icons.corporate_fare_rounded),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30))),
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
              controller: masterC.telpCabang,
              decoration: InputDecoration(
                  label: const Text('No Telpon'),
                  prefixIcon: const Icon(Icons.phone_iphone_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30))),
            ),
            const SizedBox(
              height: 5,
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(45, 45)),
                    onPressed: () {
                      if (masterC.alamatCabang.text == "") {
                        showSnackbar('Error', 'alamat tidak boleh kosong');
                      } else if (masterC.namaCabang.text == "") {
                        showSnackbar('Error', 'nama cabang tidak boleh kosong');
                      } else {
                        var kodeCabang = '00${masterC.noUrut}';
                        masterC.addCabang(
                            masterC.noUrut,
                            kodeCabang,
                            masterC.namaCabang.text,
                            masterC.kotaCabang.text,
                            masterC.alamatCabang.text,
                            masterC.telpCabang.text);

                        masterC.alamatCabang.clear();
                        masterC.namaCabang.clear();
                        masterC.kotaCabang.clear();
                        masterC.telpCabang.clear();
                      }
                    },
                    child: const Text(
                      'Simpan',
                      style: TextStyle(fontSize: 17),
                    )),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(45, 45)),
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text(
                      'Batal',
                      style: TextStyle(fontSize: 17),
                    )),
              ],
            )
          ],
        ));
  }
}
