import 'package:flutter/material.dart';
import 'package:rto/Screen/SingleFormClass.dart';

class ClassPage extends StatefulWidget {
  final String title, img1, img2;
  final bool image1, image2, iddocs, bpdocs, textbox, applicantcard;

  const ClassPage(
      {Key key,
      this.title,
      this.img1,
      this.img2,
      this.image1,
      this.image2,
      this.iddocs,
      this.bpdocs,
      this.textbox,
      this.applicantcard})
      : super(key: key);

  @override
  _ClassPageState createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, bool> values = {
    'M.C W/o Gear': false,
    'M.C With Gear': false,
    'LMV-NT-Car': false,
    'LMV-3 WNT': false,
    'LMV-Tractor': false,
    'LMV-Transport': false,
    'LMV-3 WTR': false,
    'Transport': false,
    'Inv Carriage': false,
    'Road Roller': false,
    'LMV-Tractor Trl': false,
    'Others': false,
    'M.C W/o GTR': false,
    'M.C With GTR': false,
    'LMV-Private': false,
    'TRV-PSV Bus': false,
    'TRV-Private Bus': false,
    'OTH-Loadr/xcvtr': false,
    'OTH-Cranes': false,
    'OTH-Fork Lift': false,
    'OTH-ConstEqpmnt': false,
    'OTH-Boring rigs': false,
    'INV-Carriage-2': false,
    'INV-Carriage-3': false,
  };

  var tmpArray = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 2,
          shadowColor: Theme.of(context).primaryColor,
          child: GridView.count(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              childAspectRatio: 4,
              crossAxisCount: 2,
              children: values.keys.map((String key) {
                return CheckboxListTile(      
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(key, style: TextStyle(fontSize: 13)),
                    value: values[key],
                    onChanged: (bool value) {
                      setState(() {
                        values[key] = value;
                        if(values[key]==true){
                          tmpArray.add(values);
                        }
                        else{
                          tmpArray.remove(values);
                        }
                      });
                    });
              }).toList()),
        ),
      ),
      persistentFooterButtons: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          child: FlatButton(
            color: Theme.of(context).primaryColor,
            onPressed: () {
              print(tmpArray.length);
              if (tmpArray.isEmpty) {
                _scaffoldKey.currentState.showSnackBar(new SnackBar(
                    content: Text("Please select any services first!!")));
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SingleFormClass(
                              title: widget.title,
                              image1: widget.image1,
                              image2: widget.image2,
                              img1: widget.img1,
                              img2: widget.img2,
                              bpdocs: widget.bpdocs,
                              iddocs: widget.iddocs,
                              applicantcard: widget.applicantcard,
                              count: tmpArray.length.toString(),

                            )));
                print(widget.title +
                    '\t' +
                    widget.image1.toString() +
                    '\t' +
                    widget.image2.toString() +
                    '\t' +
                    widget.img1 +
                    '\t' +
                    widget.img2 +
                    '\t' +
                    widget.bpdocs.toString() +
                    '\t' +
                    widget.iddocs.toString());
              }
            },
            shape: new RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            child: Text(
              'NEXT',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
