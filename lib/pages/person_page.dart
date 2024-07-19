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
  

  void openNoteBox(String person_id, String credit_id, double amount, String items) {
    final _amountcontroller = TextEditingController(text: amount.toString());
  final _itemcontroller = TextEditingController(text: items);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: IntrinsicHeight(
            child: Column(
              children: [
                TextFormField(
                  controller: _itemcontroller,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "Items",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20,),
                TextFormField(
                  controller: _amountcontroller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Amount",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if(person_id==null){
                  // fireStoreService.addCredit({"name": _textcontroller.text});
                }else{
                  // firestoreService.updateCredit(docID, {"name": _textcontroller.text});
                }

                print("text  ${_amountcontroller.text} ${_itemcontroller.text}");
                final _amount = double.tryParse(_amountcontroller.text);
                Map credit_data = {
                  "amount": _amount,
                  "items": _itemcontroller.text
                };
                firestoreService.updateCredit(person_id, credit_id, credit_data);

                _amountcontroller.clear();
                _itemcontroller.clear();
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
        title: Text("${widget.data["name"]}"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
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
            print("UserSnapshot $userSnapshot");
            var total_credit = userSnapshot.data?['total_credit'];
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (userSnapshot.hasError) {
              return Center(
                child: Text("Error"),
              );
            } else if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return Center(
                child: Text("No user data found"),
              );
            } else {
              List<String> creditIds =
                  List<String>.from(userSnapshot.data!['credit'] ?? []);
              if (creditIds.isEmpty) {
                return Center(
                  child: Text("No credits found"),
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: Center(
                          child: Text(
                        "$total_credit",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold
                        ),
                      )),
                      width: 200.0,
                      height: 200.0,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromARGB(255, 194, 223, 180)
                                    .withOpacity(0.7),
                                blurRadius: 2.0,
                                offset: Offset(2.0, 2.0))
                          ]),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder(
                      stream: firestoreService.getUserCreditsStream(creditIds),
                      builder: (context, creditSnapshot) {
                        if (creditSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (creditSnapshot.hasError) {
                          return Center(
                            child: Text("Error"),
                          );
                        } else {
                          List<QueryDocumentSnapshot> creditDocs =
                              creditSnapshot.data!.docs;
                          return ListView.builder(
                            itemCount: creditDocs.length,
                            itemBuilder: (context, index) {
                              var creditData = creditDocs[index].data()
                                  as Map<String, dynamic>;
                              return ListTile(
                                title: Text(creditData["amount"].toString()),
                                subtitle: creditData.containsKey("items")?Text(creditData["items"]):Text(''),
                                trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => {
                                          openNoteBox(widget.docID, creditDocs[index].id, creditData["amount"], creditData["items"])
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: (){
                                          print("creditData ${creditDocs[index].id}");
                                          firestoreService.deleteCredit(widget.docID, creditDocs[index].id);
                                        },
                                      ),
                                    ]),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
