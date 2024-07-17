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
  final firestoreService = Firestore();
  

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
        child: Text("Hii"),
      ),
    );
  }
}
