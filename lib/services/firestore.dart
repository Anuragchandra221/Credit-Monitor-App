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
        "total_credit": 0,
        "credit": [],
        "timestamp": Timestamp.now()
      });
    }else{
      return data.add({
        "name": person["name"],
        "phone": person["phone"],
        "total_credit": 0,
        "credit": [],
        "timestamp": Timestamp.now()
      });
    }
  }

  //create
  Future<void> addCredit(String docID, Map obj) async{
    DocumentReference creditRef = await credit.add(obj);
    String creditID = creditRef.id;

    DocumentReference personRef = data.doc(docID);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // print("transaction 0");
      DocumentSnapshot personSnapShot = await transaction.get(personRef);
      // print("transaction");
      var person = personSnapShot.data() as Map<String, dynamic>;
      print("person ${person["total_credit"]}");
      var current = person["total_credit"];
      print("Current $current");
      var updated = current + obj['amount'];
      print("person $current $updated");
      transaction.update(personRef, {
        "credit": FieldValue.arrayUnion([creditID]),
        "total_credit": updated,
        "timestamp": Timestamp.now()
      });
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
    print("Hi0");
    return FirebaseFirestore.instance.collection("Person").doc(docID).snapshots();
  }

  Stream<QuerySnapshot> getUserCreditsStream(List<String> creditIDs){
    return FirebaseFirestore.instance.collection("credit").where(FieldPath.documentId, whereIn: creditIDs).snapshots();
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