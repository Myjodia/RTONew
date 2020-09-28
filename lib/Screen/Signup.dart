import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rto/Utilties/searchable_dropdown.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _namecontroller = TextEditingController();
  final _emailcontroller = TextEditingController();
  final _mobController = TextEditingController();
  final _cityController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cnfrmpasswordController = TextEditingController();
  bool _isLoading = false;
  bool checkvalue = false;
  String selectedValue = '';
  String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
  final List<String> items = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jammu & Kashmir',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Orissa',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Image.asset("assets/images/rto_image.png",
                      width: 160, height: 160),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _namecontroller,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 15),
                    decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: Padding(
                        padding: const EdgeInsetsDirectional.only(
                            start: 8.0, end: 5.0),
                        child: Icon(Icons.perm_identity),
                      ),
                      prefixIconConstraints:
                          BoxConstraints(minHeight: 16, minWidth: 16),
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black26, width: 0.5)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor)),
                      labelText: 'Name',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _emailcontroller,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 15),
                    decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: Padding(
                        padding: const EdgeInsetsDirectional.only(
                            start: 8.0, end: 5.0),
                        child: Icon(Icons.email),
                      ),
                      prefixIconConstraints:
                          BoxConstraints(minHeight: 16, minWidth: 16),
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black26, width: 0.5)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor)),
                      labelText: 'Email',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _mobController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    cursorColor: Theme.of(context).primaryColor,
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 15),
                    decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: Padding(
                        padding: const EdgeInsetsDirectional.only(
                            start: 8.0, end: 5.0),
                        child: Icon(Icons.phone_iphone),
                      ),
                      prefixIconConstraints:
                          BoxConstraints(minHeight: 16, minWidth: 16),
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black26, width: 0.5)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor)),
                      labelText: 'Mobile',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            width: 0.5,
                            style: BorderStyle.solid,
                            color: Colors.black26),
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                    ),
                    child: SearchableDropdown.single(
                      items: items.map((state) {
                        return DropdownMenuItem(
                          child: new Text(state),
                          value: state,
                        );
                      }).toList(),
                      value: selectedValue,
                      displayClearIcon: false,
                      hint: "Select State",
                      searchHint: "Choose State",
                      onChanged: (value) {
                        setState(() {
                          selectedValue = value;
                          print(selectedValue);
                        });
                      },
                      isExpanded: true,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _cityController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 15),
                    decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: Padding(
                        padding: const EdgeInsetsDirectional.only(
                            start: 8.0, end: 5.0),
                        child: Icon(Icons.location_city),
                      ),
                      prefixIconConstraints:
                          BoxConstraints(minHeight: 16, minWidth: 16),
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black26, width: 0.5)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor)),
                      labelText: 'City',
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 8.0),
                        child: TextField(
                          controller: _passwordController,
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 15),
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) =>
                              FocusScope.of(context).nextFocus(),
                          obscureText: true,
                          decoration: InputDecoration(
                            isDense: true,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black26, width: 0.5)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                            prefixIconConstraints:
                                BoxConstraints(minHeight: 16, minWidth: 16),
                            prefixIcon: Padding(
                              padding: const EdgeInsetsDirectional.only(
                                  start: 8.0, end: 5.0),
                              child: Icon(Icons.lock_open),
                            ),
                            labelText: 'Password',
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 8.0),
                        child: TextField(
                          controller: _cnfrmpasswordController,
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 15),
                          obscureText: true,
                          decoration: InputDecoration(
                            isDense: true,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black26, width: 0.5)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                            prefixIconConstraints:
                                BoxConstraints(minHeight: 16, minWidth: 16),
                            prefixIcon: Padding(
                              padding: const EdgeInsetsDirectional.only(
                                  start: 8.0, end: 5.0),
                              child: Icon(Icons.lock_open),
                            ),
                            labelText: 'Confirm Password',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Theme(
                  data: Theme.of(context).copyWith(
                    unselectedWidgetColor: Theme.of(context).primaryColor,
                  ),
                  child: CheckboxListTile(
                    title: Text(
                      'I Accept Terms & Condition, Privacy Policy.',
                      style: TextStyle(
                          color: Theme.of(context).primaryColor, fontSize: 14),
                    ),
                    value: checkvalue,
                    onChanged: (newvalue) {
                      setState(() {
                        checkvalue = newvalue;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ),
                _isLoading
                    ? CupertinoActivityIndicator()
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: FlatButton(
                            color: Theme.of(context).primaryColor,
                            onPressed: () async {
                              RegExp regExp = new RegExp(pattern);
                              if (_namecontroller.text == "") {
                                _scaffoldKey.currentState.showSnackBar(
                                    new SnackBar(
                                        content:
                                            Text("Please enter correct name")));
                              } else if (_emailcontroller.text == "") {
                                _scaffoldKey.currentState.showSnackBar(
                                    new SnackBar(
                                        content: Text(
                                            "Please enter correct email")));
                              } else if (_mobController.text.length == 0) {
                                _scaffoldKey.currentState.showSnackBar(
                                    new SnackBar(
                                        content: Text(
                                            "Please enter mobile number")));
                              } else if (!regExp
                                  .hasMatch(_mobController.text)) {
                                _scaffoldKey.currentState.showSnackBar(
                                    new SnackBar(
                                        content: Text(
                                            "Please enter correct mobile no")));
                              } else if (selectedValue == '') {
                                _scaffoldKey.currentState.showSnackBar(
                                    new SnackBar(
                                        content: Text("Please select state")));
                              } else if (_cityController.text == "") {
                                _scaffoldKey.currentState.showSnackBar(
                                    new SnackBar(
                                        content:
                                            Text("Please enter correct city")));
                              } else if (_passwordController.text == "") {
                                _scaffoldKey.currentState.showSnackBar(
                                    new SnackBar(
                                        content: Text(
                                            "Please enter correct password")));
                              } else if (_cnfrmpasswordController.text !=
                                  _passwordController.text) {
                                _scaffoldKey.currentState.showSnackBar(
                                    new SnackBar(
                                        content: Text("Password Mismatch")));
                              } else if (!checkvalue) {
                                _scaffoldKey.currentState.showSnackBar(
                                    new SnackBar(
                                        content: Text(
                                            "Select terms&condition to proceed")));
                              } else {
                                FormData formData = FormData.fromMap({
                                  "text_mobile": _mobController.text,
                                  "text_email": _emailcontroller.text,
                                  "text_name": _namecontroller.text,
                                  "text_password": _passwordController.text,
                                  "state": selectedValue,
                                  "city": _cityController.text,
                                });
                                print(formData.fields);

                                setState(() => _isLoading = true);
                                final response = await Dio().post(
                                    'https://rto24x7.com/api/otp_verify/',
                                    data: formData);
                                setState(() => _isLoading = false);

                                print(response.data);
                                Map<String, dynamic> user =
                                    jsonDecode(response.data);

                                if (response.statusCode == 404) {
                                  _scaffoldKey.currentState.showSnackBar(
                                      new SnackBar(
                                          content: Text('Network Failure')));
                                } else if (user['result'] == 'Fail') {
                                  _scaffoldKey.currentState.showSnackBar(
                                      new SnackBar(
                                          content: Text(user['status'])));
                                } else {
                                  _scaffoldKey.currentState.showSnackBar(
                                      new SnackBar(
                                          content: Text(user['result'])));
                                  Navigator.of(context).pop();
                                }
                              }
                            },
                            shape: new RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              'SIGN UP',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                letterSpacing: 2.0,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: RichText(
                      text: TextSpan(
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                          children: <TextSpan>[
                        TextSpan(text: 'Already have an Account?\t'),
                        TextSpan(
                          text: 'LOGIN',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor),
                        )
                      ])),
                ),
                SizedBox(height: 10),
              ],
            )
          ],
        ));
  }
}
