import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teach_me/provider.dart';
import 'provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SignInPage extends StatelessWidget
{
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context)
  {
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
                    showLoginTitle(),
                    SizedBox(height: 50.0),
                    showTextFormField(false, 'email address', _emailController),
                    SizedBox(height: 20.0),
                    showTextFormField(true, 'password', _passwordController),
                  ],
                )
            ),
            SizedBox(height: 20.0),
            showSignInButton(context),
            SizedBox(height: 10.0),
            showSignUpButton(context),
          ],
        )
    );
  }

  // For Title : Log in
  Widget showLoginTitle()
  {
    return Container(
        padding: EdgeInsets.fromLTRB(20.0,0.0,20.0,0.0),
        child: Row(
          children: [
            Text(
                'Log in',
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
                  return ' Please Enter Your ${name}';
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

  // For Sign In Button
  Widget showSignInButton(BuildContext context)
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
            print('Sign In button!');
            if (_formKey.currentState.validate()) {
              await signInWithEmailAndPassword(context);

              final provider = Provider.of<t_Provider>(context, listen: false);
              provider.Prev = [];
            }
            else
              print('Plz Check Your Validation');
          },
          child: Text("Sign In", style: TextStyle(fontSize: 20.0)),
        )
    );
  }

  // For Sign Up Button
  Widget showSignUpButton(BuildContext context)
  {
    return Container(
        padding: EdgeInsets.fromLTRB(40.0,0.0,40.0,0.0),
        child:
        ElevatedButton(
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.purple),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(color: Colors.purple)
                  )
              )
          ),
          onPressed: () async {
            print('Sign Up button!');
            final provider = Provider.of<t_Provider>(context, listen: false);
            provider.Page = 1;
          },
          child: Text("Sign Up", style: TextStyle(fontSize: 20.0)),
        )
    );
  }

  // For Sign In
  Future signInWithEmailAndPassword(BuildContext context) async
  {
    final userReference = FirebaseFirestore.instance.collection('user');

    try{
      // sign in to an existing account with
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if(FirebaseAuth.instance.currentUser.uid != null)
      {
        print('user 정보 존재있음');
        print(FirebaseAuth.instance.currentUser.uid);
        print('login complete!');
        final provider = Provider.of<t_Provider>(context, listen: false);
        provider.Page = 2;

      }
    } catch (e){
      print('error! Login Failed!');
      print(e.message);
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
      child: Container(
        margin: EdgeInsets.all(15.0),
        child: Icon(Icons.add, color: Colors.white),
      ),
      elevation: 4.0,
    );
  }
}