import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Firestore{
  //get
  final CollectionReference data = FirebaseFirestore.instance.collection("Person");
  final CollectionReference credit = FirebaseFirestore.instance.collection("credit");

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
  Future<void> addCredit(String docID, Map obj) async{
    DocumentReference creditRef = await credit.add(obj);
    String creditID = creditRef.id;

    return data.doc(docID).update({
      "credit": FieldValue.arrayUnion([creditID]),
      "timestamp": Timestamp.now()
    });
  }
 
  Stream<DocumentSnapshot> getUsers (docID){
    return FirebaseFirestore.instance.collection("Person").doc(docID).snapshots();
  }
  //read

  Stream<QuerySnapshot> getPersonStream(){
    final personStream = data.orderBy("timestamp", descending: true).snapshots();
    return personStream;
  }



  Future<List<String>> getUserCreditIDs(docID) async{
    List<dynamic> creditIDs;
    DocumentSnapshot personSnapShot = await FirebaseFirestore.instance.collection("Person").doc(docID).get();
    creditIDs = personSnapShot['credit'];

    return creditIDs.cast<String>();
  
  }

  Stream<DocumentSnapshot> getUserDocumentStream(String docID){
    return FirebaseFirestore.instance.collection("Person").doc(docID).snapshots();
  }

  Stream<QuerySnapshot> getUserCreditsStream(List<String> creditIDs){
    return FirebaseFirestore.instance.collection("credit").where(FieldPath.documentId, whereIn: creditIDs).snapshots();
  }

  

  // Future<List<DocumentSnapshot>> getUserCredits(docID) async{
  //   List<dynamic> creditIDs;
  //   DocumentSnapshot personSnapShot = await FirebaseFirestore.instance.collection("Person").doc(docID).get();
  //   creditIDs = personSnapShot['credit'];
  //   print("credit $creditIDs");
  //   creditIDs.map((e)=>e.toString()).toList();
  //   List<DocumentSnapshot> creditDocs = [];

  //   for (String id in creditIDs){
  //     DocumentSnapshot creditDoc = await FirebaseFirestore.instance.collection("credit").doc(id).get();
  //     if(creditDoc.exists){
  //       creditDocs.add(creditDoc);
  //     }
  //   }
  //   return creditDocs;
    
  // }

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