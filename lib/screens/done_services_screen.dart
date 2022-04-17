
import 'package:barber_shop/cloud_firestore/all_salon_ref.dart';
import 'package:barber_shop/cloud_firestore/banner_ref.dart';
import 'package:barber_shop/cloud_firestore/lookbook_ref.dart';
import 'package:barber_shop/cloud_firestore/services_ref.dart';
import 'package:barber_shop/cloud_firestore/user_ref.dart';
import 'package:barber_shop/model/City_model.dart';
import 'package:barber_shop/model/booking_model.dart';
import 'package:barber_shop/model/image_model.dart';
import 'package:barber_shop/model/salon_model.dart';
import 'package:barber_shop/model/service_model.dart';
import 'package:barber_shop/model/user_model.dart';
import 'package:barber_shop/state/state_management.dart';
import 'package:barber_shop/utils/utils.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DoneService extends ConsumerWidget{
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  @override
  Widget build(BuildContext context, watch) {
    //Chip choices not hold state, so clear servicesSelected, when refreshed
    context.read(selectedServices).state.clear();
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: true,
        backgroundColor:  Color(0xFFDFDFDF),
        appBar: AppBar(
          title: Text('Done Services'),
          backgroundColor: Color(0xFF383838),
        ),
        body: Column(children: [
          Padding(padding: const EdgeInsets.all(8),child:
            FutureBuilder(
              future: getDetailBooking(context, context.read(selectedTimeSlot).state),
              builder: (context, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator(),);
                else{
                  var bookingModel = snapshot.data as BookingModel;
                  return Card(
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Row(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            CircleAvatar(
                              child: Icon(Icons.account_box_rounded, color:Colors.white),
                              backgroundColor: Colors.black,
                            ),
                              SizedBox(width: 30,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text('${bookingModel.customerName}',
                                    style: GoogleFonts.robotoMono(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                                    Text('${bookingModel.customerPhone}',
                                      style: GoogleFonts.robotoMono(
                                          fontSize: 18)),
                                ],
                              )
                            ],
                          ),
                          Divider(thickness: 2,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                            Consumer(builder: (context, watch,_){
                              var servicesSelected = watch(selectedServices).state;
                              var totalPrice = servicesSelected
                                  .map((item)=> item.price)
                                  .fold(0,
                                      (value, element) => value + element);
                              return Text('Price \$${context.read(selectedBooking).state.totalPrice == 0 ? totalPrice: context.read(selectedBooking).state.totalPrice}',
                                style: GoogleFonts.robotoMono(fontSize: 22),);
                            }),
                              context.read(selectedBooking)
                              .state.done ? Chip(label: Text('Finished'),) : Container()
                          ],)
                        ],
                      ),
                    ),
                  );
                }
              },
            ),),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: FutureBuilder(
                future: getServices(context),
                builder: (context,snapshot){
                  if(snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator(),);
                  else
                    {
                      var services = snapshot.data as List<ServiceModel>;
                      return Consumer(builder: (context,watch,_){
                        var servicesWatch = watch(selectedServices).state;
                        return SingleChildScrollView(
                          child: Column(children: [
                            ChipsChoice<ServiceModel>.multiple(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                wrapped: true,
                                value: servicesWatch,
                                onChanged: (val)=> context.read(selectedServices).state = val,
                                choiceStyle: C2ChoiceStyle(elevation: 8),
                                choiceItems: C2Choice.listFrom<
                                    ServiceModel,
                                    ServiceModel>(
                                    source: services,
                                    value: (index,value) => value,
                                    label: (index,value) => '${value
                                        .name} (\$${value.price}'  )
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                onPressed:
                                  context.read(selectedBooking).state.done
                                      ? null
                                      : servicesWatch.length > 0
                                        ? ()=> finishService(context)
                                        : null,
                                child: Text(
                                  'FINISH',
                                  style: GoogleFonts.robotoMono(),
                                ),
                              ),
                            )
                          ],)
                        );
                      });
                    }
                }
              ),
            ),
          )
        ],),
      ),
    );
  }

  finishService(BuildContext context) {
    var batch  = FirebaseFirestore.instance.batch();
    var barberBook = context.read(selectedBooking).state;
    
    var userBook = FirebaseFirestore.instance
    .collection('User')
    .doc('${barberBook.customerPhone}')
    .collection('Booking_${barberBook.customerId}')
    .doc('${barberBook.barberId}_${DateFormat('dd_MM_yyyy').format(
      DateTime.fromMillisecondsSinceEpoch(barberBook.timeStamp))}');
    Map<String,dynamic> updateDone = new Map();
    updateDone['done'] = true;
    updateDone['services'] = convertServices(context.read(selectedServices).state);
    updateDone['totalPrice'] = context
        .read(selectedServices)
        .state
        .map((e)=>e.price)
        .fold(0, (previousValue, element)=>previousValue+element);

    batch.update(userBook,updateDone);
    batch.update(barberBook.reference, updateDone);

    batch.commit().then((value){
      ScaffoldMessenger.of(scaffoldKey.currentContext)
          .showSnackBar(SnackBar(content:Text('Process success'))).closed
          .then((v)=> Navigator.of(context).pop());
    });
  }
}