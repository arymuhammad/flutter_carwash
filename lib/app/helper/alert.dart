import 'package:flutter/material.dart';
import 'package:get/get.dart';

showSnackbar(title, pesan) {
  Get.snackbar(title, pesan,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.only(left: Get.mediaQuery.size.width - 300),
      backgroundColor:
          title == "Sukses" ? Colors.greenAccent[700] : Colors.redAccent[700],
      colorText: Colors.white,
      icon: Icon(
        title == "Sukses" ? Icons.check_circle : Icons.cancel,
        color: Colors.white,
      ),
      leftBarIndicatorColor: Colors.white,
      duration: const Duration(milliseconds: 1500),
      snackStyle: SnackStyle.GROUNDED);
}

showDefaultDialog(title, message) {
  Get.defaultDialog(
      radius: 5,
      title: title,
      middleText: message,
      onConfirm: () => Get.back(),
      textConfirm: 'OK',
      confirmTextColor: Colors.white);
}
