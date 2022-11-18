import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_finish.dart';
import 'home_progress.dart';

class HomeViewTabs extends GetView {
  HomeViewTabs(this.level, this.kasir, this.cabang, this.namaCabang,
      this.alamatCabang, this.kotaCabang,
      {super.key});
  final int level;
  final String kasir;
  final String cabang;
  final String namaCabang;
  final String alamatCabang;
  final String kotaCabang;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            // flexibleSpace: Column(
            //     // mainAxisAlignment: MainAxisAlignment.end,
            //     // mainAxisSize: MainAxisSize.max,
            //     children: const [
            bottom: const TabBar(
              indicatorWeight: 7,
              tabs: [
                Tab(
                  icon: Icon(Icons.local_car_wash_rounded),
                  text: 'On Progress',
                ),
                Tab(
                  icon: Icon(Icons.no_crash),
                  text: 'Finish',
                ),
                // Tab(
                //   icon: Image.asset(
                //     'asset/store.png',
                //     scale: 3,
                //   ),
                // text: 'Manage Cabang',
                // ),
              ],
              // isScrollable: true,
            ),
            // ]),
          ),
          body: TabBarView(children: [
            HomeProgress(cabang),
            HomeFinish(
                level, kasir, cabang, namaCabang, alamatCabang, kotaCabang)
            // LevelView(),
            // UserView(),
          ]),
        ));
  }
}
