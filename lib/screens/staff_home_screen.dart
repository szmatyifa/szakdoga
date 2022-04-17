
import 'package:barber_shop/cloud_firestore/all_salon_ref.dart';
import 'package:barber_shop/cloud_firestore/banner_ref.dart';
import 'package:barber_shop/cloud_firestore/lookbook_ref.dart';
import 'package:barber_shop/cloud_firestore/user_ref.dart';
import 'package:barber_shop/model/City_model.dart';
import 'package:barber_shop/model/image_model.dart';
import 'package:barber_shop/model/salon_model.dart';
import 'package:barber_shop/model/user_model.dart';
import 'package:barber_shop/state/state_management.dart';
import 'package:barber_shop/utils/utils.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StaffHome extends ConsumerWidget{
  @override
  Widget build(BuildContext context, watch) {
    var currentStaffStep = watch(staffStep).state;
    var cityWatch = watch(selectedCity).state;
    var salonWatch = watch(selectedSalon).state;
    var dateWatch = watch(selectedDate).state;

    return SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor:  Color(0xFFDFDFDF),
          appBar: AppBar(
            title: Text(currentStaffStep == 1
                ? 'Select City'
                : currentStaffStep == 2
                  ? 'Select Salon'
                  : currentStaffStep == 3
                    ? 'Your Appointment'
                    : 'Staff Home'),
            backgroundColor: Color(0xFF383838),
          ),
          body: Column(children: [
            //Area
            Expanded(
              child: currentStaffStep == 1
                  ? displayCity()
                  : currentStaffStep == 2
                    ? displaySalon(cityWatch.name) :
        currentStaffStep == 3 ? displayAppointment(context)

                    : Container(),
              flex:10,
            ),

            //Button
            Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(padding: const EdgeInsets.all(8),
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: ElevatedButton(
                            onPressed: currentStaffStep == 1 ? null : ()=> context.read(staffStep).state--,
                            child: Text('Previous'),
                          )),
                      SizedBox(
                        width: 30,
                      ),
                      Expanded(
                          child: ElevatedButton(
                            onPressed:  (currentStaffStep == 1 &&
                                context.read(selectedCity).state.name == null) ||
                                (currentStaffStep == 2 &&
                                    context.read(selectedSalon).state.docId == null)  ||
                                currentStaffStep == 3
                                ? null
                                : ()=> context
                                .read(staffStep)
                                .state++
                            ,
                            child: Text('Next'),
                          )),
                    ],
                  ),),
                )
            )
          ],),
          ),
        );
  }

  displayCity() {
    return FutureBuilder(
        future: getCities(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator(),);
          else{
            var cities = snapshot.data as List<CityModel>;
            if(cities == null || cities.length == 0)
              return Center(child: Text('Cannot load city list'),);
            else
              return GridView.builder(
                itemCount: cities.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                  itemBuilder: (context, index){
                    return GestureDetector(
                      onTap: ()=> context.read(selectedCity).state = cities[index],
                      child: Padding(padding: const EdgeInsets.all(8),
                      child: Card(
                        shape: context
                            .read(selectedCity)
                            .state
                            .name == cities[index].name ?
                        RoundedRectangleBorder(side: BorderSide(color: Colors
                            .green,
                            width: 4),
                        borderRadius: BorderRadius.circular(5)) : null,
                        child: Center(child: Text('${cities[index].name}'),),
                      ),),
                    );
                  });
          }
        }
    );
  }

  displaySalon(String name) {
    return FutureBuilder(
        future: getSalonByCity(name),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          else{
            var salons = snapshot.data as List<SalonModel>;
            if(salons == null || salons.length == 0)
              return Center(
                child: Text('Cannot load Salon list'),
              );
            else
              return ListView.builder(
                  itemCount: salons.length,
                  itemBuilder: (context, index){
                    return GestureDetector(
                      onTap: ()=>context.read(selectedSalon).state =
                      salons[index],
                      child: Card(
                        child: ListTile(
                          shape: context
                              .read(selectedSalon)
                              .state
                              .name == salons[index].name ?
                          RoundedRectangleBorder(side: BorderSide(color: Colors
                              .green,
                              width: 4),
                              borderRadius: BorderRadius.circular(5)) : null,
                          leading: Icon(
                            Icons.home_outlined,
                            color: Colors.black,
                          ),
                          trailing: context.read(selectedSalon).state.docId == salons[index].docId
                              ? Icon(Icons.check)
                              : null,
                          title: Text(
                            '${salons[index].name}',
                            style: GoogleFonts.robotoMono(),
                          ),
                          subtitle: Text(
                            '${salons[index].address}',
                            style: GoogleFonts.robotoMono(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                    );
                  });
          }
        }
    );
  }

  displayAppointment(BuildContext context) {
    //Check if user is staff
    return FutureBuilder(
      future: checkStaffOfThisSalon(context),
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator(),);
        else
          {
            var result = snapshot.data as bool;
            if (result)
              return displaySlot(context);
            else
              return Center(
                child: Text('Sorry! You\'re not a staff at this salon.'),
              );
          }
      });
  }

  displaySlot(BuildContext context) {
    var now = context.read(selectedDate).state;
    return Column(
      children: [
        Container(
          color: Color(0xFF008577),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children:[
              Expanded(child:
              Center(child: Padding(padding: const EdgeInsets.all(12),
                child: Column(children: [
                  Text('${DateFormat.MMMM().format(now)}',
                    style: GoogleFonts.robotoMono(color: Colors.white54),), //Month
                  Text('${now.day}',      //Day int
                    style: GoogleFonts.robotoMono(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                  ),
                  Text('${DateFormat.EEEE().format(now)}',    //Day string
                    style: GoogleFonts.robotoMono(color: Colors.white54),),

                ],),),),),
              GestureDetector(onTap: (){
                DatePicker.showDatePicker(context,
                    showTitleActions: true,
                    minTime: DateTime.now(),
                    maxTime: now.add(Duration(days: 31)),
                    onConfirm: (date)=> context.read(selectedDate).state = date); //you can pick date for the next 31 day
              }, child: Padding(
                padding: const EdgeInsets.all(8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.calendar_today, color:Colors.white),
                ),
              ),)
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder(
              future: getMaxAvailableTimeSlot(context.read(selectedDate).state),
              builder: (context,snapshot){
                if(snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator(),);
                else
                {
                  var maxTimeSlot = snapshot.data as int;
                  return  FutureBuilder(
                    future: getBookingSlotOfBarber(
                      context,
                        DateFormat('dd_MM_yyyy')
                            .format(context
                            .read(selectedDate)
                            .state)),
                    builder: (context,snapshot){
                      if(snapshot.connectionState == ConnectionState.waiting)
                        return Center(child: CircularProgressIndicator(),);
                      else{
                        var listTimeSlot = snapshot.data as List <int>;
                        return GridView.builder(
                            itemCount: TIME_SLOT.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3),
                            itemBuilder: (context, index)=> GestureDetector(
                              onTap:
                                  !listTimeSlot.contains(index)
                                  ? null
                                  :  () => processDoneServices(context, index),
                              child:  Card(
                                color:
                                listTimeSlot.contains(index)
                                    ? Colors.white10 :
                                maxTimeSlot > index ? Colors.white60
                                    : context.read(selectedTime).state ==
                                    TIME_SLOT.elementAt(index)
                                    ? Colors.white54
                                    : Colors.white,
                                child: GridTile(
                                  child: Center(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('${TIME_SLOT.elementAt(index)}'),
                                        Text(listTimeSlot.contains(index)
                                            ? 'Full'
                                            : maxTimeSlot > index
                                            ? 'Not Available'
                                            : 'Available')
                                      ],
                                    ),
                                  ),
                                  header: context.read(selectedTime).state == TIME_SLOT.elementAt(index) ? Icon(Icons.check) : null,
                                ),),
                            ));
                      }
                    },
                  );
                }
              }
          ),
        )
      ],
    );
  }

  processDoneServices(BuildContext context, int index) {
    context.read(selectedTimeSlot).state =
        index;
    Navigator.of(context).pushNamed('/doneService');
  }
}