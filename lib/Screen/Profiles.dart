import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rto/Screen/ChangePassword.dart';
import 'package:rto/Screen/Contactus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profiles extends StatefulWidget {
  @override
  _ProfilesState createState() => _ProfilesState();
}

class _ProfilesState extends State<Profiles> {
  String uid, name, mobile, emailid, state, password;
  SharedPreferences prefs;
  final feedtext = new TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _userdetails() async {
    prefs = await SharedPreferences.getInstance();

    setState(() {
      uid = prefs.getString('uid');
      name = prefs.getString('name');
      mobile = prefs.getString('mobile');
      emailid = prefs.getString('email');
      state = prefs.getString('state');
      password = prefs.getString('password');

      print(uid + name + mobile + emailid + state + password);
    });
  }

  @override
  void initState() {
    _userdetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              color: Theme.of(context).primaryColor,
              height: 140,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Icon(Icons.person, color: Colors.white),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Profile',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    Image.asset("assets/images/pickup_car.png",
                        width: 100, height: 100),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  _profiledata(Icons.person, name == null ? 'Name' : name),
                  _profiledata(
                      Icons.phone_iphone, mobile == null ? 'Mobile' : mobile),
                  _profiledata(
                      Icons.email, emailid == null ? 'Email_id' : emailid),
                  _contactdata(Icons.call, 'Contact Us'),
                  _feedbkdata(Icons.feedback, 'Feedback'),
                  _profiledata(
                      Icons.location_city, state == null ? 'State' : state),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: FlatButton(
                        color: Theme.of(context).primaryColor,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ChangePassword(uid: uid)));
                        },
                        shape: new RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          'CHANGE PASSWORD',
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
            )
          ],
        ),
      ),
    );
  }

  _profiledata(IconData data, String text) {
    return new Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: <Widget>[
          CircleAvatar(
              radius: 15,
              child: Icon(
                data,
                size: 18,
              )),
          SizedBox(
            width: 10,
          ),
          Text(text)
        ],
      ),
    );
  }

  _contactdata(IconData data, String text) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Contactus()));
      },
      child: new Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                    radius: 15,
                    child: Icon(
                      data,
                      size: 18,
                    )),
                SizedBox(width: 10),
                Text(text),
              ],
            ),
            Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor)
          ],
        ),
      ),
    );
  }

  _feedbkdata(IconData data, String text) {
    return GestureDetector(
      onTap: () => _showfeeddialog(),
      child: new Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                    radius: 15,
                    child: Icon(
                      data,
                      size: 18,
                    )),
                SizedBox(width: 10),
                Text(text),
              ],
            ),
            Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor)
          ],
        ),
      ),
    );
  }

  _showfeeddialog() {
    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
              scale: a1.value,
              child: Opacity(
                opacity: a1.value,
                child: Dialog(
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
                              'Feedback',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: new Container(
                            height: 200,
                            decoration: new BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: new Border.all(
                                color: Colors.black12,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: new TextField(
                                controller: feedtext,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                decoration: new InputDecoration(
                                  hintText: 'we are happy to hear from you...',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: FlatButton(
                            color: Theme.of(context).primaryColor,
                            onPressed: () async {
                              // if (feedtext.text.length < 1) {
                              //   _scaffoldKey.currentState.showSnackBar(
                              //       new SnackBar(
                              //           content:
                              //               Text("Please enter some text")));
                              // }
                              Navigator.of(context).pop();
                              _scaffoldKey.currentState.showSnackBar(
                                  new SnackBar(
                                      content: Text(
                                          "Thanks For your valuable feedback")));
                              FormData formData = FormData.fromMap({
                                "message": feedtext.text,
                                "user_uid": uid,
                              });
                              final response = await Dio().post(
                                  'https://rto24x7.com/api/feedback/',
                                  data: formData);
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
                ),
              ));
        },
        pageBuilder: (BuildContext context, Animation animation,
            Animation secondaryAnimation) {},
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context);
  }
}
