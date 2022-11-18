import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carwash/app/helper/alert.dart';
import 'package:get/get.dart';
import 'package:data_table_2/data_table_2.dart';

import '../controllers/master_controller.dart';

class MasterLevel extends GetView<MasterController> {
  MasterLevel({super.key});

  final masterC = Get.put(MasterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Object?>>(
        stream: masterC.streamDataLevel(),
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
                      label: Text('Level'),
                    ),
                    DataColumn(
                      label: Text('Action'),
                    ),
                  ],
                  rows: List<DataRow>.generate(list.length, (index) {
                    masterC.idLevel = list[index]["id"] + 1;
                    return DataRow(cells: [
                      DataCell(Text(list[index]["id"].toString())),
                      DataCell(Text(list[index]["nama"])),
                      DataCell(Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              editData(data[index].id, list[index]["nama"]);
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
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  minimumSize:
                                                      const Size(75, 45)),
                                              onPressed: () {
                                                masterC.deleteLevel(
                                                    data[index].id);
                                              },
                                              child: const Text(
                                                'Ya',
                                                style: TextStyle(fontSize: 14),
                                              )),
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  minimumSize:
                                                      const Size(75, 45)),
                                              onPressed: () {
                                                Get.back();
                                              },
                                              child: const Text(
                                                'Tidak',
                                                style: TextStyle(fontSize: 14),
                                              )),
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
            addData(masterC.idLevel);
          },
          child: const Icon(Icons.add)),
    );
  }

  void editData(id, nama) {
    Get.defaultDialog(
        radius: 5,
        title: 'Edit Data',
        content: Column(
          children: [
            const Divider(),
            SizedBox(
                height: 45,
                child: TextField(
                  controller: masterC.namaLevel,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      prefixIcon: const Icon(Icons.account_tree_sharp),
                      hintText: nama),
                )),
            const SizedBox(
              height: 5,
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(75, 45)),
                      onPressed: () {
                        if (masterC.namaLevel.text == "") {
                          masterC.namaLevel.text = nama;
                        }
                        masterC.updateLevel(id, masterC.namaLevel.text);
                        Get.back();
                        masterC.namaLevel.clear();
                      },
                      child: const Text(
                        'Update',
                        style: TextStyle(fontSize: 15),
                      ),
                    )),
                Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(75, 45)),
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

  addData(id) {
    Get.defaultDialog(
        radius: 5,
        title: 'Tambah Data',
        content: Column(
          children: [
            const Divider(),
            SizedBox(
                height: 45,
                child: TextField(
                  controller: masterC.namaLevel,
                  decoration: const InputDecoration(
                      label: Text('Nama Level'),
                      prefixIcon: Icon(Icons.account_tree_sharp),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)))),
                )),
            const SizedBox(
              height: 5,
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(75, 45)),
                      onPressed: () {
                        if (masterC.namaLevel.text == "") {
                          showSnackbar("Error", "Data tidak boleh kosong!");
                        } else {
                          masterC.addLevel(id, masterC.namaLevel.text);
                          Get.back();
                          masterC.namaLevel.clear();
                        }
                      },
                      child: const Text(
                        'Simpan',
                        style: TextStyle(fontSize: 15),
                      ),
                    )),
                Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(75, 45)),
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
}
