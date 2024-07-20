import 'package:credit_monitor/services/firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AddPerson extends StatelessWidget {
  AddPerson({super.key});

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final Firestore firestoreService = Firestore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Phone Number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                maxLines: 4,
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: "Address",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),

                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  
                  style: ButtonStyle(
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                      )
                    ),
                    backgroundColor:
                        const WidgetStatePropertyAll<Color>(Color.fromARGB(255, 221, 165, 203)),
                    foregroundColor:
                        const WidgetStatePropertyAll<Color>(Colors.white),
                  ),
                  onPressed: () {
                    addPerson(context);
                  },
                  child: const Text("Enter"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addPerson(BuildContext ctx) async {
    final _name = _nameController;
    final _phone = _phoneController;
    final _address = _addressController;
    if (_name.text.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        margin: EdgeInsets.all(10),
        content: Text("Name cannot be empty"),
      ));
    } else if (_phone.text.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        margin: EdgeInsets.all(10),
        content: Text("Phone number cannot be empty"),
      ));
    } else if (_phone.text.length != 10) {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        margin: EdgeInsets.all(10),
        content: Text("Enter a valid phone number"),
      ));
    } else{
      final data;
      if(_address.text.isEmpty){
        data = {
          "name": _name.text,
          "phone": _phone.text,
        };
      }else{
        data = {
          "name": _name.text,
          "phone": _phone.text,
          "address": _address.text,
        };
      }
      final Map result = await firestoreService.addNewPerson(data);
      if(result.containsKey("error")){
        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        margin: EdgeInsets.all(10),
        content: Text("Phone number already exists"),
      ));
      }else{
        Navigator.of(ctx).pop();
      }
    }
  }
}
