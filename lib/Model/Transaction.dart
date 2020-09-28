import 'package:json_annotation/json_annotation.dart';

class Transaction {
  String result;
  List<Transactions> transactions;
  @JsonKey(ignore: true)
  String error;

  Transaction({this.result, this.transactions});

  Transaction.fromJson(Map<String, dynamic> json) {
    result = json['result'];
    if (json['transactions'] != null) {
      transactions = new List<Transactions>();
      json['transactions'].forEach((v) {
        transactions.add(new Transactions.fromJson(v));
      });
    }
  }

  Transaction.withError(this.error);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['result'] = this.result;
    if (this.transactions != null) {
      data['transactions'] = this.transactions.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Transactions {
  String date;
  String time;
  String formName;
  String rcBook;
  String learnLic;
  String motorDriveLic;
  String aadharVoting;
  String birthProof;
  String sign;
  String forms;
  String payment;
  String transactionalId;
  String paymentStatus;
  String formStatus;
  String completedPdf;

  Transactions(
      {this.date,
      this.time,
      this.formName,
      this.rcBook,
      this.learnLic,
      this.motorDriveLic,
      this.aadharVoting,
      this.birthProof,
      this.sign,
      this.forms,
      this.payment,
      this.transactionalId,
      this.paymentStatus,
      this.formStatus,
      this.completedPdf});

  Transactions.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    time = json['time'];
    formName = json['form_name'];
    rcBook = json['rc_book'];
    learnLic = json['learn_lic'];
    motorDriveLic = json['motor_drive_lic'];
    aadharVoting = json['aadhar_voting'];
    birthProof = json['birth_proof'];
    sign = json['sign'];
    forms = json['forms'];
    payment = json['payment'];
    transactionalId = json['transactional_id'];
    paymentStatus = json['payment_status'];
    formStatus = json['form_status'];
    completedPdf = json['completed_pdf'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['time'] = this.time;
    data['form_name'] = this.formName;
    data['rc_book'] = this.rcBook;
    data['learn_lic'] = this.learnLic;
    data['motor_drive_lic'] = this.motorDriveLic;
    data['aadhar_voting'] = this.aadharVoting;
    data['birth_proof'] = this.birthProof;
    data['sign'] = this.sign;
    data['forms'] = this.forms;
    data['payment'] = this.payment;
    data['transactional_id'] = this.transactionalId;
    data['payment_status'] = this.paymentStatus;
    data['form_status'] = this.formStatus;
    data['completed_pdf'] = this.completedPdf;
    return data;
  }
}
