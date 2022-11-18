class Merk {
  late String id;
  late String merk;

  Merk({required this.id, required this.merk});

  Merk.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    merk = json['merk'];
  }
}
