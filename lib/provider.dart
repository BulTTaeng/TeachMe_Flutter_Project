import 'dart:core';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as gec;


class t_Provider extends ChangeNotifier {

  int _page =0;
  String _name = "";
  String _uid = "";
  LocationData curr;
  gec.Placemark pla;
  List<int> _prev =[];
  String _region = "";
  double _latitude = 0;
  double _longitude = 0;



  t_Provider() {
    _page = 0;
    _name = null;
    _uid = null;
  }

  int get page => _page;
  String get name => _name;
  String get uid => _uid;
  List get prev => _prev;
  double get latitude => _latitude;
  double get longitude => _longitude;

  String  get region => _region;


  set Region(String region){
    _region = region;
    //notifyListeners();
  }
  set Latitude(double la){
    _latitude = la;
  }
  set Longitude(double lo){
    _longitude = lo;
  }





  set Page(int page){
    _page = page;
    notifyListeners();
  }
  set Name(String name){
    _name = name;
    notifyListeners();
  }
  set Uid(String uid) {
    _uid = uid;
    notifyListeners();
  }
  set Prev(List<int> prev){
    _prev =prev;
  }




  void call_notity(){
    notifyListeners();
  }


}
