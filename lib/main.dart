import 'package:flutter/material.dart';
import 'package:rollplay/router.dart';

void main() {
  initRouter();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roll-Play',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: Routes.home,
      onGenerateRoute: router.generator,
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
          onPressed: () => router.navigateTo(context, Routes.settings),
        ),
      ),
      body: Center(child: Text("Hello there!")),
    );
  }
}
