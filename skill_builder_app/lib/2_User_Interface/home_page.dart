import 'package:flutter/material.dart';
import 'package:skill_builder_app/2_User_Interface/colorpallate.dart';
import "add_skills.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.secondaryCream,

      body: Column(
        children: [
          ListTile(
            leading :Card(
              child: Text("Here is a Card"),
            )
          ),
          IconButton(
            highlightColor: ColorPalette.neutralLightGray,
            color: ColorPalette.primaryNavy,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddSkill()),
              );
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
