import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../settings.dart' as prefs;

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(null);

  Future<void> roll() async {
    print('Getting new roll...');
    emit(WaitingHomeState());
    final sp = await SharedPreferences.getInstance();
    final baseUrl =
        sp.getString(prefs.Key.API_BASE_URL) ?? prefs.Default.API_BASE_URL;
    try {
      // 1. Hit the roll/ endpoint
      print('Calling roll/ ...');
      final rollUri = Uri.parse(baseUrl + 'roll/');
      final rollRes = await http.get(rollUri);
      if (rollRes.statusCode != 200)
        throw HttpException('Response code != 200', uri: rollUri);
      final uuid = rollRes.body;
      print('Got uuid: $uuid');
      // uuid != null indicates that we got the roll/
      emit(WaitingHomeState(uuid: uuid));

      final infoUri = Uri.parse("${baseUrl}info/$uuid/");
      // Empty initial json to handle in while statement
      Map<String, dynamic> json = {'result': null};
      while (json['result'] == null) {
        final delay = max((json['eta'] as num ?? 0) / 2, 1).toInt();
        print('Delay $delay seconds...');
        await Future.delayed(Duration(seconds: delay));

        // 2. Keep pinging info/ until get result
        final infoRes = await http.get(infoUri);
        if (infoRes.statusCode != 200)
          throw HttpException('Response code != 200', uri: rollUri);
        print(infoRes.body);
        json = jsonDecode(infoRes.body);
        print('Got info/ json: $json');
        // If it's already expired then something is not right :/
        if (json['status'] == 'EXPIRED' || json['status'] == 'FAILED')
          throw HttpException('Request was failed', uri: rollUri);

        // Update the eta - it may change during the waiting
        emit(
          WaitingHomeState(
            uuid: uuid,
            eta: DateTime.now().add(
              Duration(seconds: (json['eta'] as num).toInt()),
            ),
          ),
        );
      }
      print('Finished! Final json: $json');
      emit(
        FinishedHomeState(
          uuid: uuid,
          result: json['result'],
          imageUrl: '${baseUrl}image/$uuid/',
          analImageUrl: '${baseUrl}anal-image/$uuid/',
          expireTime: DateTime.now().add(
            Duration(seconds: (json['ttl'] as num).toInt()),
          ),
        ),
      );
    } catch (e) {
      print(e);
      emit(FailedHomeState(e: e));
    }
  }
}

abstract class HomeState {}

class EmptyHomeState extends HomeState {}

class WaitingHomeState extends HomeState {
  final String uuid;
  final DateTime eta;

  WaitingHomeState({
    this.uuid,
    this.eta,
  });
}

class FinishedHomeState extends HomeState {
  final String uuid;
  final int result;
  final String imageUrl;
  final String analImageUrl;
  final DateTime expireTime;

  FinishedHomeState({
    this.uuid,
    this.result,
    this.imageUrl,
    this.analImageUrl,
    this.expireTime,
  });
}

class FailedHomeState extends HomeState {
  final dynamic e;

  FailedHomeState({this.e});
}
