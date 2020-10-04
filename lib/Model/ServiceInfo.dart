import 'package:json_annotation/json_annotation.dart';

class ServiceInfo {
  String result;
  List<Service> service;
  @JsonKey(ignore: true)
  String error;

  ServiceInfo({this.result, this.service});

  ServiceInfo.fromJson(Map<String, dynamic> json) {
    result = json['result'];
    if (json['service'] != null) {
      service = new List<Service>();
      json['service'].forEach((v) {
        service.add(new Service.fromJson(v));
      });
    }
  }

  ServiceInfo.withError(this.error);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['result'] = this.result;
    if (this.service != null) {
      data['service'] = this.service.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Service {
  String date;
  String time;
  String serviceName;
  String serviceInfo;

  Service({this.date, this.time, this.serviceName, this.serviceInfo});

  Service.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    time = json['time'];
    serviceName = json['service_name'];
    serviceInfo = json['service_info'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['time'] = this.time;
    data['service_name'] = this.serviceName;
    data['service_info'] = this.serviceInfo;
    return data;
  }
}
