import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rollplay/pages/home_cubit.dart';
import 'package:rollplay/router.dart';

void main() {
  initRouter();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (ctx) => HomeCubit()),
      ],
      child: MaterialApp(
        title: 'Roll-Play',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        initialRoute: Routes.home,
        onGenerateRoute: router.generator,
      ),
    );
  }
}