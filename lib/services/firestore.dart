import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Firestore{
  //get
  final CollectionReference data = FirebaseFirestore.instance.collection("credit");

  //create
  Future<void> addCredit(Map note){
    return data.add({
      "name": note['name'],
      "timestamp": Timestamp.now(),
    });
  }

  //read
  Stream<QuerySnapshot> getCreditStream(){
    final creditStream = data.orderBy("timestamp", descending: true).snapshots();
    return creditStream;
  }

  //update

  //delete
}