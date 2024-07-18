import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credit_monitor/pages/add_credit.dart';
import 'package:credit_monitor/services/firestore.dart';
import 'package:flutter/material.dart';

class PersonPage extends StatefulWidget {
  const PersonPage({super.key, required this.docID, required this.data});
  final String docID;
  final Map data;
  @override
  State<PersonPage> createState() => _PersonPageState();
}

class _PersonPageState extends State<PersonPage> {
  final Firestore firestoreService = Firestore();
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.data["name"]}"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async  {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => AddCredit(
                  docID: widget.docID,
                  name: widget.data["name"],
                )));
                },
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: firestoreService.getUserDocumentStream(widget.docID),
          builder: (context, userSnapshot) {
            if(userSnapshot.connectionState == ConnectionState.waiting){
              return Center(child: CircularProgressIndicator());
            }
            else if(userSnapshot.hasError){
              return Center(child: Text("Error"),);
            }

            else if(!userSnapshot.hasData || !userSnapshot.data!.exists){
              return Center(child: Text("No user data found"),);
            }
            else{
              List<String> creditIds = List<String>.from(userSnapshot.data!['credit']??[]);
              if(creditIds.isEmpty){
                return Center(child: Text("No credits found"),);
              }

              return StreamBuilder(stream: firestoreService.getUserCreditsStream(creditIds), builder: (context, creditSnapshot){
                if(creditSnapshot.connectionState == ConnectionState.waiting){
                  return Center(child: CircularProgressIndicator(),);
                }
                else if(creditSnapshot.hasError){
                  return Center(child: Text("Error"),);
                }else{
                  List<QueryDocumentSnapshot> creditDocs = creditSnapshot.data!.docs;
                  return ListView.builder(itemCount: creditDocs.length, itemBuilder: (context, index){
                    var creditData = creditDocs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(creditData["amount"]),
                      subtitle: Text(creditData["items"]),
                    );
                  },);
                }
              },);
            }

          },
        ),
      ),
    );
  }

}
