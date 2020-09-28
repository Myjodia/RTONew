import 'package:json_annotation/json_annotation.dart';

class Pricemodel {
  String price;
  String result;
  @JsonKey(ignore: true)
  String error;

  Pricemodel({this.price, this.result});

  Pricemodel.fromJson(Map<String, dynamic> json) {
    price = json['price'];
    result = json['result'];
  }

Pricemodel.withError(this.error);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['price'] = this.price;
    data['result'] = this.result;
    return data;
  }
}
