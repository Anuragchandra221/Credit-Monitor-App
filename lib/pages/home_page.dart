import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credit_monitor/pages/add_person.dart';
import 'package:credit_monitor/pages/person_page.dart';
import 'package:credit_monitor/services/firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Firestore fireStoreService = Firestore();
  // final TextEditingController _textcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Devoos Credit Monitor"),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (ctx) => AddPerson()));
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: TextFormField(decoration: InputDecoration(
          //     hintText: "Search",
          //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
          //   ),),
          // ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: fireStoreService.getPersonStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List creditList = snapshot.data!.docs;
            
                  return Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: ListView.separated(
                      separatorBuilder: (context, index){
                        return SizedBox(height: 5,);
                      },
                      itemCount: creditList.length,
                      itemBuilder: (contenxt, index) {
                        DocumentSnapshot document = creditList[index];
                        String docID = document.id;
                    
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        String creditText = data['name'];
                        var amount = data['total_credit'];
                        DateTime date = data["timestamp"].toDate();
                    
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 8,
                                  offset: Offset(0, 1), // changes position of shadow
                                ),
                              ]
                            ),
                            child: ListTile(
                              onTap: () => {
                                Navigator.of(contenxt).push(MaterialPageRoute(
                                    builder: (ctx) => PersonPage(
                                          docID: docID,
                                          data: data,
                                        )))
                              },
                              title: Text(
                                creditText,
                                style: TextStyle(fontSize: 18),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text("${DateFormat("dd-MM-yy").format(date)}, ${DateFormat("EEEE").format(date)}", style: TextStyle(fontSize: 14),),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.currency_rupee, size: 16,),
                                  Text(
                                    amount.toString(),
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return Text("No Person");
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
