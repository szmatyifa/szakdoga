import 'package:cloud_firestore/cloud_firestore.dart';

class BarberModel{
  String name, docId;
  double rating;
  int ratingTimes;

  DocumentReference reference;

  BarberModel();

  BarberModel.fromJson(Map<String,dynamic> json){
    name = json['name'];
    rating = double.parse(json['rating'] == null ? '0' : json['rating'].toString());
    ratingTimes = int.parse(json['ratingTimes'] == null ? '0' : json['ratingTimes'].toString());
  }

  Map<String,dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['rating'] = this.rating;
    data['ratingTimes'] = this.ratingTimes;
    return data;
  }
}