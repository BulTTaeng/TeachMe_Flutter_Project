import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teach_me/myinfo/edit.dart';

import '../provider.dart';

// 마이페이지

class MyInfoPage extends StatelessWidget
{
  List<Widget> TeachList = [];
  List<Widget> LearnList = [];

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: floatingbar(context),
      bottomNavigationBar: bottomBar(context),
      appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          // backgroundColor: Colors.grey,
          backgroundColor: Colors.white,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_outlined,
                color: Colors.blue.shade900,),
              onPressed: (){
                // Homepage로 넘어간다.
                final provider = Provider.of<t_Provider>(context, listen: false);
                List<int> arr = provider.prev;
                int goback = arr.last;
                arr.removeLast();
                provider.Prev = arr;
                provider.Page = goback;

              }
          ),
          actions:[
            IconButton(
                icon: Icon(Icons.edit, color: Colors.blue.shade900,),
                onPressed: (){
                  // Editpage로 넘어간다.
                  print('Editpage로 넘어가기!');
                  final provider = Provider.of<t_Provider>(context, listen: false);
                  provider.Page = 9;
                }
            ),
            IconButton(
                icon: Icon(Icons.exit_to_app,color: Colors.blue.shade900,),
                onPressed: (){
                  // LogOut
                  print('로그아웃!');
                  signOut();
                  final provider = Provider.of<t_Provider>(context, listen: false);
                  provider.Page =0;

                }
            ),
          ],
          title: Text('My Info',
            style: TextStyle(
                color : Colors.blue.shade900
            ),)
      ),
      body: ChangeNotifierProvider(
        create: (context) => t_Provider(),
        child: FutureBuilder(
            future : FirebaseFirestore.instance.collection('user').doc(FirebaseAuth.instance.currentUser.uid).get(),
            builder: (context, snapshot)
            {
              if (snapshot.hasData) // data가 있다면
                  {
                Map<String, dynamic> data = snapshot.data.data();
                //LoadTeachList(data);
                return MyAccount(data);
              }
              else
                return buildLoading();
            }
        ),
      ),
    );
  }

  Widget show_Teach(int n)
  {
    return TeachList[n];
  }

  Widget show_Learn(int n)
  {
    return LearnList[n];
  }

  // For My account
  Widget MyAccount(Map<String, dynamic> data)
  {
    TeachList.clear();
    LearnList.clear();

    return ListView(
      children: [
        MyAccountInfo(data),
        Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        TeachInfo(data),
        Text('  Teach Info'),
        for (int i=0; i<TeachList.length; i++)
          show_Teach(i),
        Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        LearnInfo(data), // 내가 배우고 싶은 목록
        Text('  Learn Info'),
        for (int i =0; i<LearnList.length; i++)
          show_Learn(i),
      ],
    );
  }

  // For My account
  Widget MyAccountInfo(Map<String, dynamic> data)
  {
    return Container(
        padding: EdgeInsets.fromLTRB(10.0, 15.0, 0.0, 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My account'),
            Row(
              children: [
                 CircleAvatar(
                    radius: 50,
                      backgroundImage: NetworkImage(data['profile'])
                    //child: Image.network('https://firebasestorage.googleapis.com/v0/b/tci-me.appspot.com/o/%EC%8A%AC%EA%B8%B0.jpg?alt=media&token=9a3495ba-2403-4ab7-a4cc-7bd1092864bb'),
                  ),

                Container(
                    padding: EdgeInsets.fromLTRB(10.0, 15.0, 0.0, 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['name']),
                        Text(data['information'],
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

  // For Load Teach List Widget
  void LoadTeachList(Map<String, dynamic> data)
  {
    if (data['teach'] != null)
    {
      for (int i=0; i<data['teach'].length; i++)
        TeachList.add(makeTeach(data['teach'][i]));
      print('length = ' + TeachList.length.toString());
    }
  }

  // For Teach Info
  Widget TeachInfo(Map<String, dynamic> data)
  {
    if (data['teach'] != null)
    {
      for (int i=0; i<data['teach'].length; i++)
        TeachList.add(makeTeach(data['teach'][i]));
      print('length = ' + TeachList.length.toString());
    }

    return Container();
  }

  // For Making Teach List with Widget
  Widget makeTeach(String uid)
  {
    return Container(
        padding: EdgeInsets.fromLTRB(10.0, 15.0, 0.0, 5.0),
        child: FutureBuilder(
            future: FirebaseFirestore.instance.collection('sports').doc(uid).get(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic> data = snapshot.data.data();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['name']),
                    Row(children: [
                      for (int i=0; i< data['information'].length ; i++)
                        Text(data['information'][i] + ' ' ,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis)
                    ],
                    ),
                    CircleAvatar(
                      radius: 50,
                          backgroundImage: NetworkImage(data['link'])
                      ),

                  ],
                );
              }
              else
                return Container();
            }
        )
    );
  }

  // For Learn Info
  Widget LearnInfo(Map<String, dynamic> data)
  {
    if (data['learn'] != null)
    {
      for (int i=0; i<data['learn'].length; i++)
        LearnList.add(makeLearn(data['learn'][i]));
      print('Learn Info length = ' + LearnList.length.toString());
    }

    return Container();
  }

  // For Making Teach List with Widget
  Widget makeLearn(String uid)
  {
    return Container(
        padding: EdgeInsets.fromLTRB(10.0, 15.0, 0.0, 5.0),
        child: FutureBuilder(
            future: FirebaseFirestore.instance.collection('sports').doc(uid).get(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic> data = snapshot.data.data();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['name']),
                    Row(children: [
                      for (int i=0; i< data['information'].length ; i++)
                        Text(data['information'][i] + ' ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis, )
                    ],
                    ),

                      CircleAvatar(
                        radius: 50,
                          backgroundImage: NetworkImage(data['link'])
                      ),

                  ],
                );
              }
              else
                return Text('None');
            }
        )
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

  void signOut() async {
    FirebaseAuth.instance.signOut();
  }
}

Widget buildLoading() => Stack(
  fit: StackFit.expand,
  children: [
    //CustomPaint(painter: BackgroundPainter()),
    Center(child: CircularProgressIndicator()),
  ],
);