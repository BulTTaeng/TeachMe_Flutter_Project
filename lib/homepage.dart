import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teach_me/find_near.dart';
import 'package:teach_me/posenet/posenet.dart';
import 'package:teach_me/select_teach_learn.dart';
import 'package:teach_me/sign_up.dart';
import 'package:teach_me/teacher_for_you.dart';


import 'chat_room.dart';
import 'chat_room_list.dart';
import 'google_map.dart';
import 'home.dart';
import 'log_in.dart';
import 'main.dart';
import 'myinfo/edit.dart';
import 'myinfo/myInfo.dart';
import 'myinfo/yourInfo.dart';
import 'provider.dart';
import 'find_near.dart';


class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          body: ChangeNotifierProvider(
            create: (context) => t_Provider(),
            child: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                final provider = Provider.of<t_Provider>(context);

               // print(provider.currentLocation.latitude);
                if (provider.page == 0) { // login
                  return SignInPage();
                } else if(provider.page ==1){ //regester
                  return SignUpPage();
                } else if(provider.page == 2){ // select what you can teach and select what you want to learn
                  return teach_learn();
                } else if(provider.page == 3){ //teachers recommandation
                  return teacher_for_you();
                } else if (provider.page  == 4){ // students recommandation
                  return student_for_you();
                } else if(provider.page == 5){ // Home
                  return Home();
                } else if(provider.page == 6){ // chat room
                  return Chat(name : provider.name , y_uid : provider.uid);
                } else if(provider.page == 7){ // google map
                  return Google();
                } else if(provider.page == 8){ // my infopage
                  return MyInfoPage();
                } else if(provider.page == 9){ // edit
                  return EditPage();
                } else if(provider.page == 10) {// posnet
                  return PoseNet();
                } else if(provider.page == 11){ // your info
                  return YourInfoPage();
                } else if(provider.page == 12) { // find near
                  return Find_near();
                } else if(provider.page == 13){ //chatroom list
                  return ChatRoomListPage();
                }
                else{
                  return buildLoading();
                }
              },
            ),
          ),

    );

  }


  Widget buildLoading() => Stack(
    fit: StackFit.expand,
    children: [
      //CustomPaint(painter: BackgroundPainter()),
      Center(child: CircularProgressIndicator()),
    ],
  );
}