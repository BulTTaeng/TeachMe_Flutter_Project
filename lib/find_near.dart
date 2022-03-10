

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as gec;

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:teach_me/homepage.dart';
import 'package:teach_me/provider.dart';
import 'dart:math';

import 'google_map.dart';
import 'chat_room.dart';
import 'provider.dart' as p;

Future find_latitude() async {
  await FirebaseFirestore.instance.collection('user').doc(FirebaseAuth.instance.currentUser.uid).get()
      .then((DocumentSnapshot documentSnapshot){
    documentSnapshot['latitude'];
  }

  );
}
class Find_near extends StatefulWidget{
  _Find_near createState() => _Find_near();
}

class _Find_near extends State<Find_near>{
  double lati = null;
  double longi = null;

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  @override
  initState(){

    FirebaseFirestore.instance.collection('user').doc(FirebaseAuth.instance.currentUser.uid).get()
        .then((DocumentSnapshot documentSnapshot){
          lati = documentSnapshot['latitude'];
          longi = documentSnapshot['longitude'];
          //t_Provider pro = new t_Provider();
          //pro.call_notity();
          setState(() {
          });
        });
  }
  @override
  Widget build(BuildContext context) {
    if(lati == null || longi == null){
      return buildLoading();
    }
    else{
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          leading:
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.blue.shade900,
              semanticLabel: 'Go back',
            ),
            onPressed: () {
              final provider = Provider.of<t_Provider>(context, listen: false);
              List<int> arr = provider.prev;
              int goback = arr.last;
              arr.removeLast();
              provider.Prev = arr;
              provider.Page = goback;
            },
          ),
          title:Text('Near your location' , textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blue.shade900,
              ),
          ),


        ),

        body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('user').snapshots(),
            builder: (context, snapshot){
              if(snapshot.hasData){
                List<dynamic> all = snapshot.data.docs.map((doc) =>
                    doc.data()).toList();

                //Stream documentStream = FirebaseFirestore.instance.collection('user').doc(FirebaseAuth.instance.currentUser.uid).snapshots();

                return ListView.builder(
                  itemCount: all.length,
                  padding: EdgeInsets.fromLTRB(2, 10, 2, 10),
                  itemBuilder: (BuildContext context, int index) {

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),

                      clipBehavior: Clip.antiAlias,
                      child : InkWell(
                        onTap:(){
                          final provider = Provider.of<t_Provider>(context , listen: false);
                          List<int> arr;
                          arr = provider.prev;
                          arr.add(provider.page);
                          provider.Uid = all[index]['uid'];
                          provider.Name = all[index]['name'];
                          provider.Prev = arr;
                          provider.Page = 11;

                        },

                        child:
                        calculateDistance(lati, longi, all[index]['latitude'], all[index]['longitude']) < 3
                            && all[index]['uid'] != FirebaseAuth.instance.currentUser.uid ?

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child:
                              AspectRatio(
                                aspectRatio: 8 / 5,
                                child: Image.network(
                                  all[index]["profile"],
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            SizedBox(width: 10,),
                            Flexible(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    Text(
                                      all[index]["name"],
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),

                                    Text(
                                        all[index]['information'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis
                                    ),
                                    Text(
                                        calculateDistance(lati, longi, all[index]['latitude'], all[index]['longitude']).toStringAsFixed(2)
                                            + "Km",
                                    )

                                  ],
                                )
                            ),
                          ],
                        ) : Container(),
                      ),
                    );
                  },
                );
              }else{
                return buildLoading();
              }
            }
        ),
      );
    }

  }

}

Widget buildLoading() => Stack(
  fit: StackFit.expand,
  children: [
    //CustomPaint(painter: BackgroundPainter()),
    Center(child: CircularProgressIndicator()),
  ],
);