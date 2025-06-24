import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController controller=TextEditingController();

  final CollectionReference users=FirebaseFirestore.instance.collection("users");

  String readname="";

  String documentId='demo-user';

  void createData(){
    users.doc(documentId).set({'name':controller.text});
  }

  void readData()async{
    DocumentSnapshot doc=await users.doc(documentId).get();
    if(doc.exists){
      setState(() {
         readname=doc['name'];
      });


    }
    else{
      setState(() {
            readname="no data found";
      });

    }
  }

  void updatedata(){
    users.doc(documentId).update({"name":controller.text});
  }

  void deletedata(){
    users.doc(documentId).delete();
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}