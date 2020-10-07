import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:rto/ApiProvider/Apifile.dart';
import 'package:rto/Model/Transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Reports extends StatefulWidget {
  @override
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  bool sort;
  Future _subscriber;
  String uid, name, mobile, emailid;
  String title, msg, date, time, servicename, amount, status, transid;
  SharedPreferences prefs;
  List<Transactions> users = [];
  Razorpay _razorpay;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _userdetails() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      uid = prefs.getString('uid');
      name = prefs.getString('name');
      mobile = prefs.getString('mobile');
      emailid = prefs.getString('email');

      FormData formData = FormData.fromMap({
        "user_uid": uid,
      });
      _subscriber = ApiFile().getTransResponse(formData);
      print(uid);
    });
  }

  @override
  void initState() {
    _userdetails();
    sort = false;
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
  }

  onSortColum(int columnIndex, bool ascending) {
    if (ascending) {
      users.sort((a, b) => a.formStatus.compareTo(b.formStatus));
    } else {
      users.sort((a, b) => b.formStatus.compareTo(a.formStatus));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        automaticallyImplyLeading: false,
        leading: Icon(Icons.report),
        title: new Text('Transaction'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: FutureBuilder<Transaction>(
            future: _subscriber,
            builder:
                (BuildContext context, AsyncSnapshot<Transaction> snapshot) {
              if (snapshot.connectionState == ConnectionState.none)
                return Container();
              else if (snapshot.connectionState == ConnectionState.waiting)
                return Container(
                    height: MediaQuery.of(context).size.height - 100,
                    child: Center(
                        child: CupertinoActivityIndicator(
                      radius: 30,
                    )));

              users = snapshot.data.transactions;
              return snapshot.data.transactions == null
                  ? Container(
                      height: MediaQuery.of(context).size.height - 100,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                              snapshot.data.error.contains('SocketException:')
                                  ? 'No Internet Connection found!'
                                  : 'Something Went Wrong! try again',
                              style: TextStyle(color: Colors.black)),
                          RaisedButton(
                              color: Theme.of(context).primaryColor,
                              child: Text(
                                'Retry',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                setState(() {
                                  FormData formData = FormData.fromMap({
                                    "user_uid": uid,
                                  });
                                  _subscriber =
                                      ApiFile().getTransResponse(formData);
                                });
                              })
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                          columnSpacing: 5,
                          sortAscending: sort,
                          sortColumnIndex: 4,
                          horizontalMargin: 10,
                          columns: [
                            DataColumn(
                                label: Text('Date\nTime',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 12))),
                            DataColumn(
                                tooltip: 'Service',
                                label: Center(
                                  child: Text('Service',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 12)),
                                )),
                            DataColumn(
                                label: Text('Payment',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 12))),
                            DataColumn(
                                numeric: false,
                                label: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text('Transaction id',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 12)),
                                )),
                            DataColumn(
                                onSort: (columnIndex, ascending) {
                                  setState(() {
                                    sort = !sort;
                                  });
                                  onSortColum(columnIndex, ascending);
                                },
                                label: Text('Form Status',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 12)))
                          ],
                          rows: users
                              .map((user) => DataRow(cells: [
                                    DataCell(
                                        Center(
                                          child: Text(
                                              user.date + '\n' + user.time,
                                              style: TextStyle(fontSize: 10)),
                                        ), onTap: () {
                                      _showpaydialog(user);
                                      setState(() {
                                        servicename =
                                            user.formName.replaceAll(',', '\n');
                                        amount = user.payment;
                                        transid = user.transactionalId;
                                      });
                                    }),
                                    DataCell(
                                        Container(
                                          width: 60,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 5),
                                            child: Text(user.formName,
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    color: Colors.amber)),
                                          ),
                                        ), onTap: () {
                                      _showpaydialog(user);
                                      setState(() {
                                        servicename =
                                            user.formName.replaceAll(',', '\n');
                                        amount = user.payment;
                                        transid = user.transactionalId;
                                      });
                                    }),
                                    DataCell(
                                        Center(
                                          child: Text(user.payment,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: user.paymentStatus
                                                          .contains('Pending')
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : Colors.green)),
                                        ), onTap: () {
                                      _showpaydialog(user);
                                      setState(() {
                                        servicename =
                                            user.formName.replaceAll(',', '\n');
                                        amount = user.payment;
                                        transid = user.transactionalId;
                                      });
                                    }),
                                    DataCell(
                                        Center(
                                          child: Text(user.transactionalId,
                                              style: TextStyle(fontSize: 10)),
                                        ), onTap: () {
                                      _showpaydialog(user);
                                      setState(() {
                                        servicename =
                                            user.formName.replaceAll(',', '\n');
                                        amount = user.payment;
                                        transid = user.transactionalId;
                                      });
                                    }),
                                    DataCell(Center(
                                      child: Text(user.formStatus,
                                          style: TextStyle(fontSize: 10)),
                                    ))
                                  ]))
                              .toList()),
                    );
            }),
      ),
    );
  }

  _paymentdailog(transid, title, msg, date, time, status, url) {
    showDialog(
        // barrierColor: Theme.of(context).primaryColor,
        useSafeArea: true,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(height: 10),
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 20,
                          color: title.contains('Pending')
                              ? Theme.of(context).primaryColor
                              : Colors.green),
                    ),
                    Text(
                      msg,
                      style: TextStyle(fontSize: 16),
                    ),
                    Divider(
                      color: Colors.black,
                    ),
                    Container(height: 5),
                    ListTile(
                      title: Text(
                        'DATE',
                      ),
                      subtitle: Text(date),
                      trailing: Column(
                        children: [
                          Text(
                            'TIME',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(time, style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                    ListTile(
                      title: Text('Service name'),
                      subtitle: Text(servicename),
                      trailing: Image.asset("assets/images/rto_image.png",
                          width: 30, height: 30),
                    ),
                    ListTile(
                      dense: true,
                      title: Text('AMOUNT'),
                      subtitle: Text(
                        amount,
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      trailing: Text(status),
                    ),
                    title.contains('Pending') || title.contains('Failed')
                        ? RaisedButton(
                            child: Text(
                              'Pay Now',
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              Navigator.of(context).pop();
                              _scaffoldKey.currentState.showSnackBar(
                                  new SnackBar(
                                      content: Text(
                                          'Please Wait... we proceeding')));
                              _openCheckout(amount, servicename);
                            })
                        : status.contains('Completed')
                            ? Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text('Transaction id : ' + transid),
                                  RaisedButton(
                                      child: Text(
                                        'View Document',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                      onPressed: () {
                                        _launchURL(
                                            'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf');
                                      })
                                ],
                              )
                            : Container(
                                height: 50,
                                child: Center(
                                    child: Text('Transaction id : ' + transid)),
                              ),
                    Container(
                      height: 10,
                    )
                  ],
                ),
              ],
            ),
          );
        });
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _showpaydialog(Transactions user) {
    _paymentdailog(
        user.transactionalId,
        user.paymentStatus.contains('Pending') ? 'Pending' : 'Thank You!',
        user.paymentStatus.contains('Pending')
            ? 'Your Payment is Pending'
            : 'Your transaction was successful',
        user.date,
        user.time,
        user.formStatus,
        user.completedPdf);
  }

  _paymenterrordailog() {
    showDialog(
        // barrierColor: Theme.of(context).primaryColor,
        useSafeArea: true,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(height: 10),
                    Text(
                      'Failed',
                      style: TextStyle(
                          fontSize: 20, color: Theme.of(context).primaryColor),
                    ),
                    Text(
                      'Your payment failed try again!!',
                      style: TextStyle(fontSize: 16),
                    ),
                    Divider(
                      color: Colors.black,
                    ),
                    Container(height: 5),
                    ListTile(
                      title: Text(
                        'DATE',
                      ),
                      subtitle: Text(DateFormat.yMd().format(DateTime.now())),
                      trailing: Column(
                        children: [
                          Text(
                            'TIME',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(DateFormat.jm().format(DateTime.now()),
                              style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                    ListTile(
                      title: Text('Service name'),
                      subtitle: Text(servicename),
                      trailing: Image.asset("assets/images/rto_image.png",
                          width: 30, height: 30),
                    ),
                    ListTile(
                      dense: true,
                      title: Text('AMOUNT'),
                      subtitle: Text(
                        amount,
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      trailing: Column(
                        children: [
                          Text('Pending'),
                        ],
                      ),
                    ),
                    RaisedButton(
                        child: Text(
                          'Retry',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Theme.of(context).primaryColor,
                        onPressed: () {
                          Navigator.of(context).pop();
                          _scaffoldKey.currentState.showSnackBar(
                              new SnackBar(content: Text('Please Wait')));
                          _openCheckout(amount, servicename);
                        }),
                    Container(
                      height: 10,
                    )
                  ],
                ),
              ],
            ),
          );
        });
  }

  void _openCheckout(String amount, formname) async {
    print(amount);
    double payamount = (double.parse(amount) * 100);
    print(payamount);
    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag',
      'amount': payamount,
      'name': name,
      'description': formname,
      'prefill': {'contact': mobile, 'email': emailid},
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    var now = new DateTime.now();
    var currentdate = new DateFormat('dd-MM-yyyy');
    var currentime = new DateFormat.jm().format(now);
    String formattedDate = currentdate.format(now);
    _paymentdailog(
        response.paymentId,
        'Thank You!',
        'Your transaction was successful',
        formattedDate,
        currentime,
        'Sucess',
        '');
    FormData tformData = FormData.fromMap({
      "new_t_id": response.paymentId,
      "t_id": transid,
    });
    print(tformData.fields);
    final transresponse = await Dio()
        .post('https://rto24x7.com/api/payment_status/', data: tformData);

    Map<String, dynamic> user = jsonDecode(transresponse.data);
    if (user['result'] == 'Success') {
      setState(() {
        FormData formData = FormData.fromMap({
          "user_uid": uid,
        });
        _subscriber = ApiFile().getTransResponse(formData);
      });
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _paymenterrordailog();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _paymenterrordailog();
  }
}
