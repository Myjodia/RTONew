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

class SingleFormPage extends StatefulWidget {
  final String title, img1, img2, img3, textname;
  final bool image1,
      image2,
      image3,
      textbox,
      iddocs,
      bpdocs,
      applicantcard,
      datepicker;

  const SingleFormPage(
      {Key key,
      this.title,
      this.img1,
      this.img2,
      this.img3,
      this.image1,
      this.image2,
      this.image3,
      this.textbox,
      this.iddocs,
      this.textname,
      this.bpdocs,
      this.applicantcard,
      this.datepicker})
      : super(key: key);

  @override
  _SingleFormPageState createState() => _SingleFormPageState();
}

class _SingleFormPageState extends State<SingleFormPage> {
  int selectedRadio;
  final _applicantcontroller = new TextEditingController();
  final _licensecontroller = new TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _dropdownValues = [
    'Pan Card',
    'Birth Certificate',
    '10th Board Certificate',
    '12th Board Certificate',
    'LIC Certificate',
    'Leaving Certificate'
  ];

  String _selectedbp;
  String _selectedtypeveh;

  String datetext = 'Select date';
  Future _price;
  File image1file;
  File image2file;
  File image3file;
  File bprooffile;
  File idcardfile;
  Razorpay _razorpay;
  String uid, name, mobile, emailid;
  SharedPreferences prefs;
  String uploadimg1, uploadimg2, uploadimg3, uploadtextname;
  bool _loading = false;
  Random random = new Random();
  String samount;
  int transid;

  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  _getprice() async {
    prefs = await SharedPreferences.getInstance();

    setState(() {
      uid = prefs.getString('uid');
      name = prefs.getString('name');
      mobile = prefs.getString('mobile');
      emailid = prefs.getString('email');
    });

    FormData formData = FormData.fromMap({
      "state_name": 'Maharashtra',
      "form_name": widget.title,
      "date": datetext.contains('Select date') ? '' : datetext,
      "vehicle": _selectedtypeveh == null ? '' : _selectedtypeveh,
    });
    _price = ApiFile().getprice(formData);
  }

  @override
  void initState() {
    _getprice();
    image1file = null;
    image2file = null;
    image3file = null;
    idcardfile = null;
    selectedRadio = 0;
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: Text(widget.title)),
        body: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SizedBox(height: 10),
            widget.applicantcard ? _applicantcard() : Container(),
            widget.image1 ? _image1() : Container(),
            widget.image2 ? _image2() : Container(),
            widget.image3 ? _image3() : Container(),
            widget.datepicker ? _datecard() : Container(),
            widget.iddocs ? _identitycard() : Container(),
            widget.bpdocs ? _birthproofcard() : Container(),
            widget.textbox ? _textboxcard(widget.textname) : Container(),
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
                                    _getprice();
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 15,
        child: RaisedButton(
          color: Theme.of(context).primaryColor,
          onPressed: () {
            if (widget.applicantcard) {
              if (_applicantcontroller.text == '') {
                _showtoast('Please enter customer no');
                return;
              }
            }
            if (widget.image1) {
              if (image1file == null) {
                _showtoast('select ' + widget.img1 + ' to proceed');
                return;
              }
            }
            if (widget.image2) {
              if (image2file == null) {
                _showtoast('select ' + widget.img2 + ' to proceed');
                return;
              }
            }
            if (widget.image3) {
              if (image3file == null) {
                _showtoast('select ' + widget.img3 + ' to proceed');
                return;
              }
            }
            if (widget.textbox) {
              if (_licensecontroller.text == '') {
                _showtoast('Please enter ' + widget.textname);
                return;
              }
            }
            if (widget.bpdocs) {
              if (bprooffile == null) {
                _showtoast('select birth proof to proceed');
                return;
              }
            }
            if (widget.iddocs) {
              if (idcardfile == null) {
                _showtoast('select id card to proceed');
                return;
              }
            }
            if (widget.datepicker) {
              if (datetext.contains('Select date')) {
                _showtoast('select date to proceed');
                return;
              }
            }
            _postuploadfile(amount.toString());
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

  _postuploadfile(String amount) async {
    if (widget.img1.contains('Upload Medical Doc')) {
      uploadimg1 = 'medical';
    }
    if (widget.img2.contains('Upload Medical Doc')) {
      uploadimg2 = 'medical';
    }
    if (widget.img2.contains('Upload Domicile')) {
      uploadimg2 = 'domicile';
    }
    if (widget.img1.contains('Upload Conductor license')) {
      uploadimg1 = 'conductor_lic';
    }
    if (widget.img2.contains('Upload Conductor license')) {
      uploadimg2 = 'conductor_lic';
    }
    if (widget.img3.contains('Upload Police Report')) {
      uploadimg3 = 'police_report';
    }
    if (widget.img1.contains('Upload Gazette/Paper cutout')) {
      uploadimg1 = 'gazette';
    }
    if (widget.img2.contains('Upload Gazette/Paper cutout')) {
      uploadimg2 = 'gazette';
    }
    if (widget.textname.contains('Application no')) {
      uploadtextname = 'app_no';
    }
    if (widget.textname.contains('MDL No.')) {
      uploadtextname = 'mdl_no';
    }
    _uploaddata(amount);
  }

  _uploaddata(String amount) async {
    setState(() {
      transid = random.nextInt(100000);
    });
    FormData formData = FormData.fromMap({
      "user_uid": uid,
      "t_id": transid,
      "app_no": _applicantcontroller.text,
      "date": datetext,
      "price": amount,
      "form_name": widget.title,
      uploadtextname: _licensecontroller.text,
      uploadimg1: widget.image1
          ? await MultipartFile.fromFile(image1file.path,
              filename: image1file.path.split('/').last)
          : '',
      uploadimg2: widget.image2
          ? await MultipartFile.fromFile(image2file.path,
              filename: image2file.path.split('/').last)
          : '',
      uploadimg3: widget.image3
          ? await MultipartFile.fromFile(image3file.path,
              filename: image3file.path.split('/').last)
          : '',
      "aadhar_voting": widget.iddocs
          ? await MultipartFile.fromFile(idcardfile.path,
              filename: idcardfile.path.split('/').last)
          : '',
      "birth_proof": widget.bpdocs
          ? await MultipartFile.fromFile(bprooffile.path,
              filename: bprooffile.path.split('/').last)
          : '',
    });

    print(formData.fields.toString());
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
    setState(() {
      samount = amount;
    });
    double payamount = (double.parse(amount) * 100);
    print(payamount);
    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag',
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
              Text(widget.img1,
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

  _image2() {
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
              Text(widget.img2,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    image2file != null
                        ? image2file.path.contains('jpg') ||
                                image2file.path.contains('png')
                            ? Image.file(
                                image2file,
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
                        print('Pick Image2');
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
                                              image2file = File(
                                                  result.files.single.path);
                                              print(image2file);
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
                                            image2file = File(image.path);
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

  _image3() {
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
              Text(widget.img3,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    image3file != null
                        ? image3file.path.contains('jpg') ||
                                image3file.path.contains('png')
                            ? Image.file(
                                image3file,
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
                                              image3file = File(
                                                  result.files.single.path);
                                              print(image3file);
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
                                            image3file = File(image.path);
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

  _textboxcard(String text) {
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
              Text(text,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic)),
              SizedBox(height: 10),
              TextField(
                controller: _licensecontroller,
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
                    hintText: 'Enter the ' + text),
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
          datetext = newdate.day.toString() +
              '-' +
              newdate.month.toString() +
              '-' +
              newdate.year.toString();
          _getprice();
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
                Text(datetext,
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
