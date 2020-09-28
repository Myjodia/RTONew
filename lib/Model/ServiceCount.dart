import 'package:json_annotation/json_annotation.dart';

class ServiceCount {
  String pending;
  String inprogress;
  String complete;
  Object version;
  String result;
  @JsonKey(ignore: true)
  String error;

  ServiceCount(
      {this.pending,
      this.inprogress,
      this.complete,
      this.version,
      this.result});

  ServiceCount.fromJson(Map<String, dynamic> json) {
    pending = json['pending'];
    inprogress = json['inprogress'];
    complete = json['complete'];
    version = json['version'];
    result = json['result'];
  }

  ServiceCount.withError(this.error);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pending'] = this.pending;
    data['inprogress'] = this.inprogress;
    data['complete'] = this.complete;
    data['version'] = this.version;
    data['result'] = this.result;
    return data;
  }
}
