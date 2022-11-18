import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carwash/app/helper/alert.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/services_controller.dart';

class ServicesView extends GetView<ServicesController> {
  ServicesView({Key? key}) : super(key: key);

  final serviceC = Get.put(ServicesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Object?>>(
        stream: serviceC.getServices(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data!.docs;
            List<Map<String, dynamic>> list = [];
            data.map((DocumentSnapshot doc) {
              list.add((doc.data() as Map<String, dynamic>));
              // print((doc.data() as Map<String, dynamic>)["no_polisi"]);
            }).toList();

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            } else {
              return DataTable2(
                  columnSpacing: 1,
                  horizontalMargin: 5,
                  minWidth: 600,
                  showBottomBorder: true,
                  headingTextStyle: const TextStyle(color: Colors.white),
                  headingRowColor: MaterialStateProperty.resolveWith(
                      (states) => Colors.lightBlue),
                  columns: const [
                    DataColumn2(
                        label: Text('No'),
                        // size: ColumnSize.S,
                        fixedWidth: 30),
                    DataColumn2(
                        label: Text('Nama Service'), size: ColumnSize.S),
                    DataColumn2(label: Text('Harga'), size: ColumnSize.S),
                    DataColumn2(label: Text('Action'), size: ColumnSize.S),
                  ],
                  rows: List<DataRow>.generate(list.length, (index) {
                    serviceC.id = list[index]["id"] + 1;
                    return DataRow(cells: [
                      DataCell(Text(list[index]["id"].toString())),
                      DataCell(Text(list[index]["nama"])),
                      DataCell(Text(NumberFormat.simpleCurrency(
                              locale: 'in', decimalDigits: 0)
                          .format(list[index]["harga"])
                          .toString())),
                      DataCell(Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              editData(data[index].id, list[index]["nama"],
                                  list[index]["harga"]);
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
                              deleteData(data[index].id);
                            },
                            icon: const Icon(
                              Icons.delete_outline_outlined,
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
          addData(serviceC.id);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  editData(id, nama, harga) {
    Get.defaultDialog(
        radius: 5,
        title: 'Edit Jenis Service',
        content: Column(
          children: [
            const Divider(),
            SizedBox(
              height: 45,
              child: TextField(
                controller: serviceC.nama,
                decoration: InputDecoration(
                    hintText: nama, border: const OutlineInputBorder()),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 45,
              child: TextField(
                controller: serviceC.harga,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: harga.toString(), border: const OutlineInputBorder()),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      if (serviceC.nama.text == "") {
                        serviceC.nama.text = nama;
                      } else if (serviceC.harga.text == "") {
                        serviceC.harga.text = harga;
                      }
                      serviceC.updateService(id, serviceC.nama.text,
                          int.parse(serviceC.harga.text));
                      Get.back();
                      serviceC.nama.clear();
                      serviceC.harga.clear();
                    },
                    child: const Text('Update')),
                ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text('Batal')),
              ],
            )
          ],
        ));
  }

  deleteData(String id) {
    Get.defaultDialog(
        radius: 5,
        title: 'Peringatan',
        content: Column(
          children: [
            const Text('Anda yakin ingin menghapus data ini?'),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      await serviceC.deleteService(id);
                      Get.back();
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
  }

  addData(int id) {
    Get.defaultDialog(
        radius: 5,
        title: 'Tambah Jenis Service',
        content: Column(
          children: [
            const Divider(),
            SizedBox(
              height: 45,
              child: TextField(
                controller: serviceC.nama,
                decoration: const InputDecoration(
                    hintText: 'Nama Service',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)))),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 45,
              child: TextField(
                controller: serviceC.harga,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    hintText: 'Rp',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)))),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      if (serviceC.nama.text == "" &&
                          serviceC.harga.text == "") {
                        showSnackbar("Error", "Data tidak boleh kosong");
                      } else {
                        serviceC.addService(id, serviceC.nama.text,
                            int.parse(serviceC.harga.text));
                        Get.back();
                        serviceC.nama.clear();
                        serviceC.harga.clear();
                      }
                    },
                    child: const Text('Simpan')),
                ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text('Batal')),
              ],
            )
          ],
        ));
  }
}
