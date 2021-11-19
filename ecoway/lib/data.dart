class Json {
  late String message;
  late List<Data> data;

  Json({required this.message, required this.data});

  Json.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  late int id;
  late String companyname;
  late String email;
  late String nivel;
  late String pontos;

  Data({required this.id, required this.companyname, required this.email, required this.nivel, required this.pontos});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    companyname = json['companyname'];
    email = json['email'];
    nivel = json['nivel'];
    pontos = json['pontos'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['companyname'] = this.companyname;
    data['email'] = this.email;
    data['nivel'] = this.nivel;
    data['pontos'] = this.pontos;
    return data;
  }

  void removeAt(index) {}
}

