import 'dart:io';

import 'package:digital_pay/digital_pay.dart';
import 'package:flutter/material.dart';

//Secure all hhtp request with [https]
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
//END secure http

//Change your main App
void main() async {
  //intialize http requests
  HttpOverrides.global = MyHttpOverrides();
  return runApp(const MyApp());
}
//END Change

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DIGITAL PAY',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DIGITAL PAY"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: TextButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.orange),
                padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 50))),
            onPressed: () {
              //Launching the checkout request
              DigitalPay.checkout(
                      context: context,
                      accessToken: "MY_ACCESS_TOKEN",
                      amount: 10)
                  .then((result) {
                //result of the request
                print(result);
              });
            },
            child: const Text(
              "Payer",
              style: TextStyle(color: Colors.white),
            )),
      ),
    );
  }
}
