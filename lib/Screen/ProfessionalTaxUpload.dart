import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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
  String taxirate;
  String goodsrate;
  String busrate;
  bool taxivalue = false;
  bool goodstruckvalue = false;
  bool busvalue = false;

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
                    hintText: 'Customer No.'),
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
                          });
                        }),
                  ),
                  Expanded(
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
                          if (text == 1) {
                            taxirate = '1000';
                          } else if (text > 1) {
                            taxirate = '2500';
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
                                    color: Theme.of(context).primaryColor)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
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
                          });
                        }),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextField(
                        controller: _truckcontroller,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly
                        ],
                        onChanged: (text) {
                          if (text.contains('1')) {
                            goodsrate = '1500';
                          } else {
                            goodsrate = '2500';
                          }
                        },
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 15),
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
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
                          });
                        }),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextField(
                        controller: _buscontroller,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly
                        ],
                        onChanged: (text) {
                          if (text.contains('1')) {
                            busrate = '1500';
                          } else {
                            busrate = '2500';
                          }
                        },
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 15),
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
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
              _showtoast('Please enter customer no');
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
                tmpArray.add('Taxi' + '_' + taxirate);
              }
              if (goodstruckvalue) {
                tmpArray.add('Goods truck' + '_' + goodsrate);
              }
              if (busvalue) {
                tmpArray.add('Bus' + '_' +busrate);
              }
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
