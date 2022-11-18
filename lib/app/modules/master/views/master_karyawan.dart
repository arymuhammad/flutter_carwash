import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../home/controllers/auth_controller.dart';
import '../controllers/master_controller.dart';

class MasterKaryawan extends GetView<MasterController> {
  MasterKaryawan({super.key});

  final masterC = Get.put(MasterController());
  final authC = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Object?>>(
        stream: masterC.streamDataKaryawan(),
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
                      label: Text('Kode Cabang'),
                      // size: ColumnSize.S,
                    ),
                    DataColumn(
                      label: Text('Nama'),
                    ),
                    DataColumn(
                      label: Text('Persentase'),
                    ),
                    DataColumn(
                      label: Text('Action'),
                    ),
                  ],
                  rows: List<DataRow>.generate(list.length, (index) {
                    masterC.noUrut = list.length + 1;

                    return DataRow(cells: [
                      DataCell(Text(list[index]["cabang"] != ""
                          ? list[index]["cabang"]
                          : 'Belum terdaftar dicabang manapun')),
                      DataCell(Text(list[index]["nama"])),
                      DataCell(Text(list[index]["persen"].toString())),
                      DataCell(Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              editData(data[index].id, list[index]["nama"],
                                  list[index]["persen"]);
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
                              // print(data[index].id);
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
                                                masterC.deleteKaryawan(
                                                    data[index].id);
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
            return const Text('Belum ada data');
          }
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            addKaryawan();
          },
          child: const Icon(Icons.add)),
    );
  }

  void editData(id, nama, persentase) {
    Get.defaultDialog(
        radius: 5,
        title: 'Detail Data',
        content: Column(
          children: [
            SizedBox(
              height: 45,
              child: TextField(
                controller: masterC.namaLengkap,
                decoration: InputDecoration(
                    hintText: nama, border: const OutlineInputBorder()),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            SizedBox(
              height: 45,
              child: TextField(
                controller: masterC.persentase,
                decoration: InputDecoration(
                    hintText: persentase, border: const OutlineInputBorder()),
              ),
            ),
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
                        masterC.updateKaryawan(id, masterC.namaLengkap.text,
                            masterC.persentase.text);
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

  addKaryawan() {
    Get.defaultDialog(
        radius: 5,
        title: 'Tambah Karyawan',
        content: Column(
          children: [
            const Divider(),
            TextField(
              controller: masterC.namaLengkap,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), label: Text('Nama Lengkap')),
            ),
            const SizedBox(
              height: 5,
            ),
            StreamBuilder(
              stream: masterC.streamDataCabang(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Obx(
                    () => DropdownButtonFormField(
                      decoration: const InputDecoration(
                          hintText: 'Pilih Cabang',
                          border: OutlineInputBorder()),
                      value: masterC.selectedCabangKaryawan.value == ""
                          ? null
                          : masterC.selectedCabangKaryawan.value,
                      // isDense: true,
                      onChanged: (String? data) {
                        masterC.selectedCabangKaryawan.value = data!;
                      },
                      items: snapshot.data!.docs.map((DocumentSnapshot doc) {
                        return DropdownMenuItem<String>(
                            value: (doc.data()
                                    as Map<String, dynamic>)["kode_cabang"]
                                .toString(),
                            child: Text(
                              '${(doc.data() as Map<String, dynamic>)["nama_cabang"]}',
                            ));
                      }).toList(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              },
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
              controller: masterC.persentase,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), label: Text('Persentase')),
            ),
            const SizedBox(
              height: 5,
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      masterC.addKaryawan(
                          masterC.noUrut,
                          masterC.namaLengkap.text,
                          masterC.selectedCabangKaryawan.value,
                          masterC.persentase.text);
                      masterC.selectedCabangKaryawan.value == "";
                      masterC.namaLengkap.clear();
                      masterC.persentase.clear();
                    },
                    child: const Text('Simpan')),
                ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text('Batal'))
              ],
            )
          ],
        ));
  }
}
