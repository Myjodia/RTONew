import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:rto/ApiProvider/Apifile.dart';
import 'package:rto/Model/ServiceCount.dart';
import 'package:rto/Screen/ClassPage.dart';
import 'package:rto/Screen/ClassPageMultiple.dart';
import 'package:rto/Screen/Login.dart';
import 'package:rto/Screen/MultivehServicePage.dart';
import 'package:rto/Screen/SingleFormPage.dart';
import 'package:rto/Screen/SingleVehicleServicePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String uid, name, mobile, emailid, password;
  SharedPreferences prefs;
  Future _count;
  String pending, inprogress, complete;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _userdetails() async {
    prefs = await SharedPreferences.getInstance();

    setState(() {
      uid = prefs.getString('uid');
      name = prefs.getString('name');
      mobile = prefs.getString('mobile');
      emailid = prefs.getString('email');
      password = prefs.getString('password');

      print(uid + name + mobile + emailid + password);

      FormData formData = FormData.fromMap({
        "user_uid": uid,
      });
      _count = ApiFile().servicecount(formData);
    });
  }

  Map<String, bool> values = {
    'MDL Noc': false,
    'Renewal Licence': false,
    'Change of Date of Birth': false,
    'Endorsment Permanent Licence': false,
    'International MDL': false,
    'Duplicate of MDL': false,
    'Change of Biomatrics': false,
    'Change of Address': false,
    'Surrender of MDL': false,
    'Change of Name': false,
    'Endorsment of Hazardous': false,
    'Replace of MDL': false,
    'MDL Extract': false,
  };

  List<String> tmpArray = new List();
  List<String> datatoshowArray = new List();

  @override
  void initState() {
    _userdetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'RTO24x7',
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child:
              Image.asset("assets/images/rto_image.png", width: 50, height: 50),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              color: Colors.black,
              icon: Icon(Icons.power_settings_new),
              iconSize: 30,
              onPressed: () {
                _logout();
              },
            ),
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            _invitenowcard(),
            FutureBuilder<ServiceCount>(
                future: _count,
                builder: (BuildContext context,
                    AsyncSnapshot<ServiceCount> snapshot) {
                  if (snapshot.connectionState == ConnectionState.none)
                    return _totalrecordcard('--', '--', '--');
                  else if (snapshot.connectionState == ConnectionState.waiting)
                    return _totalrecordcard('--', '--', '--');

                  return _totalrecordcard(snapshot.data.pending,
                      snapshot.data.inprogress, snapshot.data.complete);
                }),
            _singleselectionlicensecard(),
            _multipleselectionlicensecard(),
            _singleselectionvehiclescard(),
            _upcominglicensecard()
          ],
        ),
      ),
    );
  }

  _logout() {
    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
              scale: a1.value,
              child: Opacity(
                  opacity: a1.value,
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    title: Text('Logout'),
                    content: Text("Are you sure to logout??"),
                    actions: <Widget>[
                      FlatButton(
                        child: const Text('No'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      FlatButton(
                        child: const Text('Yes'),
                        onPressed: () {
                          prefs.remove('login');
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext ctx) => Login()));
                          print('Logout');
                        },
                      )
                    ],
                  )));
        },
        pageBuilder: (BuildContext context, Animation animation,
            Animation secondaryAnimation) {},
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context);
  }

  _invitenowcard() {
    return Padding(
      padding:
          const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 5.0, top: 5.0),
      child: Card(
        elevation: 2,
        shadowColor: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Image.asset("assets/images/running_person.png",
                  width: 100, height: 100),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                          children: <TextSpan>[
                            TextSpan(text: 'Click here to invite for\n'),
                            TextSpan(
                              text: 'RTO24x7',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 13),
                            )
                          ])),
                  FlatButton(
                    onPressed: () {
                      LaunchReview.launch(
                          androidAppId: "com.example.rto",
                          iOSAppId: "585027354");
                    },
                    child: Text(
                      'Invite now',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    shape: new RoundedRectangleBorder(
                        side: BorderSide(),
                        borderRadius: BorderRadius.circular(20)),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _totalrecordcard(String pending, String inprogress, String complete) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Card(
        elevation: 2,
        shadowColor: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          style: TextStyle(
                              color: Colors.red[900],
                              fontSize: 15,
                              fontWeight: FontWeight.w400),
                          children: <TextSpan>[
                            TextSpan(text: 'Pending\n'),
                            TextSpan(
                              text: pending == null ? '--' : pending,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[900],
                                  fontSize: 13),
                            )
                          ])),
                  Container(
                    height: 30,
                    child: VerticalDivider(
                      width: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w400),
                          children: <TextSpan>[
                            TextSpan(text: 'In Progress\n'),
                            TextSpan(
                              text: inprogress == null ? '--' : inprogress,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 13),
                            )
                          ])),
                ],
              ),
              Divider(color: Theme.of(context).primaryColor),
              RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.w400),
                      children: <TextSpan>[
                        TextSpan(text: 'Complete : '),
                        TextSpan(
                          text: complete == null ? '--' : complete,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 13),
                        )
                      ])),
            ],
          ),
        ),
      ),
    );
  }

  _singleselectionlicensecard() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 5.0),
      child: Card(
        elevation: 2,
        shadowColor: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('License Services'),
              Divider(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _licenseclassitem(
                      'assets/images/learning_licence.png',
                      'Learning Licence',
                      'Upload Medical Doc',
                      '',
                      true,
                      false,
                      true,
                      true,
                      true),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _licenseclassitem(
                      'assets/images/permanent_licence.png',
                      'Permananent Licence',
                      'Learning License',
                      '',
                      true,
                      false,
                      false,
                      false,
                      true),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _licenseclassitem(
                      'assets/images/endosment_permenent_licence.png',
                      'Endorsment Learning Licence',
                      'Upload Motor License',
                      'Upload Medical License',
                      true,
                      true,
                      false,
                      false,
                      true),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _licenseserviceitems(
                      'assets/images/new_conductor_licen.png',
                      'New Conductor Licence',
                      'Upload Medical Doc',
                      'Upload Domicile',
                      'Upload Police Report',
                      '',
                      true,
                      true,
                      true,
                      true,
                      true,
                      false,
                      true,
                      false),
                ],
              ),
              Divider(color: Colors.red[100]),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _licenseserviceitems(
                      'assets/images/learning_retest.jpg',
                      'Learning Licence Retest',
                      '',
                      '',
                      '',
                      'Application no',
                      false,
                      false,
                      false,
                      false,
                      false,
                      true,
                      true,
                      true),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _licenseserviceitems(
                      'assets/images/new_conductor_licen.png',
                      'Renewal of Conductor Licence',
                      'Upload Medical Doc',
                      'Upload Conductor license',
                      '',
                      '',
                      true,
                      true,
                      false,
                      false,
                      false,
                      false,
                      true,
                      true),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _licenseserviceitems(
                      'assets/images/change_of_address.png',
                      'Change of Address of Conductor Licence',
                      'Upload Conductor license',
                      '',
                      '',
                      '',
                      true,
                      false,
                      false,
                      true,
                      false,
                      false,
                      true,
                      false),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _licenseserviceitems(
                      'assets/images/transfer_of_ownership.png',
                      'change of Name of conductor licence',
                      'Upload Gazette/Paper cutout',
                      'Upload Conductor license',
                      '',
                      '',
                      true,
                      true,
                      false,
                      false,
                      false,
                      false,
                      true,
                      false),
                ],
              ),
              Divider(color: Colors.red[100]),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _licenseserviceitems(
                      'assets/images/permanent_licence.png',
                      'Permenent Licence Retest',
                      '',
                      '',
                      '',
                      'Application no',
                      false,
                      false,
                      false,
                      false,
                      false,
                      true,
                      true,
                      true),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _licenseserviceitems(
                      'assets/images/new_conductor_licen.png',
                      'Duplicate of Conductor Licence',
                      '',
                      '',
                      'Upload Police Report',
                      'MDL No.',
                      false,
                      false,
                      true,
                      false,
                      false,
                      true,
                      true,
                      true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _singleselectionvehiclescard() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 5.0),
      child: Card(
        elevation: 2,
        shadowColor: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Vehicle Services'),
              Divider(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _vehicleserviceitems(
                      'assets/images/tax.png',
                      'Tax',
                      '',
                      '',
                      '',
                      'Vehicle No',
                      '',
                      false,
                      false,
                      false,
                      false,
                      false,
                      true,
                      false,
                      true,
                      false,
                      true,
                      false,
                      false),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _vehicleserviceitems(
                      'assets/images/green_tax.png',
                      'Green Tax',
                      '',
                      '',
                      '',
                      'Vehicle No',
                      '',
                      false,
                      false,
                      false,
                      false,
                      false,
                      true,
                      false,
                      true,
                      false,
                      false,
                      false,
                      false),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _vehicleserviceitems(
                      'assets/images/insurance.png',
                      'Insurance',
                      'Upload RC Book',
                      'Upload Previous Insurance',
                      '',
                      '',
                      '',
                      true,
                      true,
                      false,
                      false,
                      false,
                      false,
                      false,
                      true,
                      false,
                      false,
                      true,
                      false),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _vehicleserviceitems(
                      'assets/images/mdl_noc.png',
                      'Dublicate RC',
                      '',
                      '',
                      'Upload Police Report',
                      'Vehicle No',
                      'Chasis No',
                      true,
                      false,
                      false,
                      false,
                      false,
                      true,
                      true,
                      true,
                      false,
                      false,
                      false,
                      true),
                ],
              ),
              Divider(color: Colors.red[100]),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _vehicleserviceitems(
                      'assets/images/transfer_of_ownership.png',
                      'Transfer of Ownership',
                      '',
                      '',
                      '',
                      'Vehicle No',
                      'Chasis No',
                      false,
                      false,
                      false,
                      true,
                      false,
                      true,
                      true,
                      true,
                      false,
                      false,
                      false,
                      true),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _vehicleserviceitems(
                      'assets/images/mdl_noc.png',
                      'Noc',
                      '',
                      '',
                      '',
                      'Vehicle No',
                      'Chasis No',
                      false,
                      false,
                      false,
                      true,
                      false,
                      true,
                      true,
                      true,
                      false,
                      false,
                      false,
                      false),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _vehicleserviceitems(
                      'assets/images/fitness.png',
                      'Dublicate Fitness',
                      '',
                      '',
                      '',
                      'Vehicle No',
                      'Chasis No',
                      false,
                      false,
                      false,
                      false,
                      false,
                      true,
                      true,
                      true,
                      false,
                      false,
                      false,
                      false),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _licenseitem('assets/images/tax.png', 'Check Post Tax')
                ],
              ),
              Divider(color: Colors.red[100]),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _vehicleserviceitems(
                      'assets/images/renewal_of_registration.png',
                      'Renewal of Registration',
                      '',
                      '',
                      '',
                      'Vehicle No',
                      'Chasis No',
                      false,
                      false,
                      false,
                      false,
                      false,
                      true,
                      true,
                      true,
                      false,
                      false,
                      false,
                      true),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _vehicleserviceitems(
                      'assets/images/alteration_of_vehicle.png',
                      'Alteration of Vehicle',
                      '',
                      '',
                      '',
                      'Vehicle No',
                      'Chasis No',
                      false,
                      false,
                      false,
                      false,
                      false,
                      true,
                      true,
                      true,
                      false,
                      false,
                      false,
                      true),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _vehicleserviceitems(
                      'assets/images/change_of_address.png',
                      'Change of Adresss',
                      '',
                      '',
                      '',
                      'Vehicle No',
                      'Chasis No',
                      false,
                      false,
                      false,
                      true,
                      false,
                      true,
                      true,
                      true,
                      false,
                      false,
                      false,
                      true),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _vehicleserviceitems(
                      'assets/images/mdl_noc.png',
                      'RC Particular',
                      '',
                      '',
                      '',
                      'Vehicle No',
                      'Chasis No',
                      false,
                      false,
                      false,
                      false,
                      false,
                      true,
                      true,
                      true,
                      false,
                      false,
                      false,
                      false),
                ],
              ),
              Divider(color: Colors.red[100]),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _vehicleserviceitems(
                      'assets/images/addition_of_hypo.png',
                      'Addition of Financier',
                      'Upload Form34',
                      '',
                      '',
                      'Vehicle No',
                      'Chasis No',
                      true,
                      false,
                      false,
                      false,
                      false,
                      true,
                      true,
                      true,
                      false,
                      false,
                      false,
                      true),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _vehicleserviceitems(
                      'assets/images/removal_hypo.png',
                      'Removal of Financier',
                      'Upload Form35',
                      '',
                      '',
                      'Vehicle No',
                      'Chasis No',
                      true,
                      false,
                      false,
                      false,
                      false,
                      true,
                      true,
                      true,
                      false,
                      false,
                      false,
                      false),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _vehicleserviceitems(
                      'assets/images/transfer_of_ownership.png',
                      'Transfer of Ownership & Removal of Financier',
                      'Upload Form35',
                      '',
                      '',
                      'Vehicle No',
                      'Chasis No',
                      true,
                      false,
                      false,
                      true,
                      false,
                      true,
                      true,
                      true,
                      false,
                      false,
                      false,
                      true),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _vehicleserviceitems(
                      'assets/images/addition_of_hypo.png',
                      'Transfer of ownership & Financier Termination & Financier Addition',
                      'Upload Form34',
                      'Upload Form35',
                      '',
                      'Vehicle No',
                      'Chasis No',
                      true,
                      true,
                      false,
                      true,
                      false,
                      true,
                      true,
                      true,
                      false,
                      false,
                      false,
                      true),
                ],
              ),
              Divider(color: Colors.red[100]),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _vehicleserviceitems(
                      'assets/images/mdl_noc.png',
                      'Dublicate RC & Financier Termination',
                      'Upload Form35',
                      '',
                      'Upload Police Report',
                      'Vehicle No',
                      'Chasis No',
                      true,
                      true,
                      false,
                      false,
                      false,
                      true,
                      true,
                      true,
                      false,
                      false,
                      false,
                      true),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _vehicleserviceitems(
                      'assets/images/mdl_noc.png',
                      'Dublicate RC & Financier Addition',
                      'Upload Form35',
                      '',
                      'Upload Police Report',
                      'Vehicle No',
                      'Chasis No',
                      true,
                      true,
                      false,
                      false,
                      false,
                      true,
                      true,
                      true,
                      false,
                      false,
                      false,
                      true),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _vehicleserviceitems(
                      'assets/images/mdl_noc.png',
                      'Dublicate RC & Financier Addition & Financier Termination',
                      'Upload Form34',
                      'Upload Form35',
                      'Upload Police Report',
                      'Vehicle No',
                      'Chasis No',
                      true,
                      true,
                      true,
                      false,
                      false,
                      true,
                      true,
                      true,
                      false,
                      false,
                      false,
                      true),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _vehicleserviceitems(
                      'assets/images/transfer_of_ownership.png',
                      'Transfer Ownership & Addition of Financier',
                      'Upload Form34',
                      '',
                      '',
                      'Vehicle No',
                      'Chasis No',
                      true,
                      false,
                      false,
                      true,
                      false,
                      true,
                      true,
                      true,
                      false,
                      false,
                      false,
                      true),
                ],
              ),
              Divider(color: Colors.red[100]),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _vehicleserviceitems(
                      'assets/images/fitness.png',
                      'Fitness of Vehicle',
                      '',
                      '',
                      '',
                      'Vehicle No',
                      'Chasis No',
                      false,
                      false,
                      false,
                      false,
                      false,
                      true,
                      true,
                      true,
                      false,
                      false,
                      false,
                      true),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _vehicleserviceitems(
                      'assets/images/national_permit_fee_payment.png',
                      'Permit Fee',
                      '',
                      '',
                      '',
                      'Vehicle No',
                      'Password',
                      false,
                      false,
                      false,
                      false,
                      false,
                      true,
                      true,
                      true,
                      false,
                      false,
                      false,
                      false),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _vehicleserviceitems(
                      'assets/images/national_permit_fee_payment.png',
                      'National Permit Payment',
                      '',
                      '',
                      '',
                      'Vehicle No',
                      'Chasis no',
                      false,
                      false,
                      false,
                      false,
                      false,
                      true,
                      true,
                      true,
                      false,
                      false,
                      false,
                      false),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _vehicleserviceitems(
                      'assets/images/surrender.png',
                      'Withdraw App',
                      '',
                      '',
                      '',
                      'Vehicle No',
                      'Chasis no',
                      false,
                      false,
                      false,
                      false,
                      false,
                      true,
                      true,
                      true,
                      false,
                      false,
                      false,
                      false),
                ],
              ),
              Divider(color: Colors.red[100]),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _vehicleserviceitems(
                      'assets/images/memobill.png',
                      'Pay Memo Challan',
                      '',
                      '',
                      '',
                      'Vehicle No',
                      '',
                      false,
                      false,
                      false,
                      false,
                      false,
                      true,
                      false,
                      true,
                      false,
                      false,
                      false,
                      false),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _vehicleserviceitems(
                      'assets/images/transfer_of_ownership.png',
                      'Transfer of Ownership Financier Continuaiton',
                      '',
                      '',
                      '',
                      'Vehicle No',
                      'Chasis No',
                      false,
                      false,
                      false,
                      true,
                      false,
                      true,
                      true,
                      true,
                      false,
                      false,
                      false,
                      true),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _vehicleserviceitems(
                      'assets/images/removal_hypo.png',
                      'Noc & Removal of Financier',
                      'Upload Form34',
                      '',
                      '',
                      'Vehicle No',
                      'Chasis No',
                      true,
                      false,
                      false,
                      true,
                      false,
                      true,
                      true,
                      true,
                      false,
                      false,
                      false,
                      false),
                  Container(
                      height: 70,
                      child: VerticalDivider(color: Colors.red[100])),
                  _vehicleserviceitems(
                      'assets/images/mdl_noc.png',
                      'New Registration Tax & Registration Fee',
                      '',
                      '',
                      '',
                      'Application No',
                      'Password',
                      false,
                      false,
                      false,
                      false,
                      false,
                      true,
                      true,
                      true,
                      false,
                      false,
                      false,
                      false),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _multipleselectionlicensecard() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 5.0),
      child: Card(
        elevation: 2,
        shadowColor: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Multiple Selection License Services'),
              Divider(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _multipleselectionlicenseitem(
                      'assets/images/mdl_noc.png', 'MDL Noc'),
                  Container(
                      height: 60,
                      child: VerticalDivider(color: Colors.red[100])),
                  _multipleselectionlicenseitem(
                      'assets/images/renewal_lic.png', 'Renewal Licence'),
                  Container(
                      height: 60,
                      child: VerticalDivider(color: Colors.red[100])),
                  _multipleselectionlicenseitem(
                      'assets/images/calendar.png', 'Change of Date of Birth'),
                ],
              ),
              Divider(color: Colors.red[100]),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _multipleselectionlicenseitem(
                      'assets/images/endosment_permenent_licence.png',
                      'Endorsment Permanent Licence'),
                  Container(
                      height: 60,
                      child: VerticalDivider(color: Colors.red[100])),
                  _multipleselectionlicenseitem(
                      'assets/images/international_driving_licence.png',
                      'International MDL'),
                  Container(
                      height: 60,
                      child: VerticalDivider(color: Colors.red[100])),
                  _multipleselectionlicenseitem(
                      'assets/images/renewal_lic.png', 'Duplicate of MDL'),
                ],
              ),
              Divider(color: Colors.red[100]),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _multipleselectionlicenseitem(
                      'assets/images/change_of_biomatrics.png',
                      'Change of Biomatrics'),
                  Container(
                      height: 60,
                      child: VerticalDivider(color: Colors.red[100])),
                  _multipleselectionlicenseitem(
                      'assets/images/change_of_address.png',
                      'Change of Address'),
                  Container(
                      height: 60,
                      child: VerticalDivider(color: Colors.red[100])),
                  _multipleselectionlicenseitem(
                      'assets/images/surrender.png', 'Surrender of MDL')
                ],
              ),
              Divider(color: Colors.red[100]),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _multipleselectionlicenseitem(
                      'assets/images/alteration_of_vehicle.png',
                      'Change of Name'),
                  Container(
                      height: 60,
                      child: VerticalDivider(color: Colors.red[100])),
                  _multipleselectionlicenseitem(
                      'assets/images/endosment_of_hazardus.jpg',
                      'Endorsment of Hazardous'),
                  Container(
                      height: 60,
                      child: VerticalDivider(color: Colors.red[100])),
                  _multipleselectionlicenseitem(
                      'assets/images/mdl_noc.png', 'Replace of MDL'),
                  Container(
                      height: 60,
                      child: VerticalDivider(color: Colors.red[100])),
                  _multipleselectionlicenseitem(
                      'assets/images/mdl_extract.png', 'MDL Extract')
                ],
              ),
              // GestureDetector(
              //   onTap: (){
              //     print('Selection done');
              //   },
              //   child: Padding(
              //     padding: const EdgeInsets.all(8.0),
              //     child: Center(
              //       child: Container(
              //         decoration: BoxDecoration(
              //             border: Border.all(), shape: BoxShape.circle),
              //         child: Padding(
              //           padding: const EdgeInsets.all(8.0),
              //           child: Icon(Icons.arrow_forward_ios,
              //               color: Theme.of(context).primaryColor),
              //         ),
              //       ),
              //     ),
              //   ),
              // )
              Center(
                child: FloatingActionButton.extended(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  label: Row(
                    children: <Widget>[
                      Text('Next',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16)),
                      Icon(Icons.arrow_forward_ios,
                          color: Theme.of(context).primaryColor, size: 14),
                    ],
                  ),
                  splashColor: Theme.of(context).primaryColor,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      side: BorderSide()),
                  onPressed: () {
                    tmpArray.clear();
                    datatoshowArray.clear();
                    print(values);
                    values.forEach((key, value) {
                      if (value == true) {
                        tmpArray.add(key);
                      } else {
                        tmpArray.remove(key);
                      }
                    });
                    if (tmpArray.isEmpty) {
                      _showtoast('Please Select any doc to proceed');
                    } else {
                      print("TempArray" + tmpArray.toString());
                      if (tmpArray.contains('MDL Noc')) {
                        datatoshowArray.add('motorlicence');
                        datatoshowArray.add('identification');
                      }
                      if (tmpArray.contains('Renewal Licence')) {
                        datatoshowArray.add('datepicker');
                        datatoshowArray.add('motorlicence');
                        datatoshowArray.add('medicaldoc');
                      }
                      if (tmpArray.contains('Change of Biomatrics')) {
                        datatoshowArray.add('motorlicence');
                      }
                      if (tmpArray.contains('Change of Address')) {
                        datatoshowArray.add('motorlicence');
                        datatoshowArray.add('identification');
                      }
                      if (tmpArray.contains('Surrender of MDL')) {
                        datatoshowArray.add('motorlicence');
                      }
                      if (tmpArray.contains('Change of Date of Birth')) {
                        datatoshowArray.add('motorlicence');
                        datatoshowArray.add('gazetedoc');
                        datatoshowArray.add('bpdoc');
                      }
                      if (tmpArray.contains('Endorsment Permanent Licence')) {
                        datatoshowArray.add('motorlicence');
                        datatoshowArray.add('medicaldoc');
                        datatoshowArray.add('learndoc');
                      }
                      if (tmpArray.contains('International MDL')) {
                        datatoshowArray.add('motorlicence');
                        datatoshowArray.add('medicaldoc');
                        datatoshowArray.add('passport');
                        datatoshowArray.add('visa');
                      }
                      if (tmpArray.contains('Duplicate of MDL')) {
                        datatoshowArray.add('birthdatepicker');
                        datatoshowArray.add('policereport');
                        datatoshowArray.add('textbox');
                      }
                      if (tmpArray.contains('Change of Name')) {
                        datatoshowArray.add('motorlicence');
                        datatoshowArray.add('gazetedoc');
                      }
                      if (tmpArray.contains('Endorsment of Hazardous')) {
                        datatoshowArray.add('motorlicence');
                        datatoshowArray.add('hazard');
                      }
                      if (tmpArray.contains('Replace of MDL')) {
                        datatoshowArray.add('motorlicence');
                      }
                      if (tmpArray.contains('MDL Extract')) {
                        datatoshowArray.add('birthdatepicker');
                        datatoshowArray.add('textbox');
                      }
                      if (tmpArray.contains('Endorsment Permanent Licence')) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ClassPageMultiple(
                                      multiform: datatoshowArray,
                                      multiformprice: tmpArray,
                                    )));
                      } else if (tmpArray.contains('Surrender of MDL')) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ClassPageMultiple(
                                      multiform: datatoshowArray,
                                      multiformprice: tmpArray,
                                    )));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MultiVehSrevicePage(
                                      multiform: datatoshowArray,
                                      multiformprice: tmpArray,
                                      count: '',
                                    )));
                      }
                    }
                    print("dataArray" + datatoshowArray.toString());
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _upcominglicensecard() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 5.0),
      child: Card(
        elevation: 2,
        shadowColor: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Coming Soon', style: TextStyle(fontSize: 20)),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('1) Car Driver'), Text('2) Truck Driver')],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('3) Garage'), Text('4) Automobile parts')],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('5) Tyre sells and puncture'),
                  Text('6) Car tourism')
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('7) Car or Truck washing center'),
                  Text('8) Truck Guide'),
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('9) Truck goods transportation company'),
                  Text('10) Car couting')
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('11) PUC'), Text('12) Worker Supply')],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('13) Battery sells \nservices'),
                  Text('14) crane or breck\n down services')
                ],
              ),
              Divider(),
            ],
          ),
        ),
      ),
    );
  }

  _licenseclassitem(String icons, String name, String img1, String img2,
      bool image1, bool image2, bool iddocs, bool bpdoc, bool applicantcard) {
    return Flexible(
      fit: FlexFit.tight,
      child: GestureDetector(
        onTap: () {
          print(name);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ClassPage(
                      title: name,
                      image1: image1,
                      image2: image2,
                      img1: img1,
                      img2: img2,
                      applicantcard: applicantcard,
                      bpdocs: bpdoc,
                      iddocs: iddocs)));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              icons,
              width: 40,
              height: 40,
            ),
            Text(
              name,
              style: TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  _licenseserviceitems(
      String icons,
      String name,
      String img1,
      String img2,
      String img3,
      String textname,
      bool image1,
      bool image2,
      bool image3,
      bool iddocs,
      bool bpdoc,
      bool textboxcard,
      bool applicantcard,
      bool datecard) {
    return Flexible(
      fit: FlexFit.tight,
      child: GestureDetector(
        onTap: () {
          print(name);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SingleFormPage(
                        bpdocs: bpdoc,
                        iddocs: iddocs,
                        image1: image1,
                        image2: image2,
                        image3: image3,
                        img2: img2,
                        img3: img3,
                        title: name,
                        img1: img1,
                        textname: textname,
                        textbox: textboxcard,
                        applicantcard: applicantcard,
                        datepicker: datecard,
                      )));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              icons,
              width: 40,
              height: 40,
            ),
            Text(
              name,
              style: TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  _vehicleserviceitems(
      String icons,
      String name,
      String img1,
      String img2,
      String img3,
      String textname1,
      String textname2,
      bool image1,
      bool image2,
      bool image3,
      bool iddocs,
      bool bpdoc,
      bool textboxcard,
      bool textboxcard1,
      bool applicantcard,
      bool datecard,
      bool taxservice,
      bool insservice,
      bool vehicletype) {
    return Flexible(
      fit: FlexFit.tight,
      child: GestureDetector(
        onTap: () {
          print(name);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SingleVehicleServicePage(
                        bpdocs: bpdoc,
                        iddocs: iddocs,
                        image1: image1,
                        image2: image2,
                        image3: image3,
                        img2: img2,
                        img3: img3,
                        title: name,
                        img1: img1,
                        textname1: textname1,
                        textname2: textname2,
                        insservice: insservice,
                        taxservice: taxservice,
                        vehicletype: vehicletype,
                        textbox: textboxcard,
                        textbox1: textboxcard1,
                        applicantcard: applicantcard,
                        datepicker: datecard,
                      )));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              icons,
              width: 40,
              height: 40,
            ),
            Text(
              name,
              style: TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  _licenseitem(String icons, String name) {
    return Flexible(
      fit: FlexFit.tight,
      child: GestureDetector(
        onTap: () {
          print(name);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              icons,
              width: 40,
              height: 40,
            ),
            Text(
              name,
              style: TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  _multipleselectionlicenseitem(String icons, String name) {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Checkbox(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: values[name],
                  onChanged: (bool newvalue) {
                    setState(() {
                      values[name] = newvalue;
                    });
                  }),
              Image.asset(
                icons,
                width: 30,
                height: 30,
              ),
            ],
          ),
          Text(
            name,
            style: TextStyle(fontSize: 11),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  _showtoast(String msg) {
    return _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: Text(msg)));
  }
}
