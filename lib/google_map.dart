
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as gec;

import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:teach_me/homepage.dart';
import 'provider.dart';


class Google_map extends StatefulWidget {
  LocationData currentLocation;
  gec.Placemark place;
  @override
  _Google_map createState() => _Google_map();

  Google_map({Key key, @required this.currentLocation, @required this.place });
}

class _Google_map extends State<Google_map> {

  final Map<String, Marker> _markers = {};

  getLocatio() async {

    var location = new Location();

    try {
      widget.currentLocation = await location.getLocation();

      var placemarks = await gec.placemarkFromCoordinates(
          widget.currentLocation.latitude,
          widget.currentLocation.longitude
      );

      widget.place = placemarks[0];

    } on Exception {
      //currentLocation = null;
      print("fail!");
    }
  }

  @override
  Widget build(BuildContext context) {

    final _productName = TextEditingController(text : '${widget.place.locality} , ${widget.place.postalCode}, ${widget.place.country}' );

    print(widget.currentLocation.latitude);
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
                    await getLocatio();
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
                    target: LatLng(widget.currentLocation.latitude, widget.currentLocation.longitude),
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


