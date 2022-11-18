import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:data_table_2/data_table_2.dart';

import '../controllers/master_controller.dart';

class MasterKendaraan extends GetView<MasterController> {
  MasterKendaraan({super.key});

  final masterC = Get.put(MasterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Object?>>(
        stream: masterC.streamDataMerk(),
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
                    DataColumn2(
                        label: Text('No '),
                        // size: ColumnSize.S,
                        fixedWidth: 30),
                    DataColumn(
                      label: Text('Nama Kendaraan'),
                    ),
                    DataColumn(
                      label: Text('Jenis Kendaraan'),
                    ),
                    DataColumn(
                      label: Text('Action'),
                    ),
                  ],
                  rows: List<DataRow>.generate(list.length, (index) {
                    masterC.idKendaraan = list[index]["id"] + 1;

                    return DataRow(cells: [
                      DataCell(Text(list[index]["id"].toString())),
                      DataCell(Text(list[index]["nama"])),
                      DataCell(Text(
                          list[index]["id_jenis"] == 1 ? "Motor" : "Mobil")),
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
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          ElevatedButton(
                                              onPressed: () {
                                                masterC
                                                    .deleteMerk(data[index].id);
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
            addkendaraan(masterC.idKendaraan);
          },
          child: const Icon(Icons.add)),
    );
  }

  void editData(id, nama) {
    Get.defaultDialog(
        radius: 5,
        title: 'Edit Data Kendaraan',
        content: Column(
          children: [
            SizedBox(
                height: 45,
                child: TextField(
                  controller: masterC.namaMerk,
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.car_rental),
                      hintText: nama,
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)))),
                )),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: ElevatedButton(
                      onPressed: () {
                        masterC.updateMerk(id, masterC.namaMerk.text);
                        masterC.namaMerk.clear();
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

  addkendaraan(int id) {
    Get.defaultDialog(
        radius: 5,
        title: 'Tambah Data Kendaraan',
        content: Column(
          children: [
            StreamBuilder(
              stream: masterC.streamDatajk(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Obx(
                    () => DropdownButtonFormField(
                      decoration: const InputDecoration(
                          hintText: 'Jenis Kendaraan',
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)))),
                      value: masterC.selectedjenisKendaraan.value == ""
                          ? null
                          : masterC.selectedjenisKendaraan.value,
                      // isDense: true,
                      onChanged: (String? data) {
                        masterC.selectedjenisKendaraan.value = data!;
                      },
                      items: snapshot.data!.docs.map((DocumentSnapshot doc) {
                        return DropdownMenuItem<String>(
                            value: (doc.data() as Map<String, dynamic>)["id"]
                                .toString(),
                            child: Text(
                              '${(doc.data() as Map<String, dynamic>)["jenis"]}',
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
            SizedBox(
                height: 50,
                child: TextField(
                  controller: masterC.namaMerk,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.car_rental),
                      label: Text('Nama Kendaraan'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)))),
                )),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: ElevatedButton(
                      onPressed: () {
                        masterC.addMerk(
                            id,
                            int.parse(masterC.selectedjenisKendaraan.value),
                            masterC.namaMerk.text);
                        Get.back();
                        masterC.namaMerk.clear();
                        masterC.selectedjenisKendaraan.value = "";
                      },
                      child: const Text(
                        'Simpan',
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
}
