import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:rto/Model/LoginResponse.dart';
import 'package:rto/Model/ServiceCount.dart';
import 'package:rto/Model/Transaction.dart';
import 'package:rto/Model/pricemodel.dart';

class ApiFile {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://rto24x7.com/api/';
  String _uploadfile='https://rto24x7.com/api/file_upload/';

  void printOutError(error, StackTrace stacktrace) {
    print('Exception occured: $error with stacktrace: $stacktrace');
  }

  Future<LoginResponse> getLoginResponse(FormData data) async {
    try {
      final response = await _dio.post(_baseUrl + 'login/', data: data);
      print(response);
      Map userMap = jsonDecode(response.data);
      print(_baseUrl + 'login/' + data.toString());
      print(userMap);
      return LoginResponse.fromJson(userMap);
    } catch (error, stacktrace) {
      printOutError(error, stacktrace);
      return LoginResponse.withError('$error');
    }
  }

  Future<Transaction> getTransResponse(FormData data) async {
    try {
      final response = await _dio.post(_baseUrl + 'transactions/', data: data);
      print(response);
      Map userMap = jsonDecode(response.data);
      print(_baseUrl + 'transactions/' + data.toString());
      print(userMap);
      return Transaction.fromJson(userMap);
    } catch (error, stacktrace) {
      printOutError(error, stacktrace);
      return Transaction.withError('$error');
    }
  }

  Future<ServiceCount> servicecount(FormData data) async {
    try {
      final response = await _dio.post(_baseUrl + 'services_count/', data: data);
      // print(response.data);
      Map userMap = jsonDecode(response.data);
      print(_baseUrl + 'services_count/' + data.toString());
      print(userMap);
      return ServiceCount.fromJson(userMap);
    } catch (error, stacktrace) {
      printOutError(error, stacktrace);
      return ServiceCount.withError('$error');
    }
  }

  Future<Pricemodel> getprice(FormData data) async {
    try {
      final response = await _dio.post(_baseUrl + 'price/', data: data);
      // print(response.data);
      Map userMap = jsonDecode(response.data);
      print(_baseUrl + 'price/' + data.toString());
      print(userMap);
      return Pricemodel.fromJson(userMap);
    } catch (error, stacktrace) {
      printOutError(error, stacktrace);
      return Pricemodel.withError('$error');
    }
  }

  Future<Pricemodel> getmultiprice(FormData data) async {
    try {
      final response = await _dio.post(_baseUrl + 'multi_price/', data: data);
      print(response.data);
      Map userMap = jsonDecode(response.data);
      print(_baseUrl + 'multi_price/');
      
      return Pricemodel.fromJson(userMap);
    } catch (error, stacktrace) {
      printOutError(error, stacktrace);
      return Pricemodel.withError('$error');
    }
  }

  Future<Pricemodel> gettransresult(FormData data) async {
    try {
      final response = await _dio.post(_baseUrl + 'payment_status/', data: data);
      print(response.data);
      Map userMap = jsonDecode(response.data);
      print(_baseUrl + 'payment_status/');
      
      return Pricemodel.fromJson(userMap);
    } catch (error, stacktrace) {
      printOutError(error, stacktrace);
      return Pricemodel.withError('$error');
    }
  }
}
