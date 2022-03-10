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

bool is_search = false;
String search_s = "";

class teach_learn extends StatelessWidget {
  final _contoller = TextEditingController();
  List x = new List();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<t_Provider>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          leading:
              provider.prev.isEmpty ?
                 IconButton(
              icon: Icon(Icons.exit_to_app,
              color: Colors.blue.shade900,),
              onPressed: (){
                // LogOut
                print('로그아웃!');
                signOut();
                final provider = Provider.of<t_Provider>(context, listen: false);
                provider.Page = 0;
              }
          ) : IconButton(
                onPressed: (){
                  List<int> arr = provider.prev;
                  int goback = arr.last;
                  arr.removeLast();
                  provider.Prev = arr;
                  provider.Page = goback;
                },
                icon: Icon(Icons.arrow_back_outlined,
                color: Colors.blue.shade900,),
              ),
          title:Text('Sports' , textAlign: TextAlign.center,
              style: TextStyle(
                  color : Colors.blue.shade900,
              ),
          ),

          actions: <Widget>[
            provider.prev.isEmpty ?
              IconButton(
              icon: Icon(
                Icons.arrow_forward,
                color: Colors.blue.shade900,

              ),
              onPressed: (){
                final provider = Provider.of<t_Provider>(context, listen: false);
                provider.Page = 3;
              },
            ) :  Container(),
          ],

        ),
        body:
        Column(
          children: [
            ListTile(
              title: showTextFormField(false, "search",_contoller),

              trailing:
              ElevatedButton(
                child: Text("search",
                style: TextStyle(
                  color: Colors.black,
                ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),

                ),
                onPressed: (){

                  if(_contoller.text == ""){
                    is_search = false;
                  } else{
                    is_search = true;
                  }
                  print(_contoller.text);
                  search_s = _contoller.text;
                  final provider = Provider.of<t_Provider>(context, listen: false);
                  provider.call_notity();
                },
              ),
            ),

            Expanded(
              child: StreamBuilder(
                stream: is_search ? FirebaseFirestore.instance.collection('sports')
                    .where('name' , isGreaterThanOrEqualTo : search_s )
                    .where('name' ,  isLessThan: search_s + '~')
                    .snapshots()
                    : FirebaseFirestore.instance.collection('sports').snapshots(),
                builder: (context, snapshot) {

                  if (snapshot.hasData) {
                    List<dynamic> all = snapshot.data.docs.map((doc) =>
                        doc.data()).toList();

                    return ListView.builder(
                      itemCount: all.length,
                      padding: EdgeInsets.fromLTRB(2, 10, 2, 10),
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(

                          leading :
                          AspectRatio(
                            aspectRatio: 15 / 10,
                            child: Image.network(
                              all[index]["link"],
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                          title: Text(
                            all[index]["name"],
                          ),
                          subtitle: Text(
                            all[index]["information"].toString(),
                          ),

                          trailing:
                          Column(
                            //mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Colors.white),
                                  ),
                                  onPressed: () async {
                                    print(snapshot.data.docs[index].id);
                                    List<String> teaches;
                                    await FirebaseFirestore.instance.collection('user')
                                        .doc(FirebaseAuth.instance.currentUser.uid)
                                        .get()
                                        .then((DocumentSnapshot documentSnapshot){
                                          teaches = List.from(documentSnapshot['teach']);
                                        }
                                        );
                                    teaches.add(snapshot.data.docs[index].id);
                                    await FirebaseFirestore.instance.collection('user')
                                        .doc(FirebaseAuth.instance.currentUser.uid)
                                        .update(
                                        {
                                          'teach' : teaches,
                                        }
                                    );
                                  },
                                  child: Text(
                                      "teach",
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                                width: 10,
                              ),
                              Flexible(
                                child: ElevatedButton(
                                  child: Text("learn",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  ),

                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Colors.black),

                                  ),
                                  onPressed: () async {
                                    print(snapshot.data.docs[index].id);
                                    List<String> learns;
                                    await FirebaseFirestore.instance.collection('user')
                                        .doc(FirebaseAuth.instance.currentUser.uid)
                                        .get()
                                        .then((DocumentSnapshot documentSnapshot){
                                      learns = List.from(documentSnapshot['learn']);
                                    }
                                    );
                                    learns.add(snapshot.data.docs[index].id);
                                    await FirebaseFirestore.instance.collection('user')
                                        .doc(FirebaseAuth.instance.currentUser.uid)
                                        .update(
                                        {
                                          'learn' : learns,
                                        }
                                    );
                                  },
                                ),
                              ),

                            ],
                          ),
                        );
                      },
                    );

                  } else {
                    return Container();
                  }
                },
              ),

            ),

          ],
        ),
      );

  }

}


Widget showTextFormField(bool obsc, String name, TextEditingController _controller)
{
  return Container(
      padding: EdgeInsets.fromLTRB(20.0,0.0,20.0,0.0),
      child: Container(
          padding: EdgeInsets.fromLTRB(10.0,0.0,10.0,0.0),
          decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.black
              ),
              borderRadius: BorderRadius.circular(5.0)
          ),
          child: TextFormField(
            onEditingComplete: () {
              is_search = false;
            },
            maxLines: obsc == true ? 1 : null,
            validator: (value)
            {
              if (value == null || value.isEmpty) {
                return ' ${name}';
              }
              return null;
            },


            controller: _controller,
            obscureText: obsc,

            cursorColor: Colors.blue,

            decoration: InputDecoration(
              filled: false,
              hintText:
              ' ${name}',
              border: InputBorder.none,
            ),
          )
      )
  );
}

void signOut() async {
  FirebaseAuth.instance.signOut();
}