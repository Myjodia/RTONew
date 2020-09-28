import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Login.dart';

class ChangePassword extends StatefulWidget {
  final String uid;

  const ChangePassword({Key key, this.uid}) : super(key: key);
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final oldpasswdtxt = new TextEditingController();
  final newpasswdtxt = new TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Set New Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
              child: TextField(
                controller: oldpasswdtxt,
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 15),
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                obscureText: true,
                decoration: InputDecoration(
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.black26, width: 0.5)),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor)),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  prefixIconConstraints:
                      BoxConstraints(minHeight: 16, minWidth: 16),
                  prefixIcon: Padding(
                    padding:
                        const EdgeInsetsDirectional.only(start: 8.0, end: 5.0),
                    child: Icon(Icons.lock_open),
                  ),
                  labelText: 'Enter old password',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
              child: TextField(
                controller: newpasswdtxt,
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 15),
                obscureText: true,
                decoration: InputDecoration(
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.black26, width: 0.5)),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor)),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  prefixIconConstraints:
                      BoxConstraints(minHeight: 16, minWidth: 16),
                  prefixIcon: Padding(
                    padding:
                        const EdgeInsetsDirectional.only(start: 8.0, end: 5.0),
                    child: Icon(Icons.lock_open),
                  ),
                  labelText: 'Enter new password',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: _isloading
                    ? CupertinoActivityIndicator(
                        radius: 20,
                      )
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        child: FlatButton(
                          color: Theme.of(context).primaryColor,
                          onPressed: () async {
                            if (oldpasswdtxt.text.length < 1) {
                              _scaffoldKey.currentState.showSnackBar(
                                  new SnackBar(
                                      content:
                                          Text("Please enter old password")));
                            } else if (newpasswdtxt.text.length < 1) {
                              _scaffoldKey.currentState.showSnackBar(
                                  new SnackBar(
                                      content:
                                          Text("Please enter new password")));
                            } else {
                              FormData formData = FormData.fromMap({
                                "old_password": oldpasswdtxt.text,
                                "text_password": newpasswdtxt.text,
                                "user_uid": widget.uid,
                              });

                              print(formData.fields);

                              setState(() => _isloading = true);
                              final response = await Dio().post(
                                  'https://rto24x7.com/api/change_password/',
                                  data: formData);
                              setState(() => _isloading = false);

                              if (!response.statusMessage.contains('OK')) {
                                _scaffoldKey.currentState.showSnackBar(new SnackBar(
                                    content: Text(
                                        'Something went wrong check network and try Again')));
                              } else {
                                Map<String, dynamic> user =
                                    jsonDecode(response.data);
                                var results = user['result'];
                                print(results);
                                if (results.contains('Fail')) {
                                  _scaffoldKey.currentState.showSnackBar(
                                      new SnackBar(
                                          content: Text(
                                              'old password is incorrect ! Try Again..')));
                                } else {
                                  Navigator.of(context)
                                      .popUntil((route) => route.isFirst);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext ctx) =>
                                              Login()));
                                }
                              }
                            }
                          },
                          shape: new RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            'SUBMIT',
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
            )
          ],
        ),
      ),
    );
  }
}
