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
  void openNoteBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: TextField(
            controller: _textcontroller,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if(docID==null){
                  // fireStoreService.addCredit({"name": _textcontroller.text});
                }else{
                  fireStoreService.updateCredit(docID, {"name": _textcontroller.text});
                }

                _textcontroller.clear();
                Navigator.pop(context);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
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

                return ListTile(
                  onTap: ()=>{
                    Navigator.of(contenxt).push(MaterialPageRoute(builder: (ctx)=>PersonPage(docID: docID, data: data,)))
                  },
                  // titleAlignment: ListTileTitleAlignment.center,
                  title: Text(creditText),
                
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: ()=>{},
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: ()=>{},
                    ),
                    ]
                  ),
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
