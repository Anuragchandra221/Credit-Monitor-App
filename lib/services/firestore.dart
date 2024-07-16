import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Firestore{
  //get
  final CollectionReference data = FirebaseFirestore.instance.collection("Person");

  Future<void> addNewPerson(Map person){
    if(person.containsKey("address")){
      return data.add({
        "name": person["name"],
        "phone": person["phone"],
        "addres": person["address"],
        "credit": [],
        "timestamp": Timestamp.now()
      });
    }else{
      return data.add({
        "name": person["name"],
        "phone": person["phone"],
        "credit": [],
        "timestamp": Timestamp.now()
      });
    }
  }

  //create
  Future<void> addCredit(String docID, Map obj){
    return data.doc(docID).update({
      "credit": FieldValue.arrayUnion([obj])
    });
  }

  //read
  Stream<QuerySnapshot> getPersonStream(){
    final personStream = data.orderBy("timestamp", descending: true).snapshots();
    return personStream;
  }

  //update
  Future<void> updateCredit(String docID, Map note){
    return data.doc(docID).update({
      "name": note['name'],
      'timestamp': Timestamp.now()
    });
  }

  //delete
  Future<void> deleteCredit(String docID){
    return data.doc(docID).delete();
  }


}