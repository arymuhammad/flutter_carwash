import 'package:flutter/material.dart';
import 'package:carwash/app/modules/master/views/master_kendaraan.dart';
import 'package:carwash/app/modules/services/views/services_view.dart';
// import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

import 'master_cabang.dart';
import 'master_karyawan.dart';
import 'master_level.dart';
import 'master_user.dart';

class MasterViewTabs extends GetView {
  MasterViewTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 6,
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
                  icon: Icon(Icons.business_outlined),
                  text: 'Master Cabang',
                ),
                Tab(
                  icon: Icon(Icons.people_alt_outlined),
                  text: 'Master Users',
                ),
                Tab(
                  icon: Icon(Icons.people_alt_outlined),
                  text: 'Master Karyawan',
                ),
                Tab(
                  icon: Icon(Icons.card_membership_outlined),
                  text: 'Master Level',
                ),
                Tab(
                  icon: Icon(Icons.car_rental),
                  text: 'Master Kendaraan',
                ),
                Tab(
                  icon: Icon(Icons.miscellaneous_services_rounded),
                  text: 'Master Services',
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
            // ])
          ),
          body: TabBarView(children: [
            MasterCabang(),
            MasterUsers(),
            MasterKaryawan(),
            MasterLevel(),
            MasterKendaraan(),
            ServicesView(),
          ]),
        ));
  }
}
