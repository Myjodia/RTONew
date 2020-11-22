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
import 'package:rto/ApiProvider/Apifile.dart';
import 'package:rto/Model/pricemodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class MultiVehSrevicePage extends StatefulWidget {
  final List<String> multiform;
  final List<String> multiformprice;
  final String count;

  const MultiVehSrevicePage(
      {Key key, this.multiform, this.count, this.multiformprice})
      : super(key: key);

  @override
  _MultiVehSrevicePageState createState() => _MultiVehSrevicePageState();
}

class _MultiVehSrevicePageState extends State<MultiVehSrevicePage> {
  int selectedRadio;
  final _applicantcontroller = new TextEditingController();
  final _textcontroller = new TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  File motorfile;
  File medicalfile;
  File learnfile;
  File policereportfile;
  File gazetepaperfile;
  File visafile;
  File passportfile;
  File hazardfile;
  File bprooffile;
  File idcardfile;
  Razorpay _razorpay;
  String uid, name, mobile, emailid;
  SharedPreferences prefs;
  bool _loading = false;
  Random random = new Random();
  String samount;
  int transid;

  final List<String> _dropdownValues = [
    'Pan Card',
    'Birth Certificate',
    '10th Board Certificate',
    '12th Board Certificate',
    'LIC Certificate',
    'Leaving Certificate'
  ];

  String _selectedbp;
  String expirydatetext = 'Select license expiry date';
  String birthdatetext = 'Select birth date';
  Future _price;
  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  _getprice(String datetxt) async {
    prefs = await SharedPreferences.getInstance();

    setState(() {
      uid = prefs.getString('uid');
      name = prefs.getString('name');
      mobile = prefs.getString('mobile');
      emailid = prefs.getString('email');
    });
    FormData formData = FormData.fromMap({
      "state_name": 'Maharashtra',
      "form_name": widget.multiformprice
          .reduce((value, element) => value + ',' + element),
      "date": datetxt.contains('Select license expiry date') ? '' : datetxt,
      "count": widget.count,
    });
    print(formData.fields);
    _price = ApiFile().getmultiprice(formData);
  }

