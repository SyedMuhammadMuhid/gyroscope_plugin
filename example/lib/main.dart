import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:gyroscope/gyroscope.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
    Gyroscope.subscribe;
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await  Gyroscope.platformVersion?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }
  GyroscopeData _gyroscope = GyroscopeData();
  bool _subscription = true;
  List<String> _button = ["Un Subscribe", "Subscribe"];
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      theme: ThemeData.light().copyWith(
      primaryColor: Color(0xffF15422),
      brightness: Brightness.light,
      backgroundColor: const Color(0xff736F6D),
      dividerColor: Colors.white54,
      colorScheme: ColorScheme.light(primary: Color(0xffF15422))),
      home: Scaffold(
        backgroundColor:const Color(0xff736F6D),
        appBar: AppBar(
          title: const Text('Gyroscope Plugin Example App',style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              new Container(
                child:Column(children:[
                  StreamBuilder(
                      stream:Gyroscope.gyroscope,
                      builder: (BuildContext context, AsyncSnapshot<GyroscopeData> snapshot){
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: (){
                                  if(_subscription){
                                    Gyroscope.unSubscribe;
                                      _subscription = !_subscription;
                                  }
                                  else if(_subscription == false){
                                    Gyroscope.subscribe;
                                    setState(() {
                                      _subscription = !_subscription;
                                    });
                                  }
                                },
                                child: Container(
                                  height: 30,
                                  width: 130,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color(0xffF15422),
                                  ),
                                  child: Center(child: Text(_subscription?_button[0]:_button[1], style: TextStyle(color:Colors.white, fontSize: 20,fontWeight: FontWeight.bold ),)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 30),
                              child: Column(
                                children: [
                                  Text("Azimuth",style: TextStyle(color:Colors.white, fontSize: 30,fontWeight: FontWeight.bold ),),
                                  Text((double.parse((snapshot.data != null ? snapshot.data!.azimuth : 0.0).toStringAsFixed(2))).toString(),style: TextStyle(color:Colors.white, fontSize: 25,fontWeight: FontWeight.bold )),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0, bottom: 20),
                                    child: Center(
                                      child: new RotationTransition(
                                        turns: new AlwaysStoppedAnimation(snapshot.data != null ? snapshot.data!.azimuth : 0.0),
                                        child: Image.asset("assets/images/compass_image.png"),
                                      ),
                                    ),
                                  ),
                                  Text("Pitch",style: TextStyle(color:Colors.white, fontSize: 30,fontWeight: FontWeight.bold )),
                                  Text((double.parse((snapshot.data != null ? snapshot.data!.pitch : 0.0).toStringAsFixed(2))).toString(),style: TextStyle(color:Colors.white, fontSize: 25,fontWeight: FontWeight.bold )),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0, bottom: 20),
                                    child: Center(
                                      child: new RotationTransition(
                                        turns: new AlwaysStoppedAnimation(snapshot.data != null ? snapshot.data!.pitch : 0.0),
                                        child: Image.asset("assets/images/compass_image.png"),
                                      ),
                                    ),
                                  ),
                                  Text("Roll",style: TextStyle(color:Colors.white, fontSize: 30,fontWeight: FontWeight.bold )),
                                  Text((double.parse((snapshot.data != null ? snapshot.data!.roll : 0.0).toStringAsFixed(2))).toString(),style: TextStyle(color:Colors.white, fontSize: 25,fontWeight: FontWeight.bold )),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0, bottom: 20),
                                    child: Center(
                                      child: new RotationTransition(
                                        turns: new AlwaysStoppedAnimation(snapshot.data != null ? snapshot.data!.roll : 0.0),
                                        child: Image.asset("assets/images/compass_image.png"),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      })
                ])
              ),
            ],
          ),
        ),
      ),
    );
  }
}
