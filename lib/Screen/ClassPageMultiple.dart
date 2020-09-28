import 'package:flutter/material.dart';
import 'package:rto/Screen/MultivehServicePage.dart';

class ClassPageMultiple extends StatefulWidget {
  
  final List<String> multiform;
  final List<String> multiformprice;

  const ClassPageMultiple({Key key, this.multiform, this.multiformprice}) : super(key: key);
  @override
  _ClassPageMultipleState createState() => _ClassPageMultipleState();
}

class _ClassPageMultipleState extends State<ClassPageMultiple> {
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
        title: Text('Licence'),
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
                        builder: (context) => MultiVehSrevicePage(
                              multiform: widget.multiform,
                              multiformprice: widget.multiformprice,
                              count: tmpArray.length.toString(),
                            )));
               
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
