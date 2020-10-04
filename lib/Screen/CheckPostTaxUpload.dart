import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class CheckPostTax extends StatefulWidget {
  final String title;
  const CheckPostTax({Key key, this.title}) : super(key: key);

  @override
  _CheckPostTaxState createState() => _CheckPostTaxState();
}

class _CheckPostTaxState extends State<CheckPostTax> {
  final _applicantcontroller = new TextEditingController();
  final _vehcontroller = new TextEditingController();
  final _bordercontroller = new TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _selectedstate;
  SharedPreferences prefs;
  String uid, name, mobile, emailid;
  bool _loading = false;
  Random random = new Random();
  int transid;

  final List<String> _dropdownValues = [
    "Andhra Pradesh",
    "Assam",
    "Arunachal Pradesh",
    "Bihar",
    "Goa",
    "Gujarat",
    "Jammu & Kashmir",
    "Jharkhand",
    "West Bengal",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Orissa",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Tripura",
    "Uttaranchal",
    "Uttar Pradesh",
    "Haryana",
    "Himachal Pradesh",
    "Chhattisgarh"
  ];

  _getprice() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      uid = prefs.getString('uid');
      name = prefs.getString('name');
      mobile = prefs.getString('mobile');
      emailid = prefs.getString('email');
    });
  }

  @override
  void initState() {
    _getprice();
    super.initState();
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
          _statecard(),
          _vehboxcard('Vehicle No'),
          _borderboxcard('Border Name'),
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
                    hintText: 'Customer No.'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _vehboxcard(String text) {
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
                controller: _vehcontroller,
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

  _borderboxcard(String text) {
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
                controller: _bordercontroller,
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

  _statecard() {
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
              Text('Choose State',
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
                          _selectedstate = value;
                        });
                        print(_selectedstate);
                      },
                      value: _selectedstate,
                      isExpanded: true,
                      hint: Text('Select State'),
                    ),
                  ),
                ),
              ),
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
            if (_applicantcontroller.text == '') {
              _showtoast('Please enter customer no');
            } else if (_selectedstate == null) {
              _showtoast('Please select state');
            } else if (_vehcontroller.text == '') {
              _showtoast('Please enter vehile no');
            } else if (_bordercontroller.text == '') {
              _showtoast('Please enter border name');
            } else {
              _uploaddata();
            }
          },
          shape: new RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5)),
          child: Text(
            'Submit',
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

  _uploaddata() async {
    setState(() {
      transid = random.nextInt(100000);
    });
    FormData formData = FormData.fromMap({
      "user_uid": uid,
      "t_id": transid,
      "app_no": _applicantcontroller.text,
      "form_name": widget.title,
      "state_name": _selectedstate,
      "vehicle_no": _vehcontroller.text,
      "border_name": _bordercontroller.text
    });

    print(formData.fields.toString());
    setState(() => _loading = true);
    final response =
        await Dio().post('https://rto24x7.com/api/form_new/', data: formData);
    setState(() => _loading = false);
    response.statusCode == 200
        ? _admindailog()
        : _scaffoldKey.currentState
            .showSnackBar(new SnackBar(content: Text('Something went wrong')));
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
