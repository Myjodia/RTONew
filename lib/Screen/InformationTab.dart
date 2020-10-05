import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rto/ApiProvider/Apifile.dart';
import 'package:rto/Model/ServiceInfo.dart';

class InformationTab extends StatefulWidget {
  @override
  _InformationTabState createState() => _InformationTabState();
}

class _InformationTabState extends State<InformationTab> {
  Future _serviceinfo;

  @override
  void initState() {
    _serviceinfo = ApiFile().getinforesult();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Information')),
        body: FutureBuilder<ServiceInfo>(
            future: _serviceinfo,
            builder:
                (BuildContext context, AsyncSnapshot<ServiceInfo> snapshot) {
              if (snapshot.connectionState == ConnectionState.none)
                return Container();
              else if (snapshot.connectionState == ConnectionState.waiting)
                return Container(
                    height: MediaQuery.of(context).size.height - 100,
                    child: Center(
                        child: CupertinoActivityIndicator(
                      radius: 30,
                    )));

              return snapshot.data.service == null
                  ? Container(
                      height: MediaQuery.of(context).size.height - 100,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                              snapshot.data.error.contains('SocketException:')
                                  ? 'No Internet Connection found!'
                                  : 'Something Went Wrong! try again',
                              style: TextStyle(color: Colors.black)),
                          RaisedButton(
                              color: Theme.of(context).primaryColor,
                              child: Text(
                                'Retry',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                setState(() {
                                  _serviceinfo = ApiFile().getinforesult();
                                });
                              })
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data.service.length,
                      itemBuilder: (context, position) {
                        Service service = snapshot.data.service[position];
                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 8.0, top: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 2,
                                    color: Theme.of(context).primaryColor)),
                            child: ExpansionTile(
                              expandedCrossAxisAlignment:
                                  CrossAxisAlignment.start,
                              title: Text(
                                service.serviceName,
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    ' Answer ',
                                    style: TextStyle(
                                        backgroundColor: Colors.blue,
                                        color: Colors.white),
                                  ),
                                ),
                                ListTile(
                                  title: Text(service.serviceInfo),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
            }));
  }
}
