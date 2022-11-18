class User {
  late int id;
  late String nama;
  late String password;
  late String level;
  late int status;

  User(
      {required this.id,
      required this.nama,
      required this.password,
      required this.level,
      required this.status,
      });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nama = json['nama'];
    password = json['password'];
    level = json['level'];
    status = json['status'];
  }
}
