import 'package:json_annotation/json_annotation.dart';

class LoginResponse {
  String uid;
  String name;
  String mobile;
  String email;
  String state;
  String city;
  String result;
  @JsonKey(ignore: true)
  String error;

  LoginResponse(
      {this.uid,
      this.name,
      this.mobile,
      this.email,
      this.state,
      this.city,
      this.result});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
    mobile = json['mobile'];
    email = json['email'];
    state = json['state'];
    city = json['city'];
    result = json['result'];
  }

  LoginResponse.withError(this.error);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['name'] = this.name;
    data['mobile'] = this.mobile;
    data['email'] = this.email;
    data['state'] = this.state;
    data['city'] = this.city;
    data['result'] = this.result;
    return data;
  }
}
