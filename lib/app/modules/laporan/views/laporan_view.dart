import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:get/get.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import '../../../helper/alert.dart';
import '../controllers/laporan_controller.dart';

class LaporanView extends GetView<LaporanController> {
  LaporanView(this.cabang, this.level, {super.key});

  final String cabang;
  final int? level;
  final lapC = Get.put(LaporanController());
  TextEditingController dateInputAwal = TextEditingController();
  TextEditingController dateInputAkhir = TextEditingController();
  var dateNow1 = DateFormat('yyyy-MM-dd').format(DateTime.now());
  var dateNow2 = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => FutureBuilder<List<QueryDocumentSnapshot<Object?>>>(
          future: lapC.getSummary(
              lapC.date1.value != ""
                  ? lapC.date1.value
                  : lapC.date1.value = dateNow1,
              lapC.date2.value != ""
                  ? lapC.date2.value
                  : lapC.date2.value = dateNow2,
              cabang,
              level,
              0),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var lap = snapshot.data!;
              var totalUnit = lap.length;
              var tempData = [];
              // var sumKendaraan = [];
              lap.map((DocumentSnapshot e) {
                tempData.add((e.data() as Map<String, dynamic>)["grand_total"]);
              }).toList();

              // print(tempData);
              lap.map((DocumentSnapshot e) {
                lapC.tempJenisKendaraan
                    .add((e.data() as Map<String, dynamic>)["id_jenis"]);
              }).toList();

              lapC.tempSummService.value = lap.map((DocumentSnapshot e) {
                return (e.data() as Map<String, dynamic>);
              }).toList();

              var srvc = [];
              var summServ = [];
              for (int i = 0; i < lapC.tempSummService.length; i++) {
                srvc.add(lapC.tempSummService[i]["services"]);
                for (int idx = 0;
                    idx < lapC.tempSummService[i]["services"].length;
                    idx++) {
                  summServ.add(
                      lapC.tempSummService[i]["services"][idx]["id_service"]);
                }
              }

              int netSales = tempData.fold(
                  0, (temp, grandTotal) => temp + grandTotal as int);
              return SingleChildScrollView(
                child: SizedBox(
                  height: 800,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'SALES SUMMARY',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            // const SizedBox(
                            //   width: 38,
                            // ),
                            Text(
                                lapC.date1.value != "" && lapC.date2.value != ""
                                    ? '${DateFormat('dd/MM/yyyy').format(DateTime.parse(lapC.date1.value))} - ${DateFormat('dd/MM/yyyy').format(DateTime.parse(lapC.date2.value))}'
                                    : '${DateFormat('dd/MM/yyyy').format(DateTime.now())} - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('NET SALES'),
                        trailing: Text(
                            NumberFormat.simpleCurrency(
                                    locale: 'in', decimalDigits: 0)
                                .format(netSales)
                                .toString(),
                            style: const TextStyle(
                              fontSize: 15,
                            )),
                      ),
                      ListTile(
                        title: const Text('TOTAL UNIT'),
                        trailing: Text('$totalUnit',
                            style: const TextStyle(
                              fontSize: 15,
                            )),
                      ),
                      const Divider(),
                      Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('TOP ITEMS',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DataTable2(
                              columnSpacing: 1,
                              horizontalMargin: 2,
                              minWidth: 300,
                              showBottomBorder: true,
                              headingTextStyle:
                                  const TextStyle(color: Colors.white),
                              headingRowColor:
                                  MaterialStateProperty.resolveWith(
                                      (states) => Colors.lightBlue),
                              columns: const [
                                DataColumn(
                                  label: Text('Unit'),
                                  // size: ColumnSize.S,
                                ),
                                DataColumn(
                                  label: Text('Qty Unit'),
                                ),
                                DataColumn(
                                  label: Text('Total Sales'),
                                ),
                              ],
                              rows: List<DataRow>.generate(
                                  2
                                  // lapC.tempJenisKendaraan.groupSetsBy((element) => element).length
                                  , (index) {
                                return DataRow(cells: [
                                  DataCell(Text(index == 0 ? 'Mobil' : 'Motor',
                                      style: const TextStyle(
                                        fontSize: 15,
                                      )
                                      // Text('data')
                                      )),
                                  DataCell(Obx(
                                    () => FutureBuilder<
                                            List<
                                                QueryDocumentSnapshot<
                                                    Object?>>>(
                                        future: lapC.getSummary(
                                            lapC.date1.value != ""
                                                ? lapC.date1.value
                                                : dateNow1,
                                            lapC.date2.value != ""
                                                ? lapC.date2.value
                                                : dateNow2,
                                            cabang,
                                            level,
                                            index == 0 ? 2 : 1),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            var totalUnit = snapshot.data!;
                                            return Text('${totalUnit.length}',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ));
                                          } else if (snapshot.hasError) {
                                            return Text('${snapshot.error}');
                                          }
                                          return const Center(
                                            child: CupertinoActivityIndicator(),
                                          );
                                        }),
                                  )),
                                  DataCell(Obx(
                                    () => FutureBuilder<
                                            List<
                                                QueryDocumentSnapshot<
                                                    Object?>>>(
                                        future: lapC.getSummary(
                                            lapC.date1.value != ""
                                                ? lapC.date1.value
                                                : dateNow1,
                                            lapC.date2.value != ""
                                                ? lapC.date2.value
                                                : dateNow2,
                                            cabang,
                                            level,
                                            index == 0 ? 2 : 1),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            var totalDetail = snapshot.data!;
                                            var tempTotal = [];
                                            totalDetail.map((e) {
                                              tempTotal.add((e.data() as Map<
                                                  String,
                                                  dynamic>)["grand_total"]);
                                            }).toList();

                                            totalDetail
                                                .map((e) => lapC.detailData.add(
                                                    (e.data() as Map<String,
                                                        dynamic>)))
                                                .toList();
                                            int totalSales = tempTotal.fold(
                                                0, (p, e) => p + e as int);
                                            return Row(
                                              children: [
                                                Text(
                                                    NumberFormat.simpleCurrency(
                                                            locale: 'id',
                                                            decimalDigits: 0)
                                                        .format(totalSales)
                                                        .toString(),
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                    )),
                                                IconButton(
                                                  onPressed: () {
                                                    print(lapC.detailData);
                                                    detailTrx(
                                                        lapC.detailData, index);
                                                  },
                                                  icon: const Icon(
                                                    Icons.library_books_rounded,
                                                    size: 30,
                                                    color: Colors.lightBlue,
                                                  ),
                                                  tooltip: 'Detail data',
                                                  splashRadius: 20,
                                                )
                                              ],
                                            );
                                          } else if (snapshot.hasError) {
                                            // print(snapshot.hasError);
                                            return Text('${snapshot.error}');
                                          }
                                          return const Center(
                                            child: CupertinoActivityIndicator(),
                                          );
                                        }),
                                  )),
                                ]);
                              })),
                        ),
                      ),
                      const Divider(),
                      Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('SERVICES SUMMARY',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                      Expanded(
                          flex: 2,
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: StreamBuilder<QuerySnapshot<Object?>>(
                                  stream: lapC.servicesById(summServ.isNotEmpty
                                      ? summServ.toSet().toList()
                                      : [0]),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      var dtServices = snapshot.data!.docs;
                                      var tempServ = [];
                                      dtServices
                                          .map((e) => tempServ.add((e.data()
                                              as Map<String, dynamic>)))
                                          .toList();
                                      return DataTable2(
                                          columnSpacing: 1,
                                          horizontalMargin: 2,
                                          minWidth: 300,
                                          showBottomBorder: true,
                                          headingTextStyle: const TextStyle(
                                              color: Colors.white),
                                          headingRowColor:
                                              MaterialStateProperty.resolveWith(
                                                  (states) => Colors.lightBlue),
                                          columns: const [
                                            DataColumn(
                                              label: Text('Services'),
                                              // size: ColumnSize.S,
                                            ),
                                            DataColumn(
                                              label: Text('Total'),
                                            ),
                                          ],
                                          rows: List<DataRow>.generate(
                                              dtServices.length, (index) {
                                            return DataRow(cells: [
                                              DataCell(Text(
                                                  '${dtServices[index]["nama"]}',
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                  ))),
                                              DataCell(Obx(
                                                () => FutureBuilder(
                                                    future: lapC.getSummary(
                                                        lapC.date1.value != ""
                                                            ? lapC.date1.value
                                                            : dateNow1,
                                                        lapC.date2.value != ""
                                                            ? lapC.date2.value
                                                            : dateNow2,
                                                        cabang,
                                                        level,
                                                        0),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot.hasData) {
                                                        var dtitem =
                                                            snapshot.data!;
                                                        var lst = [];

                                                        for (int i = 0;
                                                            i < dtitem.length;
                                                            i++) {
                                                          for (int x = 0;
                                                              x <
                                                                  dtitem[i][
                                                                          "services"]
                                                                      .length;
                                                              x++) {
                                                            var data = dtitem[i]
                                                                    ["services"]
                                                                [
                                                                x]["id_service"];
                                                            lst.add(data);
                                                          }
                                                        }
                                                        var total = lst.where(
                                                            (c) =>
                                                                c ==
                                                                dtServices[
                                                                        index]
                                                                    ["id"]);
                                                        return Text(
                                                            '${total.length} Unit',
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight: total
                                                                        .isNotEmpty
                                                                    ? FontWeight
                                                                        .bold
                                                                    : FontWeight
                                                                        .normal));
                                                      } else if (snapshot
                                                          .hasError) {
                                                        // print(snapshot.error);
                                                      }
                                                      return const Center(
                                                        child:
                                                            CupertinoActivityIndicator(),
                                                      );
                                                    }),
                                              ))
                                            ]);
                                          }));
                                    } else if (snapshot.hasError) {
                                      return Text('${snapshot.hasError}');
                                    }
                                    return const Center(
                                      child: CupertinoActivityIndicator(),
                                    );
                                  })))
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              // print(snapshot.error);
              return Text('${snapshot.error}');
            }
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          },
        ),
      ),
      floatingActionButton: SpeedDial(
          elevation: 8,
          overlayOpacity: 0,
          icon: Icons.calendar_month_outlined,
          activeIcon: Icons.close,
          // backgroundColor: const Color.fromARGB(255, 29, 30, 32),
          children: [
            SpeedDialChild(
              label: 'Custom Date',
              labelBackgroundColor: Colors.blue,
              labelStyle: const TextStyle(color: Colors.white),
              backgroundColor: Colors.blue,
              onTap: () {
                searchDialog();
              },
            ),
            SpeedDialChild(
              label: 'Last Year',
              labelBackgroundColor: Colors.blue,
              labelStyle: const TextStyle(color: Colors.white),
              backgroundColor: Colors.blue,
              onTap: () async {
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
                var d = DateTime.now();
                var year = DateTime.utc(d.year - 1, DateTime.january, 1);
                var days = d.difference(year);
                var firstDayOfWeek = d.subtract(Duration(days: days.inDays));
                var lastDayOfWeek =
                    d.subtract(Duration(days: days.inDays - 364));
                await lapC.getSummary(
                    lapC.date1.value = firstDayOfWeek.toString(),
                    lapC.date2.value = lastDayOfWeek.toString(),
                    cabang,
                    level,
                    0);
                Future.delayed(const Duration(seconds: 1), () {
                  Get.back();
                });
              },
            ),
            SpeedDialChild(
              label: 'This Year',
              labelBackgroundColor: Colors.blue,
              labelStyle: const TextStyle(color: Colors.white),
              backgroundColor: Colors.blue,
              onTap: () async {
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
                var d = DateTime.now();
                var year = DateTime.utc(d.year, DateTime.january, 1);
                var days = d.difference(year);
                var firstDayOfWeek = d.subtract(Duration(days: days.inDays));
                var lastDayOfWeek = d.subtract(Duration(days: d.day));
                await lapC.getSummary(
                    lapC.date1.value = firstDayOfWeek.toString(),
                    lapC.date2.value = lastDayOfWeek.toString(),
                    cabang,
                    level,
                    0);
                Future.delayed(const Duration(seconds: 1), () {
                  Get.back();
                });
              },
            ),
            SpeedDialChild(
              label: 'Last Month',
              labelBackgroundColor: Colors.blue,
              labelStyle: const TextStyle(color: Colors.white),
              backgroundColor: Colors.blue,
              onTap: () async {
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
                var d = DateTime.now();
                var firstDayOfMonth = DateTime.utc(d.year, d.month, 1);
                var day = d.difference(firstDayOfMonth);
                var firstDayOfWeek =
                    d.subtract(Duration(days: day.inDays + 31));
                var lastDayOfWeek = d.subtract(Duration(days: day.inDays + 2));
                await lapC.getSummary(
                    lapC.date1.value = firstDayOfWeek.toString(),
                    lapC.date2.value = lastDayOfWeek.toString(),
                    cabang,
                    level,
                    0);
                Future.delayed(const Duration(seconds: 1), () {
                  Get.back();
                });
              },
            ),
            SpeedDialChild(
              label: 'This Month',
              labelBackgroundColor: Colors.blue,
              labelStyle: const TextStyle(color: Colors.white),
              backgroundColor: Colors.blue,
              onTap: () async {
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
                var d = DateTime.now();
                var firstDayOfMonth = DateTime.utc(d.year, d.month, 1);
                var day = d.difference(firstDayOfMonth);
                var firstDayOfWeek = d.subtract(Duration(days: day.inDays));
                var lastDayOfWeek = d.subtract(Duration(days: day.inDays - 29));
                await lapC.getSummary(
                    lapC.date1.value = firstDayOfWeek.toString(),
                    lapC.date2.value = lastDayOfWeek.toString(),
                    cabang,
                    level,
                    0);
                Future.delayed(const Duration(seconds: 1), () {
                  Get.back();
                });
              },
            ),
            SpeedDialChild(
              label: 'Last Week',
              labelBackgroundColor: Colors.blue,
              labelStyle: const TextStyle(color: Colors.white),
              backgroundColor: Colors.blue,
              onTap: () async {
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
                var d = DateTime.now();
                var weekDay = d.weekday;
                var firstDayOfWeek = d.subtract(Duration(days: weekDay + 7));
                var lastDayOfWeek = d.subtract(Duration(days: weekDay + 1));
                await lapC.getSummary(
                    lapC.date1.value = firstDayOfWeek.toString(),
                    lapC.date2.value = lastDayOfWeek.toString(),
                    cabang,
                    level,
                    0);
                Future.delayed(const Duration(seconds: 1), () {
                  Get.back();
                });
              },
            ),
            SpeedDialChild(
              label: 'This Week',
              labelBackgroundColor: Colors.blue,
              labelStyle: const TextStyle(color: Colors.white),
              backgroundColor: Colors.blue,
              onTap: () async {
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
                var d = DateTime.now();
                var weekDay = d.weekday;
                var firstDayOfWeek = d.subtract(Duration(days: weekDay));
                var lastDayOfWeek = d.subtract(Duration(days: weekDay - 6));
                await lapC.getSummary(
                    lapC.date1.value = firstDayOfWeek.toString(),
                    lapC.date2.value = lastDayOfWeek.toString(),
                    cabang,
                    level,
                    0);
                Future.delayed(const Duration(seconds: 1), () {
                  Get.back();
                });
              },
            ),
            SpeedDialChild(
              label: 'Yesterday',
              labelBackgroundColor: Colors.blue,
              labelStyle: const TextStyle(color: Colors.white),
              backgroundColor: Colors.blue,
              onTap: () async {
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
                await lapC.getSummary(
                    lapC.date1.value = DateTime.parse(dateNow1)
                        .add(const Duration(days: -1))
                        .toString(),
                    lapC.date2.value = DateTime.parse(dateNow2)
                        .add(const Duration(days: -1))
                        .toString(),
                    cabang,
                    level,
                    0);
                Future.delayed(const Duration(seconds: 1), () {
                  Get.back();
                });
              },
            ),
            SpeedDialChild(
              label: 'Today',
              labelBackgroundColor: Colors.blue,
              labelStyle: const TextStyle(color: Colors.white),
              backgroundColor: Colors.blue,
              onTap: () async {
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
                await lapC.getSummary(lapC.date1.value = dateNow1.toString(),
                    lapC.date2.value = dateNow2.toString(), cabang, level, 0);
                Future.delayed(const Duration(seconds: 1), () {
                  Get.back();
                });
              },
            ),
          ]),
    );
  }

  searchDialog() {
    Get.bottomSheet(Container(
      decoration: const BoxDecoration(color: Colors.white),
      height: 145,
      child: Padding(
        padding: const EdgeInsets.only(top: 15, left: 8.0, right: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: DateTimeField(
                    controller: dateInputAwal,
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(1),
                        prefixIcon: Icon(Icons.calendar_month),
                        hintText: 'Tanggal Awal',
                        border: OutlineInputBorder()),
                    format: DateFormat("yyyy-MM-dd"),
                    onShowPicker: (context, currentValue) {
                      return showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: currentValue ?? DateTime.now(),
                          lastDate: DateTime(2100));
                    },
                  ),
                ),
                Expanded(
                  child: DateTimeField(
                    controller: dateInputAkhir,
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(1),
                        prefixIcon: Icon(Icons.calendar_month),
                        hintText: 'Tanggal Akhir',
                        border: OutlineInputBorder()),
                    format: DateFormat("yyyy-MM-dd"),
                    onShowPicker: (context, currentValue) {
                      return showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: currentValue ?? DateTime.now(),
                          lastDate: DateTime(2100));
                    },
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4.0, top: 8, right: 4),
              child: ElevatedButton(
                  onPressed: () async {
                    // print(dateInputAwal.text);
                    if (dateInputAwal.text == "" && dateInputAkhir.text == "") {
                      showDefaultDialog(
                          "Perhatian", "Harap masukkan tanggal pencarian");
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
                      lapC.date1.value = dateInputAwal.text;
                      lapC.date2.value = dateInputAkhir.text;
                      await lapC.getSummary(dateInputAwal.text,
                          dateInputAkhir.text, cabang, level, 0);
                      Future.delayed(const Duration(seconds: 1), () {
                        Get.back();
                        Get.back();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(Get.mediaQuery.size.width, 45),
                  ),
                  child: const Text(
                    'Cari',
                    style: TextStyle(fontSize: 20),
                  )),
            )
          ],
        ),
      ),
    ));
  }

  detailTrx(detailData, index) {
    var id = index == 0 ? 2 : 1;
    Get.defaultDialog(
        radius: 5,
        title: 'Detail Top Items',
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            const Divider(),
            SizedBox(
              height: 350.0, // Change as per your requirement
              width: 300.0,
              child: ListView.separated(
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount:
                      detailData.where((c) => c["id_jenis"] == id).length,
                  itemBuilder: (ctx, i) {
                    return ListTile(
                      title: Text(detailData[i]["no_polisi"]),
                      subtitle: Text(detailData[i]["kendaraan"]),
                      trailing: Text(NumberFormat.simpleCurrency(
                              locale: 'id', decimalDigits: 0)
                          .format(detailData[i]["grand_total"])
                          .toString()),
                    );
                  }),
            ),
            const Divider(),
          ],
        ));
  }
}
