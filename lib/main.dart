import 'package:famlicious_app/views/home/home_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Famlicious',
      theme: ThemeData(
          iconTheme: const IconThemeData(color: Colors.black),
          scaffoldBackgroundColor: const Color.fromRGBO(249, 251, 252, 1),
          cardColor: Colors.white,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.white,
            titleTextStyle: TextStyle(
                color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          textTheme: const TextTheme(
              bodyText1: TextStyle(color: Colors.black),
              bodyText2: TextStyle(color: Colors.black))
              ),
      darkTheme: ThemeData(
          scaffoldBackgroundColor: Colors.black,
          cardColor: Colors.grey.shade900,
          iconTheme: const IconThemeData(color: Colors.white),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.black,
            titleTextStyle: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          textTheme: const TextTheme(
              bodyText1: TextStyle(color: Colors.white),
              bodyText2: TextStyle(color: Colors.white))),
      themeMode: ThemeMode.system,
      home: const HomeView(),
    );
  }
}
