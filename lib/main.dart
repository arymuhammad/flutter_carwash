import 'package:auth/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app/modules/home/views/home_add.dart';
import 'app/modules/login/controllers/login_controller.dart';
import 'app/modules/login/views/login_view.dart';

import 'package:get/get.dart';

import 'app/modules/home/controllers/auth_controller.dart';
import 'app/modules/home/views/home_view.dart';
import 'app/modules/home_web/views/home_web_view.dart';
import 'app/routes/app_pages.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final auth = Get.put(AuthController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: auth.userAuth,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            // print(snapshot.data!);
            if (kIsWeb) {
              // Android-specific code
              return GetMaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData(fontFamily: 'Nunito'),
                title: "Mobile Car Wash Online",
                // initialRoute:
                //     snapshot.data != null ? Routes.HOME_WEB : Routes.LOGIN,
                home: snapshot.data != null
                    ? HomeWebView(user: snapshot.data!.email!)
                    // HomeView()
                    // HomeAdd(user: snapshot.data!.email!) // home android version
                    : LoginView(),
                getPages: AppPages.routes,
              );
            } else {
              return GetMaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData(fontFamily: 'Nunito'),
                title: "Mobile Car Wash Online",
                // initialRoute:
                //     snapshot.data != null ? Routes.HOME_WEB : Routes.LOGIN,
                home: snapshot.data != null
                    ?
                    //  HomeWebView(
                    // user: snapshot.data!.email!) //untuk home web version
                    HomeAdd(user: snapshot.data!.email!) // home android version
                    // HomeView() //home led
                    : LoginView(),
                getPages: AppPages.routes,
              );
              // iOS-specific code
            }
          }
          return const Center(child: CircularProgressIndicator());
        });

    // GetMaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   title: "PRO Wash",
    //   home: HomeView(),
    //   getPages: AppPages.routes,
    // );
  }
}
