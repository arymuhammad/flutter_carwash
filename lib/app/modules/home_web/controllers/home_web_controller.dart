import 'package:auth/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get/get.dart';

class HomeWebController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore home = FirebaseFirestore.instance;

  // Stream<DocumentSnapshot> login(String user, String pass) {
  //   QuerySnapshot users = firestore.collection("users").;

  //   return users.get().snapshots();
  // }
  var namaCabang = "";
  var alamatCabang = "";
  var kotaCabang = "";
  Stream<User?> get userAuth => auth.authStateChanges();

  Stream<QuerySnapshot<Object?>> streamDataUser(String? email) {
    CollectionReference user = home.collection("users");
    return user.where("email", isEqualTo: email).snapshots();
  }

  Stream<QuerySnapshot<Object?>> streamDataCabang(String cabang) {
    CollectionReference user = home.collection("cabang");
    return user.where("kode_cabang", isEqualTo: cabang).snapshots();
  }
}
