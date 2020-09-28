import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Contactus extends StatefulWidget {
  @override
  _ContactusState createState() => _ContactusState();
}

class _ContactusState extends State<Contactus> {
  final String telephoneNumber = "09822825386";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.phonelink_ring,
                  color: Theme.of(context).primaryColor),
              title: Text('Call Us'),
              subtitle: Text(telephoneNumber),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () async {
                String telephoneUrl = "tel:$telephoneNumber";
                if (await canLaunch(telephoneUrl)) {
                  await launch(telephoneUrl);
                } else {
                  throw "Can't phone that number.";
                }
              },
            ),
            ListTile(
              leading: Image.asset("assets/images/whats_icon.png",
                  color: Theme.of(context).primaryColor, width: 30, height: 30),
              title: Text('WhatsApp'),
              subtitle: Text(telephoneNumber),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                launchWhatsApp(phone: '+919822825386', message:'hii');
              },
            ),
            ListTile(
              leading: Image.asset("assets/images/email_icon.png",
                  color: Theme.of(context).primaryColor, width: 30, height: 30),
              title: Text('Email'),
              subtitle: Text('rto24x7@gmail.com'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () async {
                final Uri params = Uri(
                  scheme: 'mailto',
                  path: 'rto24x7@gmail.com',
                );
                String url = params.toString();
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  print('Could not launch $url');
                }
              },
            )
          ],
        ),
      ),
    );
  }

  void launchWhatsApp({@required String phone, @required String message}) async {
    String url() {
      if (Platform.isIOS) {
        return "whatsapp://wa.me/$phone/?text=${Uri.parse(message)}";
      } else {
        return "whatsapp://send?phone=$phone&text=${Uri.parse(message)}";
      }
    }

    if (await canLaunch(url())) {
      await launch(url());
    } else {
      throw 'Could not launch ${url()}';
    }
  }
}
