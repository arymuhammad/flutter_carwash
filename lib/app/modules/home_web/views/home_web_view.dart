import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carwash/app/modules/home/controllers/auth_controller.dart';
import 'package:carwash/app/modules/home_web/views/home_tab.dart';
import 'package:get/get.dart';

import '../../../helper/alert.dart';
import '../../laporan/views/laporan_view.dart';
import '../../master/views/master_view.dart';
import '../controllers/home_web_controller.dart';

class HomeWebView extends GetView<HomeWebController> {
  HomeWebView({super.key, this.user});
  final String? user;
  PageController page = PageController(initialPage: 0, keepPage: false);
  final homeC = Get.put(HomeWebController());

  final auth = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Selamat datang di Halaman Admin Saputra Car Wash'),
          centerTitle: true,
        ),
        body: StreamBuilder(
          stream: homeC.streamDataUser(user),
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              var email = snapshot.data!.docs;
              var cabang = [];
              email
                  .map((DocumentSnapshot doc) =>
                      cabang.add((doc.data() as Map<String, dynamic>)))
                  .toList();
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SideMenu(
                    controller: page,
                    // onDisplayModeChanged: (mode) {
                    //   print(mode);
                    // },
                    style: SideMenuStyle(
                        displayMode: SideMenuDisplayMode.auto,
                        hoverColor: Colors.blue[100],
                        selectedColor: Colors.lightBlue,
                        selectedTitleTextStyle:
                            const TextStyle(color: Colors.white),
                        selectedIconColor: Colors.white,
                        // decoration: BoxDecoration(
                        //   borderRadius: BorderRadius.all(Radius.circular(10)),
                        // ),
                        backgroundColor:
                            const Color.fromARGB(255, 201, 203, 204)),
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 170,
                            maxWidth: 290,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                cabang.isNotEmpty
                                    ? const CircleAvatar(
                                        backgroundColor: Colors.grey,
                                        backgroundImage:
                                            AssetImage('assets/logo.png'),
                                      )
                                    : Container(),
                                const SizedBox(
                                  width: 4,
                                ),
                                cabang.isNotEmpty
                                    ? Text(
                                        ' ${cabang[0]["nama"]}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        ),
                        const Divider(
                          indent: 8.0,
                          endIndent: 8.0,
                        ),
                      ],
                    ),
                    footer: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: cabang[0]["level"] != 1
                            ? StreamBuilder(
                                stream: homeC.streamDataCabang(
                                    cabang[0]["kode_cabang"] != ""
                                        ? cabang[0]["kode_cabang"]
                                        : ""),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    var cab = [];
                                    snapshot.data!.docs
                                        .map((DocumentSnapshot doc) {
                                      cab.add(
                                          (doc.data() as Map<String, dynamic>));
                                    }).toList();
                                    homeC.namaCabang = cab[0]["nama_cabang"];
                                    homeC.alamatCabang = cab[0]["alamat"];
                                    homeC.kotaCabang = cab[0]["kota"];

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                                flex: 2,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8, right: 12),
                                                  child: const Icon(
                                                      Icons
                                                          .maps_home_work_outlined,
                                                      color: Color.fromARGB(
                                                          255, 73, 72, 72)),
                                                )),
                                            Expanded(
                                              flex: 8,
                                              child: SizedBox(
                                                height: 20,
                                                child: Text(
                                                  '${cab[0]["nama_cabang"]}',
                                                  style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromARGB(
                                                          255, 73, 72, 72)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                                flex: 2,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8, right: 12),
                                                  child: const Icon(
                                                      Icons.map_sharp,
                                                      color: Color.fromARGB(
                                                          255, 73, 72, 72)),
                                                )),
                                            Expanded(
                                              flex: 8,
                                              child: SizedBox(
                                                height: 20,
                                                child: Text(
                                                  '${cab[0]["kota"]}',
                                                  style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromARGB(
                                                          255, 73, 72, 72)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                                flex: 2,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8, right: 12),
                                                  child: const Icon(Icons.call,
                                                      color: Color.fromARGB(
                                                          255, 73, 72, 72)),
                                                )),
                                            Expanded(
                                              flex: 8,
                                              child: SizedBox(
                                                height: 20,
                                                child: Text(
                                                  '${cab[0]["telp"]}',
                                                  style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromARGB(
                                                          255, 73, 72, 72)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text('${snapshot.error}');
                                  }
                                  return const Center(
                                    child: CupertinoActivityIndicator(),
                                  );
                                },
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: const [
                                    Center(
                                        child: Text(
                                      'OWNER',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Color.fromARGB(255, 73, 72, 72)),
                                    ))
                                  ])),
                    items: [
                      SideMenuItem(
                        priority: 0,
                        title: 'Beranda',
                        onTap: () {
                          page.jumpToPage(0);
                        },
                        icon: const Icon(Icons.home),
                        // badgeContent: const Text(
                        //   '3',
                        //   style: TextStyle(color: Colors.white),
                        // ),
                      ),
                      SideMenuItem(
                        priority: 1,
                        title: 'Data Master',
                        onTap: () {
                          if (cabang[0]["level"] != 3) {
                            page.jumpToPage(1);
                          } else {
                            Get.defaultDialog(
                                title: 'Info',
                                content: const Text(
                                    'fitur ini hanya untuk administrator'));
                          }
                        },
                        icon: const Icon(Icons.storefront),
                      ),
                      SideMenuItem(
                        priority: 2,
                        title: 'Laporan',
                        onTap: () {
                          // if (userCtr.loguser[0].level == "Administrator") {
                          page.jumpToPage(2);
                          // } else {
                          //   Get.defaultDialog(
                          //       title: 'Info',
                          //       content:
                          //           const Text('fitur ini hanya untuk administrator'));
                          // }
                        },
                        icon: const Icon(Icons.system_update_tv),
                      ),
                      // SideMenuItem(
                      //   priority: 3,
                      //   title: 'Distribusi In',
                      //   onTap: () {
                      //     page.jumpToPage(3);
                      //   },
                      //   icon: const Icon(Icons.move_to_inbox_rounded),
                      // ),
                      // SideMenuItem(
                      //   priority: 4,
                      //   title: 'Distribusi Out',
                      //   onTap: () {
                      //     page.jumpToPage(4);
                      //   },
                      //   icon: const Icon(Icons.outbox_rounded),
                      // ),
                      // SideMenuItem(
                      //   priority: 3,
                      //   title: 'Laporan Keuangan',
                      //   onTap: () {
                      //     page.jumpToPage(3);
                      //   },
                      //   icon: const Icon(Icons.settings),
                      // ),
                      SideMenuItem(
                        priority: 4,
                        title: 'Log Out',
                        onTap: () {
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext ctx) {
                                return AlertDialog(
                                  title: const Text('Info'),
                                  content:
                                      const Text('Anda yakin ingin Logout?'),
                                  actions: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        ElevatedButton(
                                            onPressed: () async {
                                              // userCtr.loguser.clear();
                                              auth.logout();
                                              Get.back();
                                              showSnackbar('Sukses',
                                                  'Anda berhasil logout');
                                              // showLogin();
                                            },
                                            child: const Text("Ya")),
                                        ElevatedButton(
                                            onPressed: () {
                                              Get.back();
                                            },
                                            child: const Text("Tidak"))
                                      ],
                                    ),
                                  ],
                                );
                              });
                        },
                        icon: const Icon(Icons.logout_outlined),
                      ),
                    ],
                  ),
                  Expanded(
                    child:
                        // StreamBuilder(
                        //   stream: homeC.streamDataUser(user!),
                        //   builder: ((context, snapshot) {
                        //     if (snapshot.hasData) {
                        //       var email = snapshot.data!.docs;
                        //       var cabang = "";
                        //       email
                        //           .map((DocumentSnapshot doc) => cabang =
                        //               ((doc.data() as Map<String, dynamic>)["kode_cabang"]))
                        //           .toList();
                        // return
                        PageView(
                      controller: page,
                      children: [
                        HomeViewTabs(
                            cabang[0]["level"],
                            cabang[0]["nama"],
                            cabang[0]["kode_cabang"] != ""
                                ? cabang[0]["kode_cabang"]
                                : "",
                            homeC.namaCabang,
                            homeC.alamatCabang,
                            homeC.kotaCabang),
                        MasterViewTabs(),
                        LaporanView(
                            cabang[0]["kode_cabang"] != ""
                                ? cabang[0]["kode_cabang"]
                                : "",
                            cabang[0]["level"]),

                        // DistOutView(),
                        // SettingsView(),
                      ],

                      //   } else if (snapshot.hasError) {
                      //     return Text('${snapshot.error}');
                      //   }
                      //   return const Center(
                      //     child: CupertinoActivityIndicator(),
                      //   );
                      // }),
                    ),
                  )
                ],
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }),
        ));
  }
}
