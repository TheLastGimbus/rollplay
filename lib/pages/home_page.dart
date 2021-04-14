import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:rollapi/rollapi.dart' as roll;

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  DateTime begin;
  roll.Request request;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    Widget noRequestWidget() => Text(
          'Go ahead, press the button below to roll a dice!',
          style: t.textTheme.headline4,
        );

    Widget queuedWidget(DateTime eta) {
      return Column(
        children: [
          Text('Your roll is waiting in a queue', style: t.textTheme.bodyText1),
          SizedBox(height: 18),
          if (eta != null)
            Text(
              'Time left: ${eta.difference(DateTime.now()).inSeconds}s',
              style: t.textTheme.headline3,
            ),
          LinearProgressIndicator(),
        ],
      );
    }

    Widget runningWidget(DateTime eta) =>
        Text('Your dice is rolling RIGHT NOW!');

    Widget failedWidget(String message) =>
        Text('Failed :( $message \nTry again');

    Widget finishedWidget(int result) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(result.toString(), style: t.textTheme.headline1),
            Text('Photo of your roll:'),
            SizedBox(height: 36),
            Container(
              constraints: BoxConstraints(maxHeight: 300),
              child: PhotoView(
                tightMode: true,
                imageProvider:
                    NetworkImage('${roll.API_BASE_URL}image/${request.uuid}'),
              ),
            ),
          ],
        );

    Widget rollSwitch(MapEntry<roll.RequestState, dynamic> data) {
      switch (data.key) {
        case roll.RequestState.queued:
          return queuedWidget(data.value as DateTime);
        case roll.RequestState.running:
          return runningWidget(data.value as DateTime);
        case roll.RequestState.failed:
        case roll.RequestState.expired:
          return failedWidget((data.value as Exception)?.toString());
        case roll.RequestState.finished:
          return finishedWidget(data.value);
        default:
          return Text('Error!');
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text("Roll-Play")),
      body: Container(
        padding: EdgeInsets.all(36),
        child: Align(
          alignment: Alignment.topCenter,
          child: request != null
              ? StreamBuilder(
                  stream: request.stateStream,
                  builder: (
                    ctx,
                    AsyncSnapshot<MapEntry<roll.RequestState, dynamic>> snap,
                  ) =>
                      ListView(
                    children: [
                      Center(child: SelectableText(request.uuid)),
                      SizedBox(height: 36),
                      snap.hasData ? rollSwitch(snap.data) : Text('Wait...'),
                    ],
                  ),
                )
              : noRequestWidget(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Roll the dice!'),
        onPressed: () async {
          request = await roll.makeRequest();
          begin = DateTime.now();
          setState(() {});
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
