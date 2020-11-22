import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class Professionaltax extends StatefulWidget {
  final String title;
  const Professionaltax({Key key, this.title}) : super(key: key);
  @override
  _ProfessionaltaxState createState() => _ProfessionaltaxState();
}

class _ProfessionaltaxState extends State<Professionaltax> {
  final _applicantcontroller = new TextEditingController();
  final _taxicontroller = new TextEditingController();
  final _truckcontroller = new TextEditingController();
  final _buscontroller = new TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  File image1file;
  SharedPreferences prefs;
  String uid, name, mobile, emailid;
  bool _loading = false;
  Random random = new Random();
  String samount;
  int transid;
  int taxirate = 0;
  int goodsrate = 0;
  int busrate = 0;
  bool taxivalue = false;
  bool goodstruckvalue = false;
  bool busvalue = false;
  Razorpay _razorpay;

  // Map<String, bool> values = {
  //   "Taxi": false,
  //   "Goods truck": false,
  //   "Bus": false
  // };

  var tmpArray = [];
  // getCheckboxItems() {
  //   tmpArray.clear();
  //   values.forEach((key, value) {
  //     if (value == true) {
  //       tmpArray.add(key);
  //     }
  //   });
  //   print(tmpArray);
  // }

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        shrinkWrap: true,
        children: [
          SizedBox(height: 10),
          _applicantcard(),
          _vehiclecard(),
          _image1(),
          _loading ? CupertinoActivityIndicator() : _submitbutton()
        ],
      ),
    );
  }

  _applicantcard() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 5),
      child: Card(
        elevation: 3,
        shadowColor: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Applicant Mobile Number',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic)),
              SizedBox(height: 10),
              TextField(
                controller: _applicantcontroller,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly
                ],
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 15),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor)),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor)),
                    hintText: 'Applicant No.'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _image1() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 5),
      child: Card(
        elevation: 3,
        shadowColor: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Upload Pancard',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    image1file != null
                        ? image1file.path.contains('jpg') ||
                                image1file.path.contains('png')
                            ? Image.file(
                                image1file,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.description,
                                color: Theme.of(context).primaryColor,
                                size: 100,
                              )
                        : Image.asset(
                            'assets/images/upload.png',
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                    FloatingActionButton.extended(
                      icon: Icon(Icons.file_upload),
                      heroTag: 0,
                      onPressed: () async {
                        print('Pick Image1');
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext bc) {
                              return SafeArea(
                                child: Container(
                                  child: new Wrap(
                                    children: <Widget>[
                                      new ListTile(
                                          leading:
                                              new Icon(Icons.photo_library),
                                          title: new Text('Photo Library'),
                                          onTap: () async {
                                            Navigator.of(context).pop();
                                            FilePickerResult result =
                                                await FilePicker.platform
                                                    .pickFiles(
                                                        type: FileType.custom,
                                                        allowedExtensions: [
                                                          'jpg',
                                                          'pdf',
                                                          'doc'
                                                        ],
                                                        allowCompression: true);
                                            setState(() {
                                              image1file = File(
                                                  result.files.single.path);
                                              print(image1file);
                                            });
                                          }),
                                      new ListTile(
                                        leading: new Icon(Icons.photo_camera),
                                        title: new Text('Camera'),
                                        onTap: () async {
                                          Navigator.of(context).pop();
                                          final image = await ImagePicker()
                                              .getImage(
                                                  source: ImageSource.camera,
                                                  imageQuality: 50);
                                          setState(() {
                                            image1file = File(image.path);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      label: Text('Pick'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _vehiclecard() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 5),
      child: Card(
        elevation: 2,
        shadowColor: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Which vehicle do you have?',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic)),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text('Taxi', style: TextStyle(fontSize: 13)),
                        value: taxivalue,
                        onChanged: (bool value) {
                          setState(() {
                            taxivalue = value;
                            if (!taxivalue) {
                              taxirate = 0;
                              _taxicontroller.clear();
                            }
                          });
                        }),
                  ),
                  !taxivalue
                      ? Container()
                      : Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextField(
                              controller: _taxicontroller,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                WhitelistingTextInputFormatter.digitsOnly
                              ],
                              onChanged: (texts) {
                                int text = int.parse(texts);
                                if (text == 0) {
                                  taxirate = 0;
                                } else if (text == 1) {
                                  taxirate = 1000;
                                } else if (text > 1) {
                                  taxirate = 2500;
                                }
                                print(taxirate);
                              },
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 15),
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor)),
                                  hintText: 'Enter Taxi Count.'),
                            ),
                          ),
                        ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        title:
                            Text('Goods truck', style: TextStyle(fontSize: 13)),
                        value: goodstruckvalue,
                        onChanged: (bool value) {
                          setState(() {
                            goodstruckvalue = value;
                            if (!goodstruckvalue) {
                              goodsrate = 0;
                              _truckcontroller.clear();
                            }
                          });
                        }),
                  ),
                  !goodstruckvalue
                      ? Container()
                      : Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextField(
                              controller: _truckcontroller,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                WhitelistingTextInputFormatter.digitsOnly
                              ],
                              onChanged: (texts) {
                                int text = int.parse(texts);
                                if (text == 0) {
                                  goodsrate = 0;
                                } else if (text == 1) {
                                  goodsrate = 1500;
                                } else if (text > 1) {
                                  goodsrate = 2500;
                                }
                              },
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 15),
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor)),
                                  hintText: 'Enter Truck Count.'),
                            ),
                          ),
                        ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text('Bus', style: TextStyle(fontSize: 13)),
                        value: busvalue,
                        onChanged: (bool value) {
                          setState(() {
                            busvalue = value;
                            if (!busvalue) {
                              busrate = 0;
                              _buscontroller.clear();
                            }
                          });
                        }),
                  ),
                  !busvalue
                      ? Container()
                      : Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextField(
                              controller: _buscontroller,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                WhitelistingTextInputFormatter.digitsOnly
                              ],
                              onChanged: (texts) {
                                int text = int.parse(texts);
                                if (text == 0) {
                                  busrate = 0;
                                }
                                if (text == 1) {
                                  busrate = 1500;
                                } else if (text > 1) {
                                  busrate = 2500;
                                }
                              },
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 15),
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor)),
                                  hintText: 'Enter Bus Count.'),
                            ),
                          ),
                        ),
                ],
              ),
              //   GridView.count(
              //       shrinkWrap: true,
              //       scrollDirection: Axis.vertical,
              //       childAspectRatio: 5,
              //       crossAxisCount: 1,
              //       children: values.keys.map((String key) {
              //         return CheckboxListTile(
              //             dense: true,
              //             controlAffinity: ListTileControlAffinity.leading,
              //             title: Text(key, style: TextStyle(fontSize: 13)),
              //             value: values[key],
              //             onChanged: (bool value) {
              //               setState(() {
              //                 values[key] = value;
              //               });
              //             });
              //       }).toList()),
            ],
          ),
        ),
      ),
    );
  }

  _submitbutton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 15,
        child: RaisedButton(
          color: Theme.of(context).primaryColor,
          onPressed: () {
            // getCheckboxItems();
            if (_applicantcontroller.text == '') {
              _showtoast('Please enter applicant no');
              // } else if (tmpArray.isEmpty) {
              //   _showtoast("Please select any vehicle first!!");
            } else if (!taxivalue && !goodstruckvalue && !busvalue) {
              _showtoast('Please select any vehicle to proceed');
            } else if (taxivalue && _taxicontroller.text == '') {
              _showtoast('Please enter taxi count');
            } else if (goodstruckvalue && _truckcontroller.text == '') {
              _showtoast('Please enter goods count');
            } else if (busvalue && _buscontroller.text == '') {
              _showtoast('Please enter bus count');
            } else if (image1file == null) {
              _showtoast('Please select pancard');
            } else {
              if (taxivalue) {
                tmpArray.add('Taxi' + '_' + taxirate.toString());
              }
              if (goodstruckvalue) {
                tmpArray.add('Goods truck' + '_' + goodsrate.toString());
              }
              if (busvalue) {
                tmpArray.add('Bus' + '_' + busrate.toString());
              }
              _uploaddata((taxirate + goodsrate + busrate).toString());
            }
          },
          shape: new RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5)),
          child: Text(
            'Pay ' + (taxirate + goodsrate + busrate).toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  _uploaddata(String amount) async {
    setState(() {
      transid = random.nextInt(100000);
    });
    FormData formData = FormData.fromMap({
      "user_uid": uid,
      "t_id": transid,
      "app_no": _applicantcontroller.text,
      "form_name": widget.title,
      "pancard": await MultipartFile.fromFile(image1file.path,
          filename: image1file.path.split('/').last),
      "vehicle": tmpArray.reduce((value, element) => value + ',' + element)
    });

    print(formData.fields.toString());
    setState(() => _loading = true);
    final response =
        await Dio().post('https://rto24x7.com/api/form_new/', data: formData);
    setState(() => _loading = false);
    response.statusCode == 200
        ? _openCheckout(amount)
        : _scaffoldKey.currentState
            .showSnackBar(new SnackBar(content: Text('Something went wrong')));
  }

  void _openCheckout(String amount) async {
    setState(() {
      samount = amount;
    });
    double payamount = (double.parse(amount) * 100);
    print(payamount);
    var options = {
      'key': 'rzp_live_8bac7CqJHegwls',
      'amount': payamount,
      'name': name,
      'description': widget.title,
      'prefill': {'contact': mobile, 'email': emailid},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    var now = new DateTime.now();
    var currentdate = new DateFormat('dd-MM-yyyy');
    var currentime = new DateFormat.jm().format(now);
    String formattedDate = currentdate.format(now);
    _paymentdailog(response.paymentId, 'Thank You!',
        'Your transaction was successful', formattedDate, currentime, 'Sucess');
    FormData tformData = FormData.fromMap({
      "new_t_id": response.paymentId,
      "t_id": transid,
    });
    print(tformData.fields);
    final transresponse = await Dio()
        .post('https://rto24x7.com/api/payment_status/', data: tformData);

    Map<String, dynamic> user = jsonDecode(transresponse.data);
    if (user['result'] == 'Success') {
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext ctx) => DashBoard()));
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    var now = new DateTime.now();
    var currentdate = new DateFormat('dd-MM-yyyy');
    var currentime = new DateFormat.jm().format(now);
    _paymenterrordailog(currentdate, currentime);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    var now = new DateTime.now();
    var currentdate = new DateFormat('dd-MM-yyyy');
    var currentime = new DateFormat.jm().format(now);
    _paymenterrordailog(currentdate, currentime);
  }

  _paymentdailog(transid, title, msg, date, time, status) {
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
                      subtitle: Text(widget.title),
                      trailing: Image.asset("assets/images/rto_image.png",
                          width: 30, height: 30),
                    ),
                    ListTile(
                      dense: true,
                      title: Text('AMOUNT'),
                      subtitle: Text(
                        samount,
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      trailing: Text(status),
                    ),
                    Container(
                      height: 50,
                      child: Center(child: Text('Transaction id : ' + transid)),
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

  _paymenterrordailog(date, time) {
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
                      subtitle: Text(date.toString()),
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
                      subtitle: Text(widget.title),
                      trailing: Image.asset("assets/images/rto_image.png",
                          width: 30, height: 30),
                    ),
                    ListTile(
                      dense: true,
                      title: Text('AMOUNT'),
                      subtitle: Text(
                        samount,
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
                          _openCheckout(samount);
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

  _admindailog() {
    showDialog(
        barrierColor: Theme.of(context).primaryColor,
        barrierDismissible: false,
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
                    Image.asset("assets/images/rto_image.png",
                        width: 110, height: 110),
                    Text(
                      'Thank You',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    Container(height: 5),
                    Text(
                      'Admin will send you\nprice after calculation',
                      style: TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                    Container(height: 10),
                    RaisedButton(
                        child: Text(
                          'Ok',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Theme.of(context).primaryColor,
                        onPressed: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext ctx) => DashBoard()));
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

  _showtoast(String msg) {
    return _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: Text(msg)));
  }
}
