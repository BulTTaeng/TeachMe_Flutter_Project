import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _emailController = TextEditingController();
final _nameController = TextEditingController();
final _passwordController = TextEditingController();
final _ageController = TextEditingController();
final _regionController = TextEditingController();
final _cellphoneController = TextEditingController();

class SignUpPage extends StatelessWidget
{
  final _formKey = GlobalKey<FormState>();



  @override
  Widget build(BuildContext context)
  {
    final provider = Provider.of<t_Provider>(context, listen: false);
    _regionController.text = provider.region;
    return Scaffold(
        //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        //floatingActionButton: floatingbar(),
        //bottomNavigationBar: bottomBar(),
        body: ListView(
          children: [
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 50.0),
                    showRegisterTitle(),
                    SizedBox(height: 50.0),
                    showTextFormField(false, 'email', _emailController),
                    SizedBox(height: 20.0),
                    showTextFormField(true, 'password', _passwordController),
                    SizedBox(height: 20.0),
                    showTextFormField(false, 'name', _nameController),
                    SizedBox(height: 20.0),
                    showTextFormField(false, 'age', _ageController),
                    SizedBox(height: 20.0),
                    Row(
                      children: [
                        Expanded(
                          flex : 8,
                            child: showTextFormField(false, 'region', _regionController),
                        ),
                        Flexible(
                            child: IconButton(
                              icon: Icon(
                                Icons.add_location_outlined,
                              ),
                              onPressed: () {
                                final provider = Provider.of<t_Provider>(context, listen: false);

                                provider.Page = 7;
                              },

                            )
                        ),
                      ],
                    ),

                    SizedBox(height: 20.0),
                    showTextFormField(false, 'CellPhone', _cellphoneController),
                  ],
                )
            ),
            SizedBox(height: 50.0),
            showRegisterButton(context),
            showGobackButton(context),
          ],
        )
    );
  }

  // For Title : Register
  Widget showRegisterTitle()
  {
    return Container(
        padding: EdgeInsets.fromLTRB(20.0,0.0,20.0,0.0),
        child: Row(
          children: [
            Text(
                'Register',
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                )
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
                ' Input Your ${name}',
                border: InputBorder.none,
              ),
            )
        )
    );
  }

  // For Register Button
  Widget showRegisterButton(BuildContext context)
  {
    return Container(
        padding: EdgeInsets.fromLTRB(40.0,0.0,40.0,0.0),
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
            print('Push Register button!');
            // validation check
            if (_formKey.currentState.validate()){
              await registerAccount(context);
              final provider = Provider.of<t_Provider>(context, listen: false);
              provider.Latitude = 0;
              provider.Longitude = 0;
              provider.Region = "";
              _emailController.text = "";
              _nameController.text = "";
              _passwordController.text = "";
              _ageController.text = "";
              _regionController.text = "";
              _cellphoneController.text = "";

            }

            else
              print('Plz Check Your Validation');
          },
          child: Text("Register Now!", style: TextStyle(fontSize: 18.0)),
        )
    );
  }

  Widget showGobackButton(BuildContext context)
  {
    return Container(
        padding: EdgeInsets.fromLTRB(40.0,0.0,40.0,0.0),
        child:
        ElevatedButton(
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.white)
                  )
              )
          ),
          onPressed: () {
            final provider = Provider.of<t_Provider>(context , listen: false);
            provider.Latitude = 0;
            provider.Longitude = 0;
            provider.Region = "";
            _emailController.text = "";
            _nameController.text = "";
            _passwordController.text = "";
            _ageController.text = "";
            _regionController.text = "";
            _cellphoneController.text = "";

            provider.Page = 0;
          },
          child: Text("Go back to login page", style: TextStyle(fontSize: 18.0)),
        )
    );
  }

  // firebase user에 등록
  void registerAccount(BuildContext context) async
  {
    final provider = Provider.of<t_Provider>(context, listen: false);
    final userReference = FirebaseFirestore.instance.collection('user');

    List<String> temp = new List<String>();
    temp.add("");

    print('Register중');

    // 동일한 email이 없으면 new accounts with a method
    try {
      var userCredentail = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text
      );
      final provider = Provider.of<t_Provider>(context, listen: false);
      final regist = await FirebaseFirestore.instance
          .collection('user')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .set({
        'age': int.parse(_ageController.text),
        'information': '',
        'learn': [],
        'location': _regionController.text,
        'name': _nameController.text,
        'phone_number': _cellphoneController.text,
        'profile': 'https://firebasestorage.googleapis.com/v0/b/tci-me.appspot.com/o/%EC%8A%AC%EA%B8%B0.jpg?alt=media&token=9a3495ba-2403-4ab7-a4cc-7bd1092864bb',
        'teach': [],
        'uid': FirebaseAuth.instance.currentUser.uid,
        'email': _emailController.text,
        'learn_person': [],
        'teach_person': [],
        'latitude' : provider.latitude,
        'longitude' : provider.longitude,
      });

      print('retgister complete');
      //provider.isSignUpPage = false;
      //final provider = Provider.of<t_Provider>(context, listen: false);
      provider.Page = 0;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password')
        print('The password provided is too weak.');
      else if (e.code == 'email-already-in-use')
        print('The account already exists for that email.');
    } catch (e){
      print(e);
    }
  }

  // For Bottom Navigation Bar
  Widget bottomBar() {
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
  Widget floatingbar()
  {
    return FloatingActionButton(
      backgroundColor: Colors.pinkAccent,
      onPressed: () {
        print('floating action btn');
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