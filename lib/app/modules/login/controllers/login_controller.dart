import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  // var username = "".obs;
  // var logUser = [].obs;
  // var password = "".obs;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot<Object?>>> loginUser(
      userLogin, passLogin) async {
    CollectionReference data = firestore.collection("users");
    final snapshots = data.snapshots().map((snapshot) => snapshot.docs.where(
        (doc) => doc["username"] == userLogin && doc["password"] == passLogin));

    return (await snapshots.first).toList();
  }

  updateIsLogin(String id) async {
    DocumentReference user = firestore.collection("users").doc(id);
    try {
      await user.update({"isLogin": true});
      // ignore: empty_catches
    } catch (e) {}
  }
}
