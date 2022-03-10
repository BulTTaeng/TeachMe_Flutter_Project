import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../provider.dart';

// Edit 페이지

class EditPage extends StatefulWidget
{
  @override
  _editPageState createState() => _editPageState();
}

class _editPageState extends State<EditPage>
{
  String downloadURL='';
  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final _nameController = TextEditingController();
  final _informationController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  PickedFile _image = null;
  bool changed = false;

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      key: scaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: floatingbar(context),
      bottomNavigationBar: bottomBar(context),
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_outlined,
              color: Colors.blue.shade900,),
              onPressed: (){
                final provider = Provider.of<t_Provider>(context, listen: false);
                provider.Page = 8;
              }
          ),
          actions:[
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
            ),
          ],
          title: Text('Edit My Info',
          style: TextStyle(
            color: Colors.blue.shade900,
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
                return MyAccount(data, context);
              }
              else
                return Text('No data');
            }
        ),
      ),
    );
  }

  // get info from picked image
  Future _getImage() async{
    PickedFile image = (await _picker.getImage(source: ImageSource.gallery));
    if (this.mounted){
      setState(() {
        _image = image;
        changed = true;
      });
    }
    await _uploadImageToStorage();
  }

  // upload to Firebase Storage
  void _uploadImageToStorage() async{
    // changed the image
    //String downloadURL='';
    if (changed)
    {
      var now = new DateTime.now();
      String path = DateFormat('yyyyMMddhhmmss').format(now);

      // firebase storage upload
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('/${path}');

      UploadTask uploadTask = ref.putFile(File(_image.path));
      await uploadTask.whenComplete(() {
        print('complete');
      });
      downloadURL = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('user')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .update
        ({
        'profile' : downloadURL,
      });
    }

    final provider = Provider.of<t_Provider>(context, listen: false);
    //provider.isEditPage = false;
    provider.call_notity();
  }

  // For My account
  Widget MyAccount(Map<String, dynamic> data, BuildContext context)
  {
    return ListView(
      children: [
        MyAccountInfo(data),
        Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        EditStatus(context),
        Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        EditProfile(context, data['profile']),
      ],
    );
  }

  // For Edit Status
  Widget EditStatus(BuildContext context)
  {
    return Container(
        padding: EdgeInsets.fromLTRB(10.0, 15.0, 0.0, 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit My Status'),
            SizedBox(height:20.0),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  showTextFormField(false, 'Name', _nameController),
                  SizedBox(height:20.0),
                  showTextFormField(false, 'Status Message', _informationController),
                  SizedBox(height:40.0),
                ],
              ),
            ),
            showEditButton(context),
          ]
        )
    );
  }

  // For Edit Profile Image
  Widget EditProfile(BuildContext context, String path)
  {
    return Container(
        padding: EdgeInsets.fromLTRB(10.0, 15.0, 0.0, 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Profile Img'),
            SizedBox(height:20.0),
            Center(child: Text('Current Img')),

            showLoadButton(context, path),
          ]
        )
    );
  }

  // For Edit Button
  Widget showEditButton(BuildContext context)
  {
    return Container(
        padding: EdgeInsets.fromLTRB(130.0,0.0,130.0,0.0),
        child:
        ElevatedButton(
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.red)
                  )
              )
          ),
          onPressed: () async {
            print('Push Edit button!');
            // validation check
            if (_formKey.currentState.validate())
            {
              // await registerAccount(context);
              final regist = await FirebaseFirestore.instance
                .collection('user')
                .doc(FirebaseAuth.instance.currentUser.uid)
                .update({
                  'information': _informationController.text,
                  'name': _nameController.text,
                });
              print('Database Update Complete!');
              _informationController.clear();
              _nameController.clear();
              showSnackBarWithKey('Your Profile Edit Complete!');
              final provider = Provider.of<t_Provider>(context, listen: false);
              //provider.isEditPage = false;
            }
            else
              print('Plz Check Your Validation');
          },
          child: Center(child: Text("Edit", style: TextStyle(fontSize: 18.0))),
        )
    );
  }

  // For Load Button
  Widget showLoadButton(BuildContext context, String currentImgPath)
  {
    return Container(
        padding: EdgeInsets.fromLTRB(130.0,0.0,130.0,0.0),
        child: Column(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: downloadURL == '' ?
              CircleAvatar(
                  backgroundImage: NetworkImage(currentImgPath)
                //child: Image.network('https://firebasestorage.googleapis.com/v0/b/tci-me.appspot.com/o/%EC%8A%AC%EA%B8%B0.jpg?alt=media&token=9a3495ba-2403-4ab7-a4cc-7bd1092864bb'),
              ) : CircleAvatar(
                  backgroundImage: NetworkImage(downloadURL)
                //child: Image.network('https://firebasestorage.googleapis.com/v0/b/tci-me.appspot.com/o/%EC%8A%AC%EA%B8%B0.jpg?alt=media&token=9a3495ba-2403-4ab7-a4cc-7bd1092864bb'),
              )
            ),
            SizedBox(height:20.0),
            ElevatedButton(
              style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(color: Colors.green)
                      )
                  )
              ),
              onPressed: () async {
                print('Push Load button!');
                await _getImage();
              },
              child: Center(child: Text("Load Img", style: TextStyle(fontSize: 18.0))),
            )
          ],
        )
    );
  }

  // For Dynamic TextField
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
              maxLines: obsc == true ? 1 : null,
              validator: (value)
              {
                if (value == null || value.isEmpty) {
                  return 'Please Enter Your ${name}';
                }
                // for password length validation
                else if (obsc == true && value.length <6)
                  return 'Please Enter Your password length > 6';

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
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircleAvatar(
                      backgroundImage: NetworkImage(data['profile'])
                    //child: Image.network('https://firebasestorage.googleapis.com/v0/b/tci-me.appspot.com/o/%EC%8A%AC%EA%B8%B0.jpg?alt=media&token=9a3495ba-2403-4ab7-a4cc-7bd1092864bb'),
                  ),
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
                print('0');
                final provider = Provider.of<t_Provider>(context, listen: false);
                //provider.isInfoPage = true;
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
            SizedBox(
              width: 50.0,
            ),
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
        //provider.isInfoPage = false;
      },
      tooltip: "Centre FAB",
      elevation: 4.0,
      child: Container(
        margin: EdgeInsets.all(15.0),
        child: Icon(Icons.add),
      ),
    );
  }

  showSnackBarWithKey(String message)
  {
    scaffoldKey.currentState
    // ignore: deprecated_member_use
      ..hideCurrentSnackBar()
    // ignore: deprecated_member_use
      ..showSnackBar(SnackBar
        (
        content: Text(message),
        action: SnackBarAction
          (
          label: 'Done',
          onPressed: (){},
        ),
      ));
  }

  void signOut() async {
    FirebaseAuth.instance.signOut();
  }

}