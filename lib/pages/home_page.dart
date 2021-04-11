import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rollplay/pages/home_cubit.dart';

import '../router.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  etaText(DateTime eta) => eta == null
      ? "Waiting..."
      : "Waiting ${eta.difference(DateTime.now()).inSeconds} seconds...";

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<HomeCubit>(context, listen: true);
    final t = Theme.of(context);
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
            if (bloc.state is FinishedHomeState)
              Text(
                (bloc.state as FinishedHomeState).result.toString(),
                style: t.textTheme.headline1,
              ),
            bloc.state is WaitingHomeState
                ? Text(etaText((bloc.state as WaitingHomeState).eta))
                : ElevatedButton(
                    child: Text("Roll!"),
                    onPressed: () => bloc.roll(),
                  ),
          ],
        ),
      ),
    );
  }
}
