import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:get/get.dart';

import '../../../helper/alert.dart';
import '../../home/controllers/auth_controller.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  LoginView({Key? key}) : super(key: key);

  TextEditingController user = TextEditingController();
  TextEditingController pass = TextEditingController();

  final authC = Get.find<AuthController>();
  final loginC = Get.put(LoginController());
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool willLeave = false;
        await Get.defaultDialog(
            radius: 5,
            title: 'Peringatan',
            content: Container(
              child: const Text('Anda yakin ingin keluar dari aplikasi ini?'),
            ),
            confirm: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent[700]),
                child: const Text('TIDAK')),
            cancel: ElevatedButton(
                onPressed: () {
                  willLeave = true;
                  Get.back();
                },
                child: const Text('IYA')));
        return willLeave;
      },
      child: Scaffold(
        // appBar: AppBar(
        //   title: const Text('LoginView'),
        //   centerTitle: true,
        // ),
        backgroundColor: Colors.lightBlue,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset('assets/logo.png'),
              ),
            ),
            Center(
                child: AlertDialog(
              elevation: 20,
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Stack(
                  //   children: const [
                  //     Text('Log In',
                  //         style: TextStyle(
                  //             fontSize: 25, fontWeight: FontWeight.bold))
                  //   ],
                  // ),

                  const Text(
                    'Log In',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito'),
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 5,
                  ),
                  TextField(
                    controller: user,
                    decoration: const InputDecoration(
                        label: Text('Username'),
                        prefixIcon: Icon(Icons.account_circle),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30)))),
                    onSubmitted: ((username) {
                      if (kIsWeb) {
                        if (pass.text.isEmpty && username.isEmpty) {
                          showSnackbar('Error',
                              'Username dan Password tidak boleh kosong');
                        } else if (username.isEmpty) {
                          showSnackbar('Error', 'Username belum di isi');
                        } else if (pass.text.isEmpty) {
                          showSnackbar('Error', 'Password belum di isi');
                        } else {
                          authC.login(user.text, pass.text);
                          showSnackbar('Sukses', 'Selamat Datang ${user.text}');
                          user.clear();
                          pass.clear();
                        }
                      } else {
                        if (pass.text.isEmpty && username.isEmpty) {
                          Fluttertoast.showToast(
                              msg: "Error, Username dan Password kosong.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.redAccent[700],
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } else if (username.isEmpty) {
                          Fluttertoast.showToast(
                              msg: "Error, Username Kosong.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.redAccent[700],
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } else if (pass.text.isEmpty) {
                          Fluttertoast.showToast(
                              msg: "Error, Password kosong.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.redAccent[700],
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } else {
                          authC.login(user.text, pass.text);
                          Fluttertoast.showToast(
                              msg:
                                  "Sukses, Anda berhasil Login.\nSedang Mengalihkan ke Home",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.greenAccent[700],
                              textColor: Colors.white,
                              fontSize: 16.0);
                          user.clear();
                          pass.clear();
                        }
                      }
                    }),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: pass,
                    decoration: const InputDecoration(
                        label: Text('Password'),
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30)))),
                    obscureText: true,
                    onSubmitted: ((password) {
                      if (kIsWeb) {
                        if (password.isEmpty && user.text.isEmpty) {
                          showSnackbar('Error',
                              'Username dan Password tidak boleh kosong');
                        } else if (user.text.isEmpty) {
                          showSnackbar('Error', 'Username belum di isi');
                        } else if (password.isEmpty) {
                          showSnackbar('Error', 'Password belum di isi');
                        } else {
                          authC.login(user.text, pass.text);
                          // showSnackbar('Sukses', 'Selamat Datang ${user.text}');
                          user.clear();
                          pass.clear();
                        }
                      } else {
                        if (password.isEmpty && user.text.isEmpty) {
                          Fluttertoast.showToast(
                              msg: "Error, Username dan Password kosong.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.redAccent[700],
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } else if (user.text.isEmpty) {
                          Fluttertoast.showToast(
                              msg: "Error, Username kosong.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.redAccent[700],
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } else if (password.isEmpty) {
                          Fluttertoast.showToast(
                              msg: "Error, Password kosong.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.redAccent[700],
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } else {
                          authC.login(user.text, pass.text);
                          Fluttertoast.showToast(
                              msg:
                                  "Sukses, Anda berhasil Login.\nSedang Mengalihkan ke Home",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.greenAccent[700],
                              textColor: Colors.white,
                              fontSize: 16.0);
                          user.clear();
                          pass.clear();
                        }
                      }
                    }),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Obx(
                    () => ElevatedButton(
                      onPressed: () {
                        if (kIsWeb) {
                          if (pass.text.isEmpty && user.text.isEmpty) {
                            authC.isLoading.value = false;
                            showSnackbar('Error',
                                'Username dan Password tidak boleh kosong');
                          } else if (user.text.isEmpty) {
                            authC.isLoading.value = false;
                            showSnackbar('Error', 'Username belum di isi');
                          } else if (pass.text.isEmpty) {
                            authC.isLoading.value = false;
                            showSnackbar('Error', 'Password belum di isi');
                          } else {
                            authC.isLoading.value = true;
                            authC.login(user.text, pass.text);
                            showSnackbar(
                                'Sukses', 'Selamat Datang ${user.text}');
                          }
                        } else {
                          if (pass.text.isEmpty && user.text.isEmpty) {
                            authC.isLoading.value = false;
                            Fluttertoast.showToast(
                                msg: "Error, Username dan Password kosong.",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.redAccent[700],
                                textColor: Colors.white,
                                fontSize: 16.0);
                          } else if (user.text.isEmpty) {
                            authC.isLoading.value = false;
                            Fluttertoast.showToast(
                                msg: "Error, Username kosong.",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.redAccent[700],
                                textColor: Colors.white,
                                fontSize: 16.0);
                          } else if (pass.text.isEmpty) {
                            authC.isLoading.value = false;
                            Fluttertoast.showToast(
                                msg: "Error, Password kosong.",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.redAccent[700],
                                textColor: Colors.white,
                                fontSize: 16.0);
                          } else {
                            authC.isLoading.value = true;
                            authC.login(user.text, pass.text);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 100,
                          fixedSize: const Size(100, 40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50))),
                      child: authC.isLoading.value
                          ? const SizedBox(
                              height: 25,
                              width: 25,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              ),
                            )
                          : const Text(
                              'Log In',
                              style: TextStyle(fontSize: 20),
                            ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  // Row(
                  //   children: [
                  //     const Text('Lupa Password?'),
                  //     const SizedBox(
                  //       width: 5,
                  //     ),
                  //     InkWell(
                  //       onTap: () {},
                  //       child: const Text(
                  //         'Klik disini',
                  //         style: TextStyle(color: Colors.lightBlue),
                  //       ),
                  //     )
                  //   ],
                  // ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
