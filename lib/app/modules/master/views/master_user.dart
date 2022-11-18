import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carwash/app/helper/alert.dart';
import 'package:get/get.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../home/controllers/auth_controller.dart';
import '../controllers/master_controller.dart';

class MasterUsers extends GetView<MasterController> {
  MasterUsers({super.key});

  final masterC = Get.put(MasterController());
  final authC = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Object?>>(
        stream: masterC.streamDataUsers(),
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
                      label: Text('Username'),
                    ),
                    DataColumn(
                      label: Text('Nama Lengkap'),
                    ),
                    DataColumn(
                      label: Text('Level'),
                    ),
                    DataColumn(
                      label: Text('No Telpon'),
                    ),
                    DataColumn(
                      label: Text('Action'),
                    ),
                  ],
                  rows: List<DataRow>.generate(list.length, (index) {
                    masterC.noUrut = list.length + 1;
                    // print(masterC.noUrut);
                    return DataRow(cells: [
                      DataCell(Text(list[index]["kode_cabang"] != ""
                          ? list[index]["kode_cabang"]
                          : 'Belum terdaftar dicabang manapun')),
                      DataCell(Text(list[index]["email"])),
                      DataCell(Text(list[index]["nama"])),
                      DataCell(StreamBuilder(
                        stream:
                            masterC.streamDataLevelByid(list[index]["level"]),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var level = "";
                            snapshot.data!.docs.map((DocumentSnapshot e) {
                              return level =
                                  (e.data() as Map<String, dynamic>)["nama"];
                            }).toList();
                            return Text(level);
                          } else if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          }
                          return const Center(
                            child: CupertinoActivityIndicator(),
                          );
                        },
                      )),
                      DataCell(Text(list[index]["notelp"].toString())),
                      DataCell(Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              editData(
                                  data[index].id,
                                  list[index]["email"],
                                  list[index]["nama"],
                                  list[index]["notelp"],
                                  list[index]["level"],
                                  list[index]["kode_cabang"]);
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
                                  title: 'Hapus Akun',
                                  content: Column(
                                    children: [
                                      Text(
                                          'Apakah Anda yakin ingin menghapus data ini?\n${list[index]["nama"]}'),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton(
                                              onPressed: () {
                                                masterC
                                                    .deleteUser(data[index].id);
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
            addUser();
          },
          child: const Icon(Icons.add)),
    );
  }

  editData(id, username, nama, telp, level, cabang) {
    Get.defaultDialog(
        radius: 5,
        title: 'Detail Data',
        content: Column(
          children: [
            const Divider(),
            TextField(
              readOnly: true,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: username,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
              controller: masterC.namaLengkap,
              decoration: InputDecoration(
                  border: const OutlineInputBorder(), hintText: nama),
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
              controller: masterC.notelp,
              decoration: InputDecoration(
                  border: const OutlineInputBorder(), hintText: telp),
            ),
            const SizedBox(
              height: 5,
            ),
            StreamBuilder(
              stream: masterC.getLevel(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Obx(
                    () => DropdownButtonFormField(
                      decoration: const InputDecoration(
                          hintText: 'Level User', border: OutlineInputBorder()),
                      value: masterC.selectedLevel.value == ""
                          ? null
                          : masterC.selectedLevel.value,
                      // isDense: true,
                      onChanged: (String? data) {
                        masterC.selectedLevel.value = data!;
                        // print(homeC.selectedItem);
                      },
                      items: snapshot.data!.docs.map((DocumentSnapshot doc) {
                        return DropdownMenuItem<String>(
                            value: (doc.data() as Map<String, dynamic>)["id"]
                                .toString(),
                            child: Text(
                              '${(doc.data() as Map<String, dynamic>)["nama"]}',
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
            const SizedBox(height: 5),
            StreamBuilder(
              stream: masterC.streamDataCabang(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Obx(
                    () => DropdownButtonFormField(
                      decoration: const InputDecoration(
                          hintText: 'Pilih Cabang',
                          border: OutlineInputBorder()),
                      value: masterC.selectedCabang.value == ""
                          ? null
                          : masterC.selectedCabang.value,
                      // isDense: true,
                      onChanged: (String? data) {
                        masterC.selectedCabang.value = data!;
                        // print(homeC.selectedItem);
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
            const Divider(),
            Row(
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: ElevatedButton(
                      onPressed: () {
                        if (masterC.namaLengkap.text == "") {
                          masterC.namaLengkap.text = nama;
                        } else {
                          masterC.namaLengkap.text = masterC.namaLengkap.text;
                        }
                        if (masterC.notelp.text == "") {
                          masterC.notelp.text = telp;
                        } else {
                          masterC.notelp.text = masterC.notelp.text;
                        }
                        if (masterC.selectedLevel.isEmpty) {
                          masterC.selectedLevel.value = level.toString();
                        } else {
                          masterC.selectedLevel.value =
                              masterC.selectedLevel.value;
                        }

                        if (masterC.selectedCabang.isEmpty) {
                          masterC.selectedCabang.value = cabang;
                        } else {
                          masterC.selectedCabang.value =
                              masterC.selectedCabang.value;
                        }
                        masterC.updateUser(
                            id,
                            masterC.namaLengkap.text,
                            masterC.notelp.text,
                            masterC.selectedLevel.value,
                            masterC.selectedCabang.value);
                        Get.back();
                        masterC.namaLengkap.clear();
                        masterC.notelp.clear();
                        masterC.selectedLevel.value = "";
                        masterC.selectedCabang.value = "";
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

  addUser() {
    Get.defaultDialog(
        radius: 5,
        title: 'Tambah User',
        content: Column(
          children: [
            const Divider(),
            TextField(
              controller: masterC.email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), label: Text('Username')),
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
              controller: masterC.password,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text('Password'),
              ),
              obscureText: true,
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
              controller: masterC.nama,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), label: Text('Nama Lengkap')),
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
              controller: masterC.notelp,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), label: Text('No Telpon')),
            ),
            const SizedBox(
              height: 5,
            ),
            StreamBuilder(
              stream: masterC.getLevel(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Obx(
                    () => DropdownButtonFormField(
                      decoration: const InputDecoration(
                          hintText: 'Level User', border: OutlineInputBorder()),
                      value: masterC.selectedLevel.value == ""
                          ? null
                          : masterC.selectedLevel.value,
                      // isDense: true,
                      onChanged: (String? data) {
                        masterC.selectedLevel.value = data!;
                        // print(homeC.selectedItem);
                      },
                      items: snapshot.data!.docs.map((DocumentSnapshot doc) {
                        return DropdownMenuItem<String>(
                            value: (doc.data() as Map<String, dynamic>)["id"]
                                .toString(),
                            child: Text(
                              '${(doc.data() as Map<String, dynamic>)["nama"]}',
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
            const SizedBox(height: 5),
            StreamBuilder(
              stream: masterC.streamDataCabang(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Obx(
                    () => DropdownButtonFormField(
                      decoration: const InputDecoration(
                          hintText: 'Pilih Cabang',
                          border: OutlineInputBorder()),
                      value: masterC.selectedCabang.value == ""
                          ? null
                          : masterC.selectedCabang.value,
                      // isDense: true,
                      onChanged: (String? data) {
                        masterC.selectedCabang.value = data!;
                        // print(homeC.selectedItem);
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
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      if (masterC.email.text == "") {
                        showDefaultDialog(
                            "Perhatian", "Username tidak boleh kosong");
                      } else if (masterC.password.text == "") {
                        showDefaultDialog(
                            "Perhatian", "Password tidak boleh kosong");
                      } else if (masterC.selectedLevel.value == "") {
                        showDefaultDialog(
                            "Perhatian", "Level tidak boleh kosong");
                      } else if (masterC.selectedCabang.isEmpty) {
                        showDefaultDialog(
                            "Perhatian", "Harap pilih nama cabang");
                      } else {
                        Get.defaultDialog(
                            barrierDismissible: false,
                            title: '',
                            content: Column(
                              children: const [
                                Center(
                                  child: CircularProgressIndicator(),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text('Loading data...')
                              ],
                            ));
                        await masterC.signUp();
                      }
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
