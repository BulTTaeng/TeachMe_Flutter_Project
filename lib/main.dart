
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as gec;

import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:teach_me/homepage.dart';
import 'provider.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as gec;

import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:teach_me/homepage.dart';
import 'provider.dart';

LocationData currentLocation;
gec.Placemark place;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();





  _getLocation() async {

    var location = new Location();

    try {
      currentLocation = await location.getLocation();

      print('locationLatitude: ${currentLocation.latitude}');
      print('locationLongitude: ${currentLocation.longitude}');

      var placemarks = await gec.placemarkFromCoordinates(
          currentLocation.latitude,
          currentLocation.longitude
      );

      place = placemarks[0];
    } on Exception {
      currentLocation = null;
      print("fail!@@@@@@@@@@@@@@@@@@@@@");
    }
  }

  await _getLocation();

  //t_Provider().currentLocation = currentLocation;
  //print(t_Provider().curr);

  runApp(
      ChangeNotifierProvider(
        create: (context) {
          //final provider = Provider.of<t_Provider>(context, listen: false);
          //provider.curr = currentLocation;
          //provider.pla = place;
          //print(provider.curr);
          t_Provider();
        },

        builder: (context, _) => MyApp(),
      )
  );
  //runApp(teach_learn());
  //runApp(MyApp1(currentLocation: currentLocation, place: place));
  //runApp(Chat(name: "Kim",y_uid: "123"));

}

class MyApp extends StatelessWidget {
  //static final String title = 'Google SignIn';

  @override
  Widget build(BuildContext context) => MaterialApp(

    debugShowCheckedModeBanner: false,
    //title: title,


    theme: ThemeData(primarySwatch: Colors.lightBlue),
    home: HomePage(),
  );
}



class Google extends StatefulWidget {

  @override
  _Google createState() => _Google();


}

class _Google extends State<Google> {

  final Map<String, Marker> _markers = {};

  getLocation() async {

    var location = new Location();

    try {
      currentLocation = await location.getLocation();

      var placemarks = await gec.placemarkFromCoordinates(
          currentLocation.latitude,
          currentLocation.longitude
      );

      place = placemarks[0];

    } on Exception {
      currentLocation = null;
      print("fail!");
    }
  }

  @override
  Widget build(BuildContext context) {

    final _productName = TextEditingController(text : '${place.locality} , ${place.postalCode}, ${place.country}' );
    final provider = Provider.of<t_Provider>(context, listen: false);
    provider.Region = _productName.text;
    provider.Latitude = currentLocation.latitude;
    provider.Longitude = currentLocation.longitude;
    print(currentLocation.latitude);
    return Scaffold(
        appBar: AppBar(
            title: const Text('Google Office Locations'),
            backgroundColor: Colors.green[700],
            leading:
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                semanticLabel: 'Go back',
              ),
              onPressed: () {
                final provider = Provider.of<t_Provider>(context, listen: false);
                provider.Page = 1;
              },
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.add_location_outlined,
                  semanticLabel: 'Go back',
                ),
                onPressed: () async {
                  await getLocation();
                },
              ),
            ]
        ),
        body: Column(
          children: [
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Your address here';
                }
                return null;
              },

              controller: _productName,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Your address!',
              ),
              style: TextStyle(
                fontSize: 20,
              ),
            ),

            Expanded(
              flex: 10,
              child: GoogleMap(
                //onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(currentLocation.latitude,currentLocation.longitude),
                  zoom: 15,
                ),
                myLocationEnabled: true,
                markers: _markers.values.toSet(),
              ),
            ),

          ],
        )

    );

  }
}















