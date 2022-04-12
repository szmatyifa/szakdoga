
import 'package:barber_shop/cloud_firestore/banner_ref.dart';
import 'package:barber_shop/cloud_firestore/lookbook_ref.dart';
import 'package:barber_shop/cloud_firestore/user_ref.dart';
import 'package:barber_shop/model/image_model.dart';
import 'package:barber_shop/model/user_model.dart';
import 'package:barber_shop/state/state_management.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffHome extends ConsumerWidget{
  @override
  Widget build(BuildContext context, watch) {
    return SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor:  Color(0xFFDFDFDF),
          appBar: AppBar(title: Text('Staff home'),backgroundColor: Color(0xFF383838),),
          body: Center(child: Text('Staff home'),),
        ));
  }
}