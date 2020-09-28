import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rto/ApiProvider/Apifile.dart';
import 'package:rto/Screen/Signup.dart';
import 'package:rto/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _mobController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final focus = FocusNode();
  String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Image.asset("assets/images/rto_image.png",
                    width: 160, height: 160),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Card(
                  color: Colors.white,
                  elevation: 5.0,
                  shadowColor: Theme.of(context).primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 10),
                        Text(
                          'Sign In',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 25),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _mobController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            WhitelistingTextInputFormatter.digitsOnly
                          ],
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) =>
                              FocusScope.of(context).nextFocus(),
                          cursorColor: Theme.of(context).primaryColor,
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            hintText: 'Enter mobile no.',
                            prefixIcon: Icon(Icons.phone_iphone),
                            prefixIconConstraints:
                                BoxConstraints(minHeight: 16, minWidth: 16),
                            labelText: 'Mobile',
                            labelStyle: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                        TextField(
                          controller: _passwordController,
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                          obscureText: true,
                          focusNode: focus,
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            hintText: 'Your Password',
                            prefixIconConstraints:
                                BoxConstraints(minHeight: 16, minWidth: 16),
                            prefixIcon: Icon(Icons.lock_open),
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.topRight,
                          child: FlatButton(
                            onPressed: () {},
                            child: GestureDetector(
                              onTap: _forgotdailog,
                              child: Text(
                                'Forgot Password',
                                style: TextStyle(
                                  color: Colors.black45,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: _isLoading
                              ? CupertinoActivityIndicator()
                              : Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: FlatButton(
                                    color: Theme.of(context).primaryColor,
                                    onPressed: () async {
                                      RegExp regExp = new RegExp(pattern);

                                      if (_mobController.text.length == 0) {
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
                                      } else if (_passwordController.text ==
                                              "" ||
                                          _passwordController
                                              .value.text.isEmpty) {
                                        _scaffoldKey.currentState.showSnackBar(
                                            new SnackBar(
                                                content: Text(
                                                    "Please enter password")));
                                      } else {
                                        FormData formData =
                                            new FormData.fromMap({
                                          "text_mobile": _mobController.text,
                                          "text_password":
                                              _passwordController.text,
                                        });
                                        print(formData.fields);

                                        setState(() => _isLoading = true);
                                        final useresponse = await ApiFile()
                                            .getLoginResponse(formData);
                                        setState(() => _isLoading = false);

                                        print(useresponse);

                                        if (useresponse.error != null) {
                                          _scaffoldKey.currentState
                                              .showSnackBar(new SnackBar(
                                                  duration:
                                                      Duration(seconds: 2),
                                                  content: Text(
                                                      'Network Error! try Again')));
                                        } else if (useresponse.result
                                            .contains('Success')) {
                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          prefs.setString(
                                              'uid', useresponse.uid);
                                          prefs.setString(
                                              'name', useresponse.name);
                                          prefs.setString(
                                              'mobile', useresponse.mobile);
                                          prefs.setString(
                                              'email', useresponse.email);
                                          prefs.setString(
                                              'state', useresponse.state);
                                          prefs.setString(
                                              'city', useresponse.city);
                                          prefs.setString('password',
                                              _passwordController.text);
                                          prefs.setBool("login", true);

                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      DashBoard()));
                                          print('done');
                                        } else if (useresponse.result
                                            .contains('Fail')) {
                                          _scaffoldKey.currentState
                                              .showSnackBar(new SnackBar(
                                                  content: Text(
                                                      'Credentials Failed')));
                                        }
                                      }
                                    },
                                    shape: new RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Text(
                                      'SIGN IN',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Signup())),
                          child: RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 16),
                                  children: <TextSpan>[
                                TextSpan(text: 'New user?\t'),
                                TextSpan(
                                  text: 'Sign Up',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor),
                                )
                              ])),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  _forgotdailog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 50,
                  decoration: new BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(15.0),
                          topRight: const Radius.circular(15.0))),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pop();
                          }),
                      Text(
                        'Forgot Password',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
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
                    style: TextStyle(color: Theme.of(context).primaryColor),
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor)),
                      hintText: 'Enter mobile no.',
                      prefixIcon: Icon(Icons.phone_iphone),
                      prefixIconConstraints:
                          BoxConstraints(minHeight: 16, minWidth: 16),
                      labelText: 'Mobile',
                      labelStyle:
                          TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: FlatButton(
                      color: Theme.of(context).primaryColor,
                      onPressed: () async {
                        RegExp regExp = new RegExp(pattern);
                        if (_mobController.text.length == 0) {
                          _scaffoldKey.currentState.showSnackBar(new SnackBar(
                              content: Text("Please enter mobile number")));
                        } else if (!regExp.hasMatch(_mobController.text)) {
                          _scaffoldKey.currentState.showSnackBar(new SnackBar(
                              content: Text("Please enter correct mobile no")));
                        } else {
                          Navigator.of(context).pop();
                          _scaffoldKey.currentState.showSnackBar(new SnackBar(
                              content: Text("Password sent to your registered mobile no")));
                          FormData formData = new FormData.fromMap({
                            "text_mobile": _mobController.text,
                          });
                          print(formData.fields);
                          final response = await Dio().post(
                              'https://highsofttechno.com/sms.php',
                              data: formData);
                        }
                      },
                      shape: new RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        'SUBMIT',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
