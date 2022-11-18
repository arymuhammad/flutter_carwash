class Login {
  int? sukses;
  String? pesan;
  String? nama;
  String? pass;
  String? level;

  Login({this.sukses, this.pesan, this.nama, this.pass, this.level});

  Login.fromJson(Map<String, dynamic> json) {
    sukses = json['success'];
    pesan = json['pesan'];
    nama = json['Nama'];
    pass = json['Password'];
    level = json['Level_user'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = sukses;
    data['pesan'] = pesan;
    data['Nama'] = nama;
    data['Password'] = pass;
    data['Level_user'] = level;
    return data;
  }
}
