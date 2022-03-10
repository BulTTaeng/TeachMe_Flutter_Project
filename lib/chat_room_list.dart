import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teach_me/myinfo/edit.dart';

import 'provider.dart';

// 채팅방 목록

class ChatRoomListPage extends StatefulWidget {
  @override
  _ChatRoomListPageState createState() => _ChatRoomListPageState();
}

class _ChatRoomListPageState extends State<ChatRoomListPage>
{
  List<String> arrlist;
  // Find path for default handong logo
  Future<void> init() async {
    await FirebaseFirestore.instance
        .collection('chatroom')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get().then((DocumentSnapshot ds) {
      //print(ds.get('chatting'));
      setState(() {
        arrlist = ds.get('chatting').cast<String>();
        print(arrlist);
      });
    });
  }


  // constructor
  _ChatRoomListPageState() {
    init();
  }

  @override
  Widget build(BuildContext context)
  {
    final provider = Provider.of<t_Provider>(context , listen: false);

    return Scaffold(
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      //floatingActionButton: floatingbar(context),
      //bottomNavigationBar: bottomBar(context),
      appBar: AppBar(
          centerTitle: true,
          //backgroundColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_outlined,
              color: Colors.blue.shade900,),
              onPressed: (){
                // Homepage로 넘어간다.
                final provider = Provider.of<t_Provider>(context, listen: false);
                List arr = provider.prev;
                int goback = arr.last;
                arr.removeLast();
                provider.Prev  = arr;
                provider.Page = goback;
              }
          ),

          title: Text('Chat Room List',
          style: TextStyle(
            color: Colors.blue.shade900,
          ),)
      ),
      //body: arrlist != null ? Text('num:' + arrlist.length.toString()) : Text('')
      body: ChangeNotifierProvider(
        create: (context) => t_Provider(),
        child: StreamBuilder(
            stream : FirebaseFirestore.instance.collection('user').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot)
            {
              if (snapshot.hasData && arrlist != null) // data가 있다면
                  {
                List<dynamic> all = snapshot.data.docs.map((doc) =>
                    doc.data()).toList();
                return ListView.builder(
                  itemCount: all.length,
                  padding: EdgeInsets.fromLTRB(2, 10, 2, 10),
                    itemBuilder: (BuildContext context, int index) {
                    if(arrlist.contains(all[index]['uid'])){
                      return InkWell(
                        onTap: (){

                          provider.Name = all[index]["name"];
                          provider.Uid  = all[index]["uid"];
                          List<int> arr = [];
                          arr = provider.prev;
                          arr.add(provider.page);
                          provider.Prev = arr;
                          provider.Page = 6;
                        },
                        child: Container(
                            padding: EdgeInsets.fromLTRB(10.0, 15.0, 0.0, 5.0),
                            child: Column(
                              //crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(

                                  children: [
                                    SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: CircleAvatar(
                                          backgroundImage: NetworkImage(all[index]['profile'])
                                        //child: Image.network('https://firebasestorage.googleapis.com/v0/b/tci-me.appspot.com/o/%EC%8A%AC%EA%B8%B0.jpg?alt=media&token=9a3495ba-2403-4ab7-a4cc-7bd1092864bb'),
                                      ),
                                    ),
                                    Container(
                                        padding: EdgeInsets.fromLTRB(10.0, 15.0, 0.0, 5.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(all[index]['name']),
                                             ],
                                        )
                                    )
                                  ],
                                ),
                              ],
                            )
                        ),
                      );
                    }
                    else{
                      return Container();
                    }





                    }
                );
              }
              else
                return Text('No data');
            }
        ),
      ),
    );
  }

  // for chat room ListView
  Widget chatroomlist(AsyncSnapshot<QuerySnapshot> snapshot)
  {
    print(arrlist);
    snapshot.data.docs.forEach((element) {
      if (arrlist.contains(element.get('uid')))
        return ChatRoomInfo(element.get('name'), element.get('age').toString(), element.get('region'), element.get('information'), element.get('profile'),);
      else
        return Container();
    });
  }

  // For My account
  Widget ChatRoomInfo(String name, String age, String region, String information, String profile)
  {
    return Container(
        padding: EdgeInsets.fromLTRB(10.0, 15.0, 0.0, 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(''),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircleAvatar(
                      backgroundImage: NetworkImage(profile)
                    //child: Image.network('https://firebasestorage.googleapis.com/v0/b/tci-me.appspot.com/o/%EC%8A%AC%EA%B8%B0.jpg?alt=media&token=9a3495ba-2403-4ab7-a4cc-7bd1092864bb'),
                  ),
                ),
                Container(
                    padding: EdgeInsets.fromLTRB(10.0, 15.0, 0.0, 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name),
                        Text(information,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis)
                      ],
                    )
                )
              ],
            ),
          ],
        )
    );
  }
}