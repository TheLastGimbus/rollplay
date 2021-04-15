import 'dart:async';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:rollapi/rollapi.dart' as roll;
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  DateTime begin;
  roll.Request request;
  DateTime _lastStateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    Widget noRequestWidget() => Text(
          'Go ahead, press the button below to roll a dice!',
          style: t.textTheme.headline4,
        );

    Widget requestingWidget() => Column(
          children: [
            Text('Rolling...', style: t.textTheme.headline3),
            SizedBox(height: 36),
            CircularProgressIndicator(),
          ],
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

    Future<T> minDelayFuture<T>(Future<T> future, Duration minDelay) async =>
        (await Future.wait([Future.delayed(minDelay), future]))[1];

    Stream<T> minDelayStream<T>(Stream<T> stream, Duration minDelay) =>
        stream.asyncMap<T>(
          (e) async {
            var state = await minDelayFuture<T>(
              Future.value(e),
              _lastStateTime.add(minDelay).difference(DateTime.now()),
            );
            _lastStateTime = DateTime.now();
            return state;
          },
        );

    return Scaffold(
      appBar: AppBar(
        title: Text("Roll-Play"),
        centerTitle: true,
        actions: [
          // ignore: deprecated_member_use
          FlatButton(
            colorBrightness: Brightness.dark,
            child: Text('What is this?? \u{1F517}'),
            onPressed: () =>
                launch('https://github.com/TheLastGimbus/Roll-API'),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(36),
        child: Align(
          alignment: Alignment.topCenter,
          child: begin == null
              ? noRequestWidget()
              : request == null
                  ? requestingWidget()
                  : StreamBuilder(
                      stream:
                          minDelayStream<MapEntry<roll.RequestState, dynamic>>(
                        request.stateStream,
                        Duration(seconds: 1),
                      ),
                      builder: (
                        ctx,
                        AsyncSnapshot<MapEntry<roll.RequestState, dynamic>>
                            snap,
                      ) =>
                          ListView(
                        children: [
                          Center(child: SelectableText(request.uuid)),
                          SizedBox(height: 36),
                          Center(
                            child: snap.hasData
                                ? rollSwitch(snap.data)
                                : Text('Wait...'),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Roll the dice!'),
        onPressed: () async {
          showSnack(String text) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(text)));
          try {
            begin = DateTime.now();
            request = null;
            setState(() {});
            request = await minDelayFuture(
              roll.makeRequest().timeout(Duration(seconds: 8)),
              Duration(seconds: 3),
            );
          } on roll.RateLimitException catch (e) {
            print(e);
            showSnack(
              'You rolled to many times!' +
                  (e.limitReset != null
                      ? '\nTry again in ${e.limitReset.difference(DateTime.now()).inSeconds} seconds'
                      : ''),
            );
          } on roll.ApiUnavailableException catch (e) {
            print(e);
            var t = 'API is currently unavailable :(';
            if (e.message?.isNotEmpty ?? false) t += '\n' + e.message;
            showSnack(t);
          } on roll.ApiException catch (e) {
            print(e);
            showSnack('Something went wrong: $e\nTry again');
          } on TimeoutException catch (e) {
            print(e);
            showSnack("Can't reach the API! Try again later");
          } catch (e) {
            print(e);
            showSnack('Some error :/\n$e');
          } finally {
            // request wasn't finished because of some error
            if (begin != null && request == null) {
              // Clear the begin to set state to initial
              begin = null;
            }
            setState(() {});
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
