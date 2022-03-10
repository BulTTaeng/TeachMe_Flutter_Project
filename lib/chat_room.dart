import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as gec;

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:teach_me/provider.dart';

String g_uid;
String g_name;
final _controller = ScrollController();

class Chat extends StatefulWidget{
  @override
  _Chat createState() => _Chat();
  String y_uid;
  String name;
  int num;
  Chat({Key key , @required this.name, @required this.y_uid , @required this.num});
}

class _Chat extends State<Chat>{
  CollectionReference users = FirebaseFirestore.instance.collection('chatroom');

  @override
  Widget build(BuildContext context) {
    g_uid = widget.y_uid;
    g_name = widget.name;
    print("Aaaaaaaaaaaaaa");




    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.blue.shade900,
              semanticLabel: 'Go back',
            ),
            onPressed: () {
              final provider = Provider.of<t_Provider>(context , listen: false);
              //final provider = Provider.of<t_Provider>(context, listen: false);
              // Homepage로 넘어간다.
              List<int> arr;
              arr = provider.prev;
              int goback = arr.last;
              arr.removeLast();
              provider.Prev = arr;
              provider.Page = goback;
            },
          ),
          title: Center(
            child: Text(widget.name,
            style: TextStyle(
              color: Colors.blue.shade900,
            ),),
          ),

        ),
        body: Column(
          children: [
            message_info(),
            submit_Info(),
          ],
        )


    );

  }

}



Widget message_info(){
  Timer(
    Duration(seconds: 1),
        () => _controller.jumpTo(_controller.position.maxScrollExtent),
  );
  return Expanded(
    child: StreamBuilder (
        stream: FirebaseFirestore.instance.collection("chatroom")
            .doc(FirebaseAuth.instance.currentUser.uid).collection(g_uid).orderBy("time").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<dynamic> all = snapshot.data.docs.map((doc) =>
                doc.data()).toList();
            return ListView.builder(
                itemCount: all.length,
                padding: EdgeInsets.all(2.0),
                shrinkWrap: true,
                controller: _controller,
                itemBuilder: (BuildContext context , int index){
                  if((all[index]["sender"] == FirebaseAuth.instance.currentUser.uid)) {
                    return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children :[
                          Container(
                            padding: EdgeInsets.fromLTRB(10.00,5.00,10.0,5.0),

                            child : Container(
                              decoration: BoxDecoration(
                                //shape: BoxShape.circle,
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                color: Colors.orangeAccent[100],
                              ),
                              child: Container(
                                padding : EdgeInsets.all(2.0),

                                child: Text(
                                  all[index]["message"],
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ) ,

                                ),
                              ),
                            ),

                          ),

                        ]

                    );
                  } else{
                    return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children :[
                          Container(
                            padding: EdgeInsets.fromLTRB(10.00,5.00,10.0,5.0),

                            child : Container(
                              decoration: BoxDecoration(
                                //shape: BoxShape.circle,
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                color: Colors.white70,
                              ),
                              child: Container(
                                padding : EdgeInsets.all(2.0),

                                child: Text(
                                  all[index]["message"],
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ) ,

                                ),
                              ),
                            ),

                          ),
                        ]

                    );
                  }
                }
            );
          } else{
            return buildLoading();
          }
        }

    ),
  );
}

Widget submit_Info() // 메세지 전송하는 부분
{
  final _controller = TextEditingController();

  return Container
    (
      child: ListTile
        (
        title: TextField
          (
          controller: _controller,
        ),
        trailing: IconButton
          (
            icon: Icon(Icons.send),
            color: Colors.blue,
            disabledColor: Colors.grey,
            onPressed:() async {
              CollectionReference chat_room = FirebaseFirestore.instance.collection(
                  "chatroom")
                  .doc(FirebaseAuth.instance.currentUser.uid).collection(g_uid);
              CollectionReference another_chat_room = FirebaseFirestore.instance
                  .collection("chatroom")
                  .doc(g_uid).collection(FirebaseAuth.instance.currentUser.uid);
              await chat_room.add({
                'message': _controller.text,
                'sender': FirebaseAuth.instance.currentUser.uid.toString(),
                'time': FieldValue.serverTimestamp(),
              });
              await another_chat_room.add({
                'message': _controller.text,
                'sender': FirebaseAuth.instance.currentUser.uid.toString(),
                'time': FieldValue.serverTimestamp(),
              });
              _controller.clear();
              var datas1 = FirebaseFirestore.instance.collection('chatroom').doc(
                  g_uid).snapshots();
              datas1.forEach((element) async {
                if (!element.exists)
                {
                  List<String> temp = [];
                  await FirebaseFirestore.instance
                      .collection('chatroom')
                      .doc(g_uid)
                      .set({
                    'chatting': temp
                  });
                }
                else
                {
                  var dd = element.get('chatting');
                  List<String> temp = dd.cast<String>();
                  if (!temp.contains(FirebaseAuth.instance.currentUser.uid)) {
                    temp.add(FirebaseAuth.instance.currentUser.uid);
                    await FirebaseFirestore.instance
                        .collection('chatroom')
                        .doc(g_uid)
                        .update({
                      'chatting': temp
                    });
                  }
                }

                var datas2 = FirebaseFirestore.instance.collection('chatroom').doc(
                    FirebaseAuth.instance.currentUser.uid).snapshots();
                datas2.forEach((element) async {
                  if (!element.exists)
                  {
                    List<String> temp = [];
                    await FirebaseFirestore.instance
                        .collection('chatroom')
                        .doc(FirebaseAuth.instance.currentUser.uid)
                        .set({
                      'chatting': temp
                    });
                  }
                  else
                  {
                    var dd = element.get('chatting');
                    List<String> temp = dd.cast<String>();

                    if (!temp.contains(g_uid)) {
                      temp.add(g_uid);
                      await FirebaseFirestore.instance
                          .collection('chatroom')
                          .doc(FirebaseAuth.instance.currentUser.uid)
                          .update({
                        'chatting': temp
                      });
                    }
                  }
                });
              });
            }
        ),
      )
  );
}

Widget buildLoading() => Stack(
  fit: StackFit.expand,
  children: [
    //CustomPaint(painter: BackgroundPainter()),
    Center(child: CircularProgressIndicator()),
  ],
);