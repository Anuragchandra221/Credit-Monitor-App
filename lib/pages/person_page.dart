import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credit_monitor/pages/add_credit.dart';
import 'package:credit_monitor/services/firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PersonPage extends StatefulWidget {
  const PersonPage({super.key, required this.docID, required this.data});
  final String docID;
  final Map data;
  @override
  State<PersonPage> createState() => _PersonPageState();
}

class _PersonPageState extends State<PersonPage> {
  final Firestore firestoreService = Firestore();

  List<bool> _expanded = List.generate(50, (index) => false);

  void openNoteBox(
      String person_id, String credit_id, double amount, String items) {
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
                SizedBox(
                  height: 20,
                ),
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
                if (person_id == null) {
                  // fireStoreService.addCredit({"name": _textcontroller.text});
                } else {
                  // firestoreService.updateCredit(docID, {"name": _textcontroller.text});
                }

                print(
                    "text  ${_amountcontroller.text} ${_itemcontroller.text}");
                final _amount = double.tryParse(_amountcontroller.text);
                Map credit_data = {
                  "amount": _amount,
                  "items": _itemcontroller.text
                };
                firestoreService.updateCredit(
                    person_id, credit_id, credit_data);

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
                      width: 200.0,
                      height: 200.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          // borderRadius: BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(
                                  0, 1), // changes position of shadow
                            ),
                          ]),
                      child: Center(
                          child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.currency_rupee),
                          Text(
                            "$total_credit",
                            style: const TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )),
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
                              var date = creditData["timestamp"].toDate();
                              // print(creditData);
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 8,
                                          offset: Offset(0,
                                              1), // changes position of shadow
                                        ),
                                      ]),
                                  child: Column(
                                    children: [
                                      creditData.containsKey("items")
                                          ? ExpansionTile(
                                              title: Text(
                                                "${DateFormat("dd-MM-yy").format(date)}, ${DateFormat("EEEE").format(date)}",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              subtitle: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 6.0),
                                                child: Row(children: [
                                                  Icon(
                                                    Icons.currency_rupee,
                                                    size: 16,
                                                  ),
                                                  Text(
                                                    creditData["amount"]
                                                        .toString(),
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                ]),
                                              ),
                                              children: [
                                                ListTile(
                                              title: Text(
                                                creditData["items"],
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              trailing: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.edit,
                                                        size: 24,
                                                      ),
                                                      onPressed: () => {
                                                        openNoteBox(
                                                            widget.docID,
                                                            creditDocs[index]
                                                                .id,
                                                            creditData[
                                                                "amount"],
                                                            creditData["items"])
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        size: 24,
                                                      ),
                                                      onPressed: () {
                                                        print(
                                                            "creditData ${creditDocs[index].id}");
                                                        firestoreService
                                                            .deleteCredit(
                                                                widget.docID,
                                                                creditDocs[
                                                                        index]
                                                                    .id);
                                                      },
                                                    ),
                                                  ]),
                                            ),
                                              ],
                                            )
                                          : ListTile(
                                              title: Text(
                                                "${DateFormat("dd-MM-yy").format(date)}, ${DateFormat("EEEE").format(date)}",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              subtitle: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 6.0),
                                                child: Row(children: [
                                                  Icon(
                                                    Icons.currency_rupee,
                                                    size: 16,
                                                  ),
                                                  Text(
                                                    creditData["amount"]
                                                        .toString(),
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                ]),
                                              ),
                                              trailing: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.edit,
                                                        size: 24,
                                                      ),
                                                      onPressed: () => {
                                                        openNoteBox(
                                                            widget.docID,
                                                            creditDocs[index]
                                                                .id,
                                                            creditData[
                                                                "amount"],
                                                            creditData["items"])
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        size: 24,
                                                      ),
                                                      onPressed: () {
                                                        print(
                                                            "creditData ${creditDocs[index].id}");
                                                        firestoreService
                                                            .deleteCredit(
                                                                widget.docID,
                                                                creditDocs[
                                                                        index]
                                                                    .id);
                                                      },
                                                    ),
                                                  ]),
                                            ),
                                    ],
                                  ),
                                ),
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
