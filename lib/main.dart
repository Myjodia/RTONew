import 'package:flutter/material.dart';
import 'package:rto/Screen/Homepage.dart';
import 'package:rto/Screen/Login.dart';
import 'package:rto/Screen/Profiles.dart';
import 'package:rto/Screen/Reports.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  print(prefs.getBool('login'));
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: Colors.red,
        primaryColorDark: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: prefs.getBool('login') == null ? Login() : DashBoard()));
}

class DashBoard extends StatefulWidget {
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    Homepage(),
    Reports(),
    Profiles()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            title: Text('Reports'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('Profiles'),
          ),
        ],
        currentIndex: _selectedIndex,
        elevation: 20,
        onTap: _onItemTapped,
      ),
    );
  }
}
