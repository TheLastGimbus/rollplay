import 'package:flutter/material.dart';

import '../router.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Roll-Play"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => router.navigateTo(context, Routes.settings),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            ElevatedButton(
              child: Text("Roll!"),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