  @override
  void initState() {
    _getprice(expirydatetext);
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    selectedRadio = 0;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: Text('Multiple Services')),
        body: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SizedBox(height: 10),
            _applicantcard(),
            widget.multiform.contains('motorlicence')
                ? _motorfile()
                : Container(),
            widget.multiform.contains('medicaldoc')
                ? _medicaldoc()
                : Container(),
            widget.multiform.contains('learndoc') ? _learnfile() : Container(),
            widget.multiform.contains('policereport')
                ? _policefile()
                : Container(),
            widget.multiform.contains('gazetedoc') ? _gazetfile() : Container(),
            widget.multiform.contains('passport')
                ? _passportfile()
                : Container(),
            widget.multiform.contains('visa') ? _visafile() : Container(),
            widget.multiform.contains('hazard') ? _hazardfile() : Container(),
            widget.multiform.contains('bpdoc')
                ? _birthproofcard()
                : Container(),
            widget.multiform.contains('identification')
                ? _identitycard()
                : Container(),
            widget.multiform.contains('textbox') ? _textboxcard() : Container(),
            widget.multiform.contains('datepicker') ? _datecard() : Container(),
            widget.multiform.contains('birthdatepicker')
                ? _birthdatecard()
                : Container(),
            FutureBuilder<Pricemodel>(
                future: _price,
                builder:
                    (BuildContext context, AsyncSnapshot<Pricemodel> snapshot) {
                  if (snapshot.connectionState == ConnectionState.none)
                    return Container();
                  else if (snapshot.connectionState == ConnectionState.waiting)
                    return CupertinoActivityIndicator(radius: 30);

                  return snapshot.data.result == null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                                    _getprice(expirydatetext);
                                  });
                                })
                          ],
                        )
                      : _loading
                          ? CupertinoActivityIndicator()
                          : snapshot.data.price == ''
                              ? Container()
                              : _submitbutton(int.parse(snapshot.data.price));
                }),
          ],
        ));
  }

  _submitbutton(int amount) {
    print('amount= ' + amount.toString());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 15,
        child: RaisedButton(
          color: Theme.of(context).primaryColor,
          onPressed: () {
            if (_applicantcontroller.text == '') {
              _showtoast('Please enter customer no');
              return;
            }
            if (widget.multiform.contains('motorlicence')) {
              if (motorfile == null) {
                _showtoast('select motorlicense image  to proceed');
                return;
              }
            }
            if (widget.multiform.contains('medicaldoc')) {
              if (medicalfile == null) {
                _showtoast('select medical file to proceed');
                return;
              }
            }
            if (widget.multiform.contains('learndoc')) {
              if (learnfile == null) {
                _showtoast('select learning doc to proceed');
                return;
              }
            }
            if (widget.multiform.contains('policereport')) {
              if (policereportfile == null) {
                _showtoast('Please select policefile');
                return;
              }
            }
            if (widget.multiform.contains('gazetedoc')) {
              if (gazetepaperfile == null) {
                _showtoast('Please select gazetedoc');
                return;
              }
            }
            if (widget.multiform.contains('passport')) {
              if (passportfile == null) {
                _showtoast('Please select passport');
                return;
              }
            }
            if (widget.multiform.contains('visa')) {
              if (visafile == null) {
                _showtoast('Please select visa');
                return;
              }
            }
            if (widget.multiform.contains('hazard')) {
              if (hazardfile == null) {
                _showtoast('Please select hazardfile');
                return;
              }
            }
            if (widget.multiform.contains('bpdoc')) {
              if (bprooffile == null) {
                _showtoast('select birth proof to proceed');
                return;
              }
            }
            if (widget.multiform.contains('identification')) {
              if (idcardfile == null) {
                _showtoast('Please select identification file');
                return;
              }
            }

            if (widget.multiform.contains('textbox')) {
              if (_textcontroller.text == '') {
                _showtoast('Please enter MDl no.');
                return;
              }
            }

            if (widget.multiform.contains('datepicker')) {
              if (expirydatetext.contains('Select license expiry date')) {
                _showtoast('select date to proceed');
                return;
              }
            }
            if (widget.multiform.contains('birthdatepicker')) {
              if (birthdatetext.contains('Select birth date')) {
                _showtoast('select date to proceed');
                return;
              }
            }
            _uploaddata(amount.toString());
          },
          shape: new RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5)),
          child: Text(
            amount == 0 ? "Submit" : "Pay ₹ " + amount.toString(),
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

    print(idcardfile.path);
    FormData formData = FormData.fromMap({
      "user_uid": uid,
      "t_id": transid,
      "app_no": _applicantcontroller.text,
      "date": expirydatetext.contains('Select license expiry date')
          ? ''
          : expirydatetext,
      "birth_date":
          birthdatetext.contains('Select birth date') ? '' : birthdatetext,
      "mdl_no": _textcontroller.text,
      "price": amount,
      "form_name": widget.multiformprice
          .reduce((value, element) => value + ',' + element),
      "motor_dri_lic": widget.multiform.contains('motorlicence')
          ? await MultipartFile.fromFile(motorfile.path,
              filename: motorfile.path.split('/').last)
          : "",
      "medical": widget.multiform.contains('medicaldoc')
          ? await MultipartFile.fromFile(medicalfile.path,
              filename: medicalfile.path.split('/').last)
          : "",
      "learn_lic": widget.multiform.contains('learndoc')
          ? await MultipartFile.fromFile(learnfile.path,
              filename: learnfile.path.split('/').last)
          : "",
      "police_report": widget.multiform.contains('policereport')
          ? await MultipartFile.fromFile(policereportfile.path,
              filename: policereportfile.path.split('/').last)
          : '',
      "gazette": widget.multiform.contains('gazetedoc')
          ? await MultipartFile.fromFile(gazetepaperfile.path,
              filename: gazetepaperfile.path.split('/').last)
          : '',
      "passport": widget.multiform.contains('passport')
          ? await MultipartFile.fromFile(passportfile.path,
              filename: passportfile.path.split('/').last)
          : '',
      "visa": widget.multiform.contains('visa')
          ? await MultipartFile.fromFile(visafile.path,
              filename: visafile.path.split('/').last)
          : '',
      "hazardous_certi": widget.multiform.contains('hazard')
          ? await MultipartFile.fromFile(hazardfile.path,
              filename: hazardfile.path.split('/').last)
          : '',
      "aadhar_voting": widget.multiform.contains('identification')
          ? await MultipartFile.fromFile(idcardfile.path,
              filename: idcardfile.path.split('/').last)
          : '',
      "birth_proof": widget.multiform.contains('bpdoc')
          ? await MultipartFile.fromFile(bprooffile.path,
              filename: bprooffile.path.split('/').last)
          : '',
    });

    print(formData.fields);
    setState(() => _loading = true);
    final response = await Dio().post('https://rto24x7.com/api/form_new/',
        data: formData, onSendProgress: (int sent, int total) {});
    setState(() => _loading = false);

    response.statusCode == 200
        ? amount.contains('0') ? _admindailog() : _openCheckout(amount)
        : _scaffoldKey.currentState
            .showSnackBar(new SnackBar(content: Text('Something went wrong')));
  }

  void _openCheckout(String amount) async {
    print(amount);
    setState(() {
      samount = amount;
    });
    double payamount = (double.parse(amount) * 100);
    print(payamount);
    var options = {
      'key': 'rzp_live_8bac7CqJHegwls',
      'amount': payamount,
      'name': name,
      'description': widget.multiformprice
          .reduce((value, element) => value + '\n' + element),
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
                      subtitle: Text(widget.multiformprice
                          .reduce((value, element) => value + '\n' + element)),
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
                      subtitle: Text(widget.multiformprice
                          .reduce((value, element) => value + ',' + element)),
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

  _motorfile() {
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
              Text('Upload Motor Licence',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    motorfile != null
                        ? motorfile.path.contains('jpg') ||
                                motorfile.path.contains('png')
                            ? Image.file(
                                motorfile,
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
                        print('motorfile');
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
                                              motorfile = File(
                                                  result.files.single.path);
                                            });
                                            // final image = await ImagePicker()
                                            //     .getImage(
                                            //         source: ImageSource.gallery,
                                            //         imageQuality: 50);
                                            // setState(() {
                                            //   motorfile = File(image.path);
                                            //   print(motorfile);
                                            // });
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
                                            motorfile = File(image.path);
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

  _medicaldoc() {
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
              Text('Upload Medical Certificate',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    medicalfile != null
                        ? medicalfile.path.contains('jpg') ||
                                medicalfile.path.contains('png')
                            ? Image.file(
                                medicalfile,
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
                      heroTag: null,
                      onPressed: () {
                        print('medicalfile');
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
                                              medicalfile = File(
                                                  result.files.single.path);
                                              print(medicalfile);
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
                                            medicalfile = File(image.path);
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

  _learnfile() {
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
              Text('Upload Learning Licence',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    learnfile != null
                        ? learnfile.path.contains('jpg') ||
                                learnfile.path.contains('png')
                            ? Image.file(
                                learnfile,
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
                      heroTag: null,
                      onPressed: () {
                        print('Pick Image3');
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
                                              learnfile = File(
                                                  result.files.single.path);
                                              print(learnfile);
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
                                            learnfile = File(image.path);
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

  _policefile() {
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
              Text('Upload Police Report',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    policereportfile != null
                        ? policereportfile.path.contains('jpg') ||
                                policereportfile.path.contains('png')
                            ? Image.file(
                                policereportfile,
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
                      heroTag: null,
                      onPressed: () {
                        print('Pick Image3');
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
                                              policereportfile = File(
                                                  result.files.single.path);
                                              print(policereportfile);
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
                                            policereportfile = File(image.path);
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

  _gazetfile() {
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
              Text('Upload Gazete/Paper CutOut',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    gazetepaperfile != null
                        ? gazetepaperfile.path.contains('jpg') ||
                                gazetepaperfile.path.contains('png')
                            ? Image.file(
                                gazetepaperfile,
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
                      heroTag: null,
                      onPressed: () {
                        print('Pick gazet');
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
                                              gazetepaperfile = File(
                                                  result.files.single.path);
                                              print(gazetepaperfile);
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
                                            gazetepaperfile = File(image.path);
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

  _visafile() {
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
              Text('Upload Visa',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    visafile != null
                        ? visafile.path.contains('jpg') ||
                                visafile.path.contains('png')
                            ? Image.file(
                                visafile,
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
                      heroTag: null,
                      onPressed: () {
                        print('Pick visa');
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
                                              visafile = File(
                                                  result.files.single.path);
                                              print(visafile);
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
                                            visafile = File(image.path);
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

  _passportfile() {
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
              Text('Upload Passport',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    passportfile != null
                        ? passportfile.path.contains('jpg') ||
                                passportfile.path.contains('png')
                            ? Image.file(
                                passportfile,
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
                      heroTag: null,
                      onPressed: () {
                        print('Pick visa');
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
                                              passportfile = File(
                                                  result.files.single.path);
                                              print(passportfile);
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
                                            passportfile = File(image.path);
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

  _hazardfile() {
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
              Text('Upload Hazardous Certificate',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    hazardfile != null
                        ? hazardfile.path.contains('jpg') ||
                                hazardfile.path.contains('png')
                            ? Image.file(
                                medicalfile,
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
                      heroTag: null,
                      onPressed: () {
                        print('Pick hazard');
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
                                              hazardfile = File(
                                                  result.files.single.path);
                                              print(hazardfile);
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
                                            hazardfile = File(image.path);
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

  _identitycard() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 5),
      child: Card(
        elevation: 3,
        shadowColor: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Select Identification Document',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic)),
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(children: <Widget>[
                      Row(children: <Widget>[
                        Radio(
                          value: 1,
                          groupValue: selectedRadio,
                          activeColor: Colors.green,
                          onChanged: (val) {
                            print("Radio $val");
                            setSelectedRadio(val);
                          },
                        ),
                        Text(
                          'Adhaar Card',
                          style: TextStyle(fontSize: 14),
                        )
                      ]),
                      Row(children: <Widget>[
                        Radio(
                          value: 2,
                          groupValue: selectedRadio,
                          activeColor: Colors.blue,
                          onChanged: (val) {
                            print("Radio $val");
                            setSelectedRadio(val);
                          },
                        ),
                        Text(
                          'Voting Card',
                          style: TextStyle(fontSize: 14),
                        )
                      ])
                    ]),
                    Column(
                      children: <Widget>[
                        selectedRadio == 0
                            ? Row(
                                children: <Widget>[
                                  Image.asset(
                                    'assets/images/aadharcard.png',
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  ),
                                  Image.asset(
                                    'assets/images/voteridcard.png',
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ],
                              )
                            : idcardfile != null
                                ? idcardfile.path.contains('jpg') ||
                                        idcardfile.path.contains('png')
                                    ? Image.file(
                                        idcardfile,
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(
                                        Icons.description,
                                        color: Theme.of(context).primaryColor,
                                        size: 50,
                                      )
                                : Image.asset(
                                    selectedRadio == 1
                                        ? 'assets/images/aadharcard.png'
                                        : 'assets/images/voteridcard.png',
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                        SizedBox(height: 10),
                        FloatingActionButton.extended(
                            icon: Icon(Icons.file_upload),
                            heroTag: null,
                            onPressed: () {
                              selectedRadio == 0
                                  ? _scaffoldKey.currentState.showSnackBar(
                                      new SnackBar(
                                          content: Text(
                                              "Please select first document!!")))
                                  : showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext bc) {
                                        return SafeArea(
                                          child: Container(
                                            child: new Wrap(
                                              children: <Widget>[
                                                new ListTile(
                                                    leading: new Icon(
                                                        Icons.photo_library),
                                                    title: new Text(
                                                        'Photo Library'),
                                                    onTap: () async {
                                                      Navigator.of(context)
                                                          .pop();
                                                      FilePickerResult result =
                                                          await FilePicker
                                                              .platform
                                                              .pickFiles(
                                                                  type: FileType
                                                                      .custom,
                                                                  allowedExtensions: [
                                                                    'jpg',
                                                                    'pdf',
                                                                    'doc'
                                                                  ],
                                                                  allowCompression:
                                                                      true);
                                                      setState(() {
                                                        idcardfile = File(result
                                                            .files.single.path);
                                                        print(idcardfile);
                                                      });
                                                    }),
                                                new ListTile(
                                                  leading: new Icon(
                                                      Icons.photo_camera),
                                                  title: new Text('Camera'),
                                                  onTap: () async {
                                                    Navigator.of(context).pop();
                                                    final image =
                                                        await ImagePicker()
                                                            .getImage(
                                                                source:
                                                                    ImageSource
                                                                        .camera,
                                                                imageQuality:
                                                                    50);
                                                    setState(() {
                                                      idcardfile =
                                                          File(image.path);
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                            },
                            label: Text('Pick')),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _birthproofcard() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 5),
      child: Card(
        elevation: 3,
        shadowColor: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Choose Birth Proof Document',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic)),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: DropdownButtonHideUnderline(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.black26),
                    ),
                    child: DropdownButton(
                      items: _dropdownValues
                          .map((value) => DropdownMenuItem(
                                child: Text(value),
                                value: value,
                              ))
                          .toList(),
                      onChanged: (String value) {
                        setState(() {
                          _selectedbp = value;
                        });
                        print(_selectedbp);
                      },
                      value: _selectedbp,
                      isExpanded: true,
                      hint: Text('Select Birth Proof'),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      bprooffile != null
                          ? bprooffile.path.contains('jpg') ||
                                  bprooffile.path.contains('png')
                              ? Image.file(
                                  bprooffile,
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
                              _selectedbp == null
                                  ? 'assets/images/upload.png'
                                  : _selectedbp.contains('Pan Card')
                                      ? 'assets/images/pancard.jpg'
                                      : _selectedbp
                                              .contains('Birth Certificate')
                                          ? 'assets/images/birthcertificate.jpeg'
                                          : _selectedbp.contains(
                                                  '10th Board Certificate')
                                              ? 'assets/images/ssc.png'
                                              : _selectedbp.contains(
                                                      '12th Board Certificate')
                                                  ? 'assets/images/mar.jpg'
                                                  : _selectedbp.contains(
                                                          'LIC Certificate')
                                                      ? 'assets/images/lic.jpg'
                                                      : 'assets/images/secondar.png',
                              height: 100,
                              width: 100,
                            ),
                      Text(
                          _selectedbp == null
                              ? 'Select Birth Proof'
                              : _selectedbp,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                  FloatingActionButton.extended(
                    icon: Icon(Icons.file_upload),
                    heroTag: null,
                    onPressed: () {
                      print('bp Pick Image');
                      _selectedbp == null
                          ? _scaffoldKey.currentState.showSnackBar(new SnackBar(
                              content: Text("Please select first document!!")))
                          : showModalBottomSheet(
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
                                                          allowCompression:
                                                              true);
                                              setState(() {
                                                bprooffile = File(
                                                    result.files.single.path);
                                                print(bprooffile);
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
                                              bprooffile = File(image.path);
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
            ],
          ),
        ),
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
                    hintText: 'Customer No.'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _textboxcard() {
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
              Text('MDL No.',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic)),
              SizedBox(height: 10),
              TextField(
                controller: _textcontroller,
                keyboardType: TextInputType.text,
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
                    hintText: 'Enter the MDL No.'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iosdate() {
    return CupertinoDatePicker(
      initialDateTime: DateTime.now(),
      minimumDate: DateTime.now().subtract(Duration(days: 1)),
      onDateTimeChanged: (DateTime newdate) {
        print(newdate.day);
        setState(() {
          expirydatetext = newdate.day.toString() +
              '-' +
              newdate.month.toString() +
              '-' +
              newdate.year.toString();
          _getprice(expirydatetext);
        });
      },
      use24hFormat: false,
      minimumYear: 2010,
      maximumYear: 2050,
      minuteInterval: 1,
      mode: CupertinoDatePickerMode.date,
    );
  }

  Widget iosdate1() {
    return CupertinoDatePicker(
      initialDateTime: DateTime.now(),
      minimumDate: DateTime.now().subtract(Duration(days: 1)),
      onDateTimeChanged: (DateTime newdate) {
        print(newdate.day);
        setState(() {
          birthdatetext = newdate.day.toString() +
              '-' +
              newdate.month.toString() +
              '-' +
              newdate.year.toString();
        });
      },
      use24hFormat: false,
      minimumYear: 2010,
      maximumYear: 2050,
      minuteInterval: 1,
      mode: CupertinoDatePickerMode.date,
    );
  }

  Widget _datecard() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
            context: context,
            builder: (BuildContext builder) {
              return Container(
                  height: MediaQuery.of(context).copyWith().size.height / 3,
                  child: iosdate());
            });
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 5),
        child: Card(
          elevation: 3,
          shadowColor: Theme.of(context).primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: <Widget>[
                Icon(Icons.calendar_today),
                SizedBox(width: 10),
                Text(expirydatetext,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _birthdatecard() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
            context: context,
            builder: (BuildContext builder) {
              return Container(
                  height: MediaQuery.of(context).copyWith().size.height / 3,
                  child: iosdate1());
            });
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 5),
        child: Card(
          elevation: 3,
          shadowColor: Theme.of(context).primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: <Widget>[
                Icon(Icons.calendar_today),
                SizedBox(width: 10),
                Text(birthdatetext,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _showtoast(String msg) {
    return _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: Text(msg)));
  }
}
