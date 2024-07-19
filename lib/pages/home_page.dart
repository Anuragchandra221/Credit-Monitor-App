import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credit_monitor/pages/add_person.dart';
import 'package:credit_monitor/pages/person_page.dart';
import 'package:credit_monitor/services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Firestore fireStoreService = Firestore();
  final TextEditingController _textcontroller = TextEditingController();
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Devoos Credit Monitor"),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>AddPerson()));
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fireStoreService.getPersonStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List creditList = snapshot.data!.docs;
            

            return ListView.builder(
              
              itemCount: creditList.length,
              itemBuilder: (contenxt, index) {
                DocumentSnapshot document = creditList[index];
                String docID = document.id;

                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String creditText = data['name'];
                var amount = data['total_credit'];

                return ListTile(
                  onTap: ()=>{
                    Navigator.of(contenxt).push(MaterialPageRoute(builder: (ctx)=>PersonPage(docID: docID, data: data,)))
                  },
                  // titleAlignment: ListTileTitleAlignment.center,
                  title: Text(creditText),
                  subtitle: Text(amount.toString()),
            
                );
              },
            );
          } else {
            return Text("No credit");
          }
        },
      ),
    );
  }
}
