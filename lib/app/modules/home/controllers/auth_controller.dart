import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../helper/alert.dart';

class AuthController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;

  var isLoading = false.obs;

  Stream<User?> get userAuth => auth.authStateChanges();

  login(String user, String pass) async {
    try {
      await auth.signInWithEmailAndPassword(email: user, password: pass);
      if (kIsWeb) {
        showSnackbar('Sukses', 'Selamat Datang $user');
      } else {
        return Fluttertoast.showToast(
            msg: "Sukses, Anda berhasil Login",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.greenAccent[700],
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        isLoading.value = false;
        showSnackbar('Error', 'Username tidak di temukan!');
      } else if (e.code == "wrong-password") {
        isLoading.value = false;
        showSnackbar('Error', 'Password yang Anda masukkan salah!');
      }
    }
  }

  logout() async {
    await auth.signOut();
    // Fluttertoast.showToast(
    //         msg:
    //             "Sukses, Anda berhasil logout.",
    //         toastLength: Toast.LENGTH_SHORT,
    //         gravity: ToastGravity.BOTTOM,
    //         timeInSecForIosWeb: 1,
    //         backgroundColor: Colors.greenAccent[700],
    //         textColor: Colors.white,
    //         fontSize: 16.0);
  }

  void deleteUser() {
    auth.currentUser;
  }
}
