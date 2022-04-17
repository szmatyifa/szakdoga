import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel{
  String docId,
      barberId,
      barberName,
      cityBook,
      customerId,
      customerName,
      customerPhone,
      salonAddress,
      salonId,
      salonName,
      services,
      time;

  double totalPrice;
  bool done;
  int slot, timeStamp;

  DocumentReference reference;

  BookingModel(
    {
      this.docId,
      this.barberId,
      this.barberName,
      this.cityBook,
      this.customerId,
      this.customerName,
      this.customerPhone,
      this.salonAddress,
      this.salonId,
      this.salonName,
      this.services,
      this.time,
      this.done,
      this.slot,
      this.totalPrice,
      this.timeStamp
    }
  );

  BookingModel.fromJson(Map<String,dynamic> json){
    barberId = json['barberId'];
    barberName = json['barberName'];
    cityBook = json['cityBook'];
    customerId = json['customerId'];
    customerName = json['customerName'];
    customerPhone = json['customerPhone'];
    salonAddress = json['salonAddress'];
    salonName = json['salonName'];
    salonId = json['salonId'];
    services = json['services'];
    time = json['time'];
    done = json['done'] as bool;
    slot = int.parse(json['slot'] == null ? '-1' : json['slot'].toString());
    totalPrice = double.parse(json['totalPrice'] == null ? '0' : json['totalPrice'].toString());
    timeStamp  = int.parse(json['timeStamp'] == null ? '0' : json['timeStamp'].toString());

  }

  Map<String,dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['barberId'] = this.barberId;
    data['barberName'] = this.barberName;
    data['cityBook'] = this.cityBook;
    data['customerId'] = this.customerId;
    data['customerPhone'] = this.customerPhone;
    data['customerName'] = this.customerName;
    data['salonId'] = this.salonId;
    data['salonName'] = this.salonName;
    data['salonAddress'] = this.salonAddress;
    data['time'] = this.time;
    data['done'] = this.done;
    data['slot'] = this.slot;
    data['timeStamp'] = this.timeStamp;

    return data;
  }
}
