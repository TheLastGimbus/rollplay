import 'package:flutter/material.dart';
import 'package:rollapi/rollapi.dart' as roll;
import 'package:shared_preferences/shared_preferences.dart';

import '../settings.dart' as prefs;

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SharedPreferences sp;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) => setState(() => sp = value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          padding: EdgeInsets.all(36),
          child: sp == null ? Text("Wait...") : settings(),
        ),
      ),
    );
  }

  Widget settings() {
    return ListView(
      children: [
        Text("Roll-API base URL:"),
        TextFormField(
          key: UniqueKey(),
          initialValue: sp.getString(prefs.Key.API_BASE_URL) ??
              prefs.Default.API_BASE_URL,
          decoration: InputDecoration(hintText: prefs.Default.API_BASE_URL),
          onChanged: (str) {
            if (!str.endsWith('/')) str += '/';
            roll.API_BASE_URL = str;
            sp.setString(prefs.Key.API_BASE_URL, str);
          },
        ),
        ElevatedButton(
          child: Text('Reset settings'),
          onPressed: () async {
            await sp.clear();
            setState(() {});
          },
        )
      ],
    );
  }
}
