import 'dart:ffi';

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

import 'google_map.dart';
import 'chat_room.dart';



class teacher_for_you extends StatelessWidget {

  bool func1(List<dynamic> all , int index , int loc){
    List x = all[index]["teach"].toList();
    List y = all[loc]["learn"].toList();
    if(x.isEmpty){
      return false;
    }
    else if(y.isEmpty){
      return false;
    }
    else if (x.any((item) => y.contains(item)) ) {
      return true;
    } else {
      return false;
    }
  }



  @override
  Widget build(BuildContext context) {
    //print("yea");
    return Scaffold(
      appBar: AppBar(
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
            provider.Page = 2;
          },
        ),
        title: Center(
            child: Text('Teachers for you!!' ,
                style: TextStyle(
                  color: Colors.blue.shade900,
                ),
                textAlign: TextAlign.center)
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.arrow_forward,
              color: Colors.blue.shade900,
            ), onPressed: () {
            final provider = Provider.of<t_Provider>(context, listen: false);
            provider.Page = 4;
          },
          ),
        ],

      ),


      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('user').snapshots(),
        builder: (context, snapshot) {
          int loc;
          int i =0;
          if (snapshot.hasData) {
            List<dynamic> all = snapshot.data.docs.map((doc) =>
                doc.data()).toList();
            all.forEach((element) {
              if(all[i]["uid"].contains(FirebaseAuth.instance.currentUser.uid)){
                loc = i;
                print(loc);

              }
              i++;
            });

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
                      provider.Name = all[index]["name"];
                      provider.Uid  = all[index]["uid"];
                      List<int> arr = [];
                      arr.add(provider.page);
                      provider.Prev = arr;
                      provider.Page = 11;
                    },

                    child:

                    //all[index]["teach"].any(all[loc]["learn"]) == true ?
                    func1(all,index,loc) == true ?
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                            child : AspectRatio(
                              aspectRatio: 8 / 5,
                              child: Image.network(
                                all[index]["profile"],
                                fit: BoxFit.fill,
                              ),
                            )
                        ),

                        SizedBox(width: 10),
                        Flexible(
                            child: Column(
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
                                    overflow: TextOverflow.ellipsis),
                              ],
                            )
                        ),
                      ],
                    ) : Container(),
                  ),

                );

              },

            );

          } else {
            return Container();
          }
        },
      ),
    );

  }

}

class student_for_you extends StatelessWidget {

  bool func(List<dynamic> all , int index , int loc){
    List x = all[loc]["teach"].toList();
    List y = all[index]["learn"].toList();
    if(x.isEmpty){
      return false;
    }
    else if(y.isEmpty){
      return false;
    }
    else if (y.any((item) => x.contains(item))) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
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
            provider.Page = 3;
          },
        ),
        title: Center(
            child: Text('Students for you!!' ,
                style: TextStyle(
                  color: Colors.blue.shade900,
                ),
                textAlign: TextAlign.center)
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.arrow_forward,
              color: Colors.blue.shade900,
            ), onPressed: () {
            final provider = Provider.of<t_Provider>(context, listen: false);
            provider.Page = 5;
          },
          ),
        ],

      ),


      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('user').snapshots(),
        builder: (context, snapshot) {
          int loc;
          int i = 0;
          if (snapshot.hasData) {
            List<dynamic> all = snapshot.data.docs.map((doc) =>
                doc.data()).toList();
            all.forEach((element) {
              if(all[i]["uid"].contains(FirebaseAuth.instance.currentUser.uid)){
                loc = i;
                print(loc);

              }
              i++;
            });

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
                      provider.Name = all[index]["name"];
                      provider.Uid  = all[index]["uid"];
                      List<int> arr;
                      arr = provider.prev;
                      arr.add(provider.page);
                      provider.Prev = arr;
                      provider.Page = 11;

                    },

                    child:
                    func(all,index,loc) == true?
                    //all[index]["teach"].contains("6UwOAmGaP66Jr9YVpgi5") == true ?
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(

                          child: AspectRatio(
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

                              ],
                            )
                        ),
                      ],
                    ) : Container(),
                  ),
                );
              },
            );


          } else {
            return Container();
          }
        },
      ),
    );

  }

}