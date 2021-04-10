import 'package:flutter/material.dart';

import 'pages/settings_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roll-Play',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

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
        leading: IconButton(
          icon: Icon(Icons.settings),
          // TODO: Change this shit to fluro
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => SettingsPage())),
        ),
      ),
      body: Center(child: Text("Hello there!")),
    );
  }
}
