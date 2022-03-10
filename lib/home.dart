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

class Home extends StatelessWidget{

  Future<Column> find_techers(List<String> teacher) async {
    try{
      await FirebaseFirestore.instance.collection("user").where('uid' , arrayContainsAny : teacher)
          .get().then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          return Column(
            children: [
              Image.network(
                  doc['profile']
              ),
              Text(
                doc["name"],
              ),
              Text(
                doc["information"].toString(),
              ),

            ],
          );
        });
      });
    }
    catch(e){
      print("exception");
    }

  }


  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('user');
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: floatingbar(context),
      bottomNavigationBar: bottomBar(context),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
              Icons.arrow_back,
              semanticLabel: 'Go back',
              color: Colors.blue.shade900,
          ),
          onPressed: () {
            final provider = Provider.of<t_Provider>(context, listen: false);
            //provider.Prev = provider.page;
            provider.Page = 4;
          },
        ),
        title: Center(
          child: Text("Home", style: TextStyle(color: Colors.blue.shade900),),
        ),
        actions: <Widget>[
          IconButton(
              onPressed: (){
                final provider = Provider.of<t_Provider>(context, listen: false);
                List<int> arr;
                arr = provider.prev;
                arr.add(provider.page);
                provider.Prev = arr;
                provider.Page = 10;
              },
              icon: Icon(
                Icons.directions_run_outlined,
                color : Colors.blue.shade900,
              ),
          )

        ],

      ),
      body: FutureBuilder<DocumentSnapshot> (
          future:users.doc(FirebaseAuth.instance.currentUser.uid).get(),
          builder:(context, snapshot){
            if(snapshot.hasData){
              Map<String, dynamic> data = snapshot.data.data();
              List<dynamic> teach = data["teach_person"].toList();
              List<dynamic> learn = data["learn_person"].toList();
              //List<String> teach = ["TTnaOaE5o2YCSfuw6gxAToXdfNn2"];
              //print(teach.);
              return  Container(
                  padding: EdgeInsets.fromLTRB(15.0, 10, 15.0, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding: EdgeInsets.fromLTRB(0.0, 3, 0.0, 7),
                          child: Text(
                            "My Account",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          )
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: (){
                              final provider = Provider.of<t_Provider>(context, listen: false);
                              List<int> arr;
                              arr = provider.prev;
                              arr.add(provider.page);
                              provider.Prev = arr;
                              provider.Page = 8;
                              //print("ontap");
                            },
                            child:
                            Container(
                              padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child: CircleAvatar(
                                    backgroundImage: NetworkImage(data['profile'])
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                  height : 70.0,
                                  decoration: ShapeDecoration(
                                      color: Colors.white,
                                      shape: Border.all(
                                        color: Colors.lightBlue,
                                        width: 1.0,
                                      )),


                                  padding: EdgeInsets.fromLTRB(5.0, 1.0, 5.0, 1.0),
                                  child : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(data["name"],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold)),
                                      Text(data["information"],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis)
                                    ],
                                  )
                              )
                          )
                        ],
                      ),



                      Divider(
                        height: 6,
                        color : Colors.black,
                      ),
                      Container(
                          padding: EdgeInsets.fromLTRB(0.0, 3, 0.0, 7),
                          child: Text(
                            "My Teachers",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          )
                      ),
                      Flexible(
                        child: teach.isEmpty ?
                        Container() :
                        StreamBuilder(

                            stream: FirebaseFirestore.instance.collection("user")
                                .where("uid" , whereIn : teach)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if(snapshot.hasData){

                                List<dynamic> all1 = snapshot.data.docs.map((doc) =>
                                    doc.data()).toList();
                                return ListView.builder(
                                    itemCount: all1.length,
                                    padding: EdgeInsets.fromLTRB(0.0, 3, 0.0, 0),
                                    itemBuilder: (BuildContext context, int index) {
                                      return Container(
                                          padding: EdgeInsets.fromLTRB(0.0, 3, 0.0, 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                                                child: SizedBox(
                                                  width: 100,
                                                  height: 100,
                                                  child: CircleAvatar(
                                                      backgroundImage: NetworkImage(all1[index]['profile'])
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                  child: Container(
                                                      height : 70.0,
                                                      decoration: ShapeDecoration(
                                                          color: Colors.white,
                                                          shape: Border.all(
                                                            color: Colors.lightBlue,
                                                            width: 1.0,
                                                          )),


                                                      padding: EdgeInsets.fromLTRB(5.0, 1.0, 5.0, 1.0),
                                                      child : Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(all1[index]["name"],
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold)),
                                                          Text(all1[index]["information"],
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis)
                                                        ],
                                                      )
                                                  )
                                              )
                                            ],
                                          )
                                      );
                                    }

                                );
                              }else{
                                return buildLoading();
                              }
                            }
                        ),
                      ),


                      Divider(
                        height: 6,
                        color : Colors.black,
                      ),
                      Container(
                          padding: EdgeInsets.fromLTRB(0.0, 3, 0.0, 7),
                          child: Text(
                            "My Students",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          )
                      ),
                      Flexible(
                        child: learn.isEmpty ? Container() :
                        StreamBuilder(

                            stream: FirebaseFirestore.instance.collection("user")
                                .where("uid" , whereIn : learn)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if(snapshot.hasData){

                                List<dynamic> all1 = snapshot.data.docs.map((doc) =>
                                    doc.data()).toList();
                                // print(teach[0].toString());
                                //print(all1);
                                //print(snapshot);
                                return ListView.builder(
                                    itemCount: all1.length,
                                    padding: EdgeInsets.all(2.0),
                                    itemBuilder: (BuildContext context, int index) {
                                      return Container(
                                          padding: EdgeInsets.fromLTRB(0.0, 3, 0.0, 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                                                child: SizedBox(
                                                  width: 100,
                                                  height: 100,
                                                  child: CircleAvatar(
                                                      backgroundImage: NetworkImage(all1[index]['profile'])
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                  child: Container(
                                                      height : 70.0,
                                                      decoration: ShapeDecoration(
                                                          color: Colors.white,
                                                          shape: Border.all(
                                                            color: Colors.lightBlue,
                                                            width: 1.0,
                                                          )),


                                                      padding: EdgeInsets.fromLTRB(5.0, 1.0, 5.0, 1.0),
                                                      child : Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(all1[index]["name"],
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold)),
                                                          Text(all1[index]["information"],
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis)
                                                        ],
                                                      )
                                                  )
                                              )
                                            ],
                                          )
                                      );
                                    }

                                );
                              }else{
                                return buildLoading();
                              }
                            }
                        ),
                      ),

                    ],
                  )
              );

            }else{
              return buildLoading();
            }
          }

      ),


    );

  }

  Widget bottomBar(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      //color of the BottomAppBar
      color: Colors.white,
      child: Container(
        margin: EdgeInsets.only(left: 12.0, right: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(

              //update the bottom app bar view each time an item is clicked
              onPressed: () {
                final provider = Provider.of<t_Provider>(context, listen: false);

                provider.Page = 5;
                print('0');
              },
              iconSize: 27.0,
              icon: Icon(
                  Icons.home,
                  //darken the icon if it is selected or else give it a different color
                  color: Colors.blue.shade900
              ),
            ),
            IconButton(
              onPressed: () {
                final provider = Provider.of<t_Provider>(context, listen: false);
                List<int> arr;
                arr = provider.prev;
                arr.add(provider.page);
                provider.Prev = arr;
                provider.Page = 2;
                print('1');
              },
              iconSize: 27.0,
              icon: Icon(
                  Icons.search,
                  color: Colors.blue.shade900
              ),
            ),
            //to leave space in between the bottom app bar items and below the FAB
            SizedBox(
              width: 50.0,
            ),
            IconButton(
              onPressed: () {
                final provider = Provider.of<t_Provider>(context, listen: false);
                List<int> arr;
                arr = provider.prev;
                arr.add(provider.page);
                provider.Prev = arr;
                provider.Page = 13;
                print('2');
              },
              iconSize: 27.0,
              icon: Icon(
                  Icons.textsms_outlined,
                  color: Colors.blue.shade900
              ),
            ),
            IconButton(
              onPressed: () {
                final provider = Provider.of<t_Provider>(context, listen: false);
                List<int> arr;
                arr = provider.prev;
                arr.add(provider.page);
                provider.Prev = arr;
                provider.Page = 8;

                //print('3');
              },
              iconSize: 27.0,
              icon: Icon(
                  Icons.person_outline,
                  color: Colors.blue.shade900
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget floatingbar(BuildContext context)
  {
    return FloatingActionButton(
      backgroundColor: Colors.pinkAccent,
      onPressed: () {
        print('floating action btn');
        final provider = Provider.of<t_Provider>(context, listen: false);
        print('near_find');
        List<int> arr;
        arr = provider.prev;
        arr.add(provider.page);
        provider.Prev = arr;
        provider.Page = 12;

      },
      tooltip: "Centre FAB",
      elevation: 4.0,
      child: Container(
        margin: EdgeInsets.all(15.0),
        child: Icon(Icons.add),
      ),
    );
  }

}

Widget buildLoading() => Stack(
  fit: StackFit.expand,
  children: [
    //CustomPaint(painter: BackgroundPainter()),
    Center(child: CircularProgressIndicator()),
  ],
);