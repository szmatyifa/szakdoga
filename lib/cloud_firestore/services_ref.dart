

import 'package:barber_shop/model/service_model.dart';
import 'package:barber_shop/state/state_management.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<List<ServiceModel>> getServices(BuildContext context) async{
  var services = List<ServiceModel>.empty(growable: true);
  CollectionReference serviceRef = FirebaseFirestore.instance.collection('Services');
  QuerySnapshot snapshot = await serviceRef.where(
    context.read(selectedSalon).state.docId,isEqualTo:true
  ).get();
  snapshot.docs.forEach((element) {
    var serviceModel = ServiceModel.fromJson(element.data());
    serviceModel.docId = element.id;
    services.add(serviceModel);
  });
  return services;
}