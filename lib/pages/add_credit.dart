import 'package:credit_monitor/services/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddCredit extends StatelessWidget {
  AddCredit({super.key, required this.docID, required this.name});
  final String docID;
  final String name;
  final _amountController = TextEditingController();
  final _itemsController = TextEditingController();

  final fireStoreService = Firestore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Credit to $name")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                maxLines: 4,
                controller: _itemsController,
                decoration: const InputDecoration(
                  hintText: "Items",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Amount",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: const ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll<Color>(Colors.green),
                    foregroundColor:
                        MaterialStatePropertyAll<Color>(Colors.white),
                  ),
                  onPressed: () {
                    addCredit(context);
                  },
                  child: const Text("Add"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void addCredit(BuildContext context){
    if(_amountController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        margin: EdgeInsets.all(10),
        content: Text("Amount cannot be empty"),
      ));
    }else{
      final obj;
      if(_itemsController.text.isEmpty){
        obj = {
          "amount": _amountController.text
        };
      }else{
        obj = {
          "items": _itemsController.text,
          "amount": _amountController.text
        };
      }
      fireStoreService.addCredit(docID, obj);
      Navigator.pop(context, true);
    }
  }
}