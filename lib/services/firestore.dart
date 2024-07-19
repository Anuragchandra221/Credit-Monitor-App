import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Firestore{
  //get
  final CollectionReference data = FirebaseFirestore.instance.collection("Person");
  final CollectionReference credit = FirebaseFirestore.instance.collection("credit");

  Future<Map> addNewPerson(Map person) async{
    final same_phone = await FirebaseFirestore.instance.collection("Person").where("phone", isEqualTo: person["phone"]).get();
    if(same_phone.docs.isNotEmpty){
      return {
        "error": "Phone no already exists"
      };
    }
    if(person.containsKey("address")){
      data.add({
        "name": person["name"],
        "phone": person["phone"],
        "addres": person["address"],
        "total_credit": 0.0,
        "credit": [],
        "timestamp": Timestamp.now()
      });
    }else{
      data.add({
        "name": person["name"],
        "phone": person["phone"],
        "total_credit": 0.0,
        "credit": [],
        "timestamp": Timestamp.now()
      });
    }
    return {
      "msg": "success"
    };
  }

  //create
  Future<void> addCredit(String docID, Map obj) async{
    // Map object = {
    //   "amount": obj["amount"],
    //   "items": obj["items"],
    //   "timestamp": Timestamp.now()
    // };
    DocumentReference creditRef;
    print("obj $obj");
    if(obj.containsKey("items")){
      creditRef = await credit.add({
        "amount": obj["amount"],
        "items": obj["items"],
        "timestamp": Timestamp.now()
      });
    }else{
      creditRef = await credit.add({
      "amount": obj["amount"],
      "timestamp": Timestamp.now()
    });
    }
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
    return FirebaseFirestore.instance.collection("credit").orderBy("timestamp", descending: true).where(FieldPath.documentId, whereIn: creditIDs).snapshots();
  }

  

  //update
  Future<void> updateCredit(String person_docID, String credit_id, Map credit_data) async{

    await FirebaseFirestore.instance.runTransaction((transaction) async{
      DocumentSnapshot personSnapShot = await FirebaseFirestore.instance.collection("Person").doc(person_docID).get();
      var amount = personSnapShot["total_credit"];
      DocumentSnapshot creditSnapshot = await FirebaseFirestore.instance.collection("credit").doc(credit_id).get();
      var credit = creditSnapshot['amount'];
      amount = amount - credit + credit_data['amount'];
      transaction.update(data.doc(person_docID), {
        "total_credit": amount
      });
      transaction.update(FirebaseFirestore.instance.collection("credit").doc(credit_id), {
        "amount": credit_data["amount"],
        "items": credit_data["items"],
        "timestamp": Timestamp.now()
      });
    });

  }

  

  //delete
  Future<void> deleteCredit(String person_docID, String credit_id) async {

    await FirebaseFirestore.instance.runTransaction((transaction) async{
      DocumentSnapshot personSnapShot = await FirebaseFirestore.instance.collection("Person").doc(person_docID).get();
      var amount = personSnapShot["total_credit"];
      DocumentSnapshot creditSnapshot = await FirebaseFirestore.instance.collection("credit").doc(credit_id).get();
      var credit = creditSnapshot["amount"];
      List creditIds = personSnapShot["credit"];

      amount = amount - credit;
      transaction.update(data.doc(person_docID), {
        "total_credit": amount,
        "credit": FieldValue.arrayRemove([credit_id])
      });
      transaction.delete(FirebaseFirestore.instance.collection("credit").doc(credit_id));
    });
  }


}