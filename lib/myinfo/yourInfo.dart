import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teach_me/myinfo/edit.dart';

import '../provider.dart';

// Your Page


class YourInfoPage extends StatelessWidget {
  List<Widget> TeachList = [];
  List<Widget> LearnList = [];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<t_Provider>(context, listen: false);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: floatingbar(context),
      bottomNavigationBar: bottomBar(context),
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_outlined,
              color: Colors.blue.shade900,),
              onPressed: () {
                final provider = Provider.of<t_Provider>(context, listen: false);
                // Homepage로 넘어간다.
                List<int> arr;
                arr = provider.prev;
                int goback = arr.last;
                arr.removeLast();
                provider.Prev = arr;
                provider.Page = goback;
              }
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.textsms_outlined,color: Colors.blue.shade900,),
                onPressed: () {
                  List<int> arr;
                  arr = provider.prev;
                  arr.add(provider.page);

                  provider.Prev = arr;

                  provider.Page = 6;
                }
            ),
          ],
          title: Text(provider.name,style: TextStyle(
              color : Colors.blue.shade900,
          ),)
      ),
      body: ChangeNotifierProvider(
        create: (context) => t_Provider(),
        child: FutureBuilder(
            future: FirebaseFirestore.instance.collection('user').doc(provider.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.hasData) // data가 있다면
                  {
                Map<String, dynamic> data = snapshot.data.data();
                //LoadTeachList(data);
                return MyAccountInfo(data, context, provider.uid);
              }
              else
                return buildLoading();
            }
        ),
      ),
    );
  }



  // For My account
  Widget MyAccountInfo(Map<String, dynamic> data, BuildContext context, String youruid)
  {
    TeachList.clear();
    LearnList.clear();
        return  ListView(
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Text('Info'),

              CircleAvatar(
                radius: 100,
                  backgroundImage: NetworkImage(data['profile'])
                //child: Image.network('https://firebasestorage.googleapis.com/v0/b/tci-me.appspot.com/o/%EC%8A%AC%EA%B8%B0.jpg?alt=media&token=9a3495ba-2403-4ab7-a4cc-7bd1092864bb'),
              ),

            Center(
              child: Text(data['name'], style: TextStyle(fontSize: 22.0)),
            ),
            Center(
              child : Text(data['age'].toString()+'세', style: TextStyle(fontSize: 15.0)),
            ),
            Center(
              child: Text(data['location'] + ' 거주', style: TextStyle(fontSize: 15.0)),
            ),


            Divider(
              thickness: 1,
              color: Colors.grey,
            ),
            Center(
              child: Text(data['information'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),

                            //overflow: TextOverflow.ellipsis),
            Divider(
              thickness: 1,
              color: Colors.grey,
            ),
            TeachInfo(data),
            for (int i=0; i<TeachList.length; i++)
              show_Teach(i),
            addMyTeacherButton(context, youruid),
            LearnInfo(data), // 내가 배우고 싶은 목록
            for (int i =0; i<LearnList.length; i++)
              show_Learn(i),
            addMyStudentButton(context, youruid),

          ],
        );

  }

  Widget LearnInfo(Map<String, dynamic> data)
  {
    if (data['teach'][0] != '')
    {
      for (int i=0; i<data['learn'].length; i++)
        LearnList.add(makeLearn(data['learn'][i]));
      print('Learn Info length = ' + LearnList.length.toString());
    }

    return Text('  Learn Info');
  }

  Widget makeLearn(String uid)
  {
    return Container(
      child:FutureBuilder(
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
                      radius: 60,
                      backgroundImage: NetworkImage(data['link'])
                  ),

                ],
              );
            }
            else
              return Center(
                child : Text('None'),
              );
          }
      ),
    );


  }
  Widget show_Learn(int n)
  {
    return LearnList[n];
  }
  Widget show_Teach(int n)
  {
    return TeachList[n];
  }
  Widget TeachInfo(Map<String, dynamic> data)
  {
    if (data['teach'][0] != '')
    {
      for (int i=0; i<data['teach'].length; i++)
        TeachList.add(makeTeach(data['teach'][i]));
      print('length = ' + TeachList.length.toString());
    }

    return Text('  Teach Info');
  }

  Widget makeTeach(String uid)
  {
    return Container(
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
                      radius: 60,
                      backgroundImage: NetworkImage(data['link'])
                  ),

                ],
              );
            }
            else
              return Container();
          }
      ),
    ) ;


  }

  // For Add My Teacher Button
  Widget addMyTeacherButton(BuildContext context, String youruid)
  {
    return Container(
        padding: EdgeInsets.fromLTRB(40.0,0.0,40.0,0.0),
        child: ElevatedButton(
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(color: Colors.blue)
                  )
              )
          ),
          onPressed: () async {
            print('Add my teacher button!');
            bool ck=false;
            var datas = FirebaseFirestore.instance.collection('user').doc(FirebaseAuth.instance.currentUser.uid).snapshots();
            datas.forEach((element) async {
              var dd = element.get('teach_person');
              List<String> temp = dd.cast<String>();
              //List<String> temp = dd.map((s) => s as String).toList();
              if (!(temp.contains(youruid))) // 없다면
                  {
                temp.add(youruid);
                print(temp);

                await FirebaseFirestore.instance
                    .collection('user')
                    .doc(FirebaseAuth.instance.currentUser.uid)
                    .update({
                  'teach_person': temp
                });
                print('update 완료');
              }
              else
                print('update 할거 없음');

            });
            //print(datas['name']);
          },
          child: Text("Add My Teacher!", style: TextStyle(fontSize: 20.0)),
        )
    );
  }

  Widget addMyStudentButton(BuildContext context, String youruid)
  {
    return Container(
        padding: EdgeInsets.fromLTRB(40.0,0.0,40.0,0.0),
        child: ElevatedButton(
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(color: Colors.blue)
                  )
              )
          ),
          onPressed: () async {
            print('Add my student button!');

            var datas = FirebaseFirestore.instance.collection('user').doc(FirebaseAuth.instance.currentUser.uid).snapshots();
            datas.forEach((element) async {
              var dd = element.get('learn_person');
              List<String> temp = dd.cast<String>();
              //List<String> temp = dd.map((s) => s as String).toList();
              if (!(temp.contains(youruid))) // 없다면
                  {
                temp.add(youruid);
                print(temp);

                await FirebaseFirestore.instance
                    .collection('user')
                    .doc(FirebaseAuth.instance.currentUser.uid)
                    .update({
                  'learn_person': temp
                });
                print('update 완료');
              }
              else
                print('update 할거 없음');

            });
            //print(datas['name']);
          },
          child: Text("Add My Students!", style: TextStyle(fontSize: 20.0)),
        )
    );
  }

  // For Bottom Navigation Bar
  Widget bottomBar(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      //color of the BottomAppBar
      elevation: 0,
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
                //provider.isInfoPage = true;
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
                print('1');
              },
              iconSize: 27.0,
              icon: Icon(
                  Icons.search,
                  color: Colors.blue.shade900
              ),
            ),
            //to leave space in between the bottom app bar items and below the FAB

            IconButton(
              onPressed: () {
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
                //provider.isPosenet = true;
                print('3');
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

  // For Floating Action Button
  Widget floatingbar(BuildContext context)
  {
    return FloatingActionButton(
      backgroundColor: Colors.pinkAccent,
      onPressed: () {
        print('floating action btn');
        final provider = Provider.of<t_Provider>(context, listen: false);
        print('posenet 바꿈');
        provider.Page = 10;

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
