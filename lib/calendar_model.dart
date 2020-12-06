class Calendar {
  int id;
  String name;
  int tgl;

  Calendar(this.id, this.name, this.tgl);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{'id': id, 'name': name, 'tgl': tgl};
    return map;
  }

  Calendar.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    tgl = map['tgl'];
  }
}
