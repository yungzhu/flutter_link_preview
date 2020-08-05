import 'package:flutter/material.dart';
import 'package:flutter_link_preview/flutter_link_preview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _controller;
  @override
  void initState() {
    _controller = TextEditingController(
        text:
            "https://click.mz.simba.taobao.com/necpm?spm=a21bo.2017.201874-sales.8&eadt=31&p=&s=1991808525&k=474&e=SUxTD2ulfJ5TFDV3rFI8BlK40VEcAoMovTuXabZA%2BAaarHBh9smeTBrqp3eVTYClsTwhFTeYaozeztuUDszO1FgHmAqQVjLSe%2FOrboKQAI6PpKhWr01Y8SJwZsBnSjuqFPSCea13zvAgC0RSbE%2FTh3Cqj9SdrwCuF9LuAUXZc5HV06n%2Bwtfba9d3eW%2FPtbGEAEu4lGxvE97wBINwKSmcCkPdqyBLazyLPVQ%2FK8QboOJiDfm78MTmvM03e7RjlIKRhKgcqbVsE3MTH5rpzxz5FAoG881ZVrCTOxzeBTKecP3c2Za6oY7rfyMt0UA75jRDsgDY5tsnHWpa6r1xhrEc5Uh9oSqtI3ZubF9GYLHa%2B%2BMU%2FRMr4SL38oc21nzUNDakQIPqx%2FLJpWbEMU6K2hg%2BjTe01qn1888GxKcv3BebcWGKtI40xIZ%2FgbM0mBuBbEKzlamjiOpfV6gRlhxN4wjJ8g%3D%3D");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controller,
                    ),
                  ),
                  RaisedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text("get"),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 500),
                child: FlutterLinkPreview(
                  url: _controller.value.text,
                  key: ValueKey(_controller.value.text),
                  titleStyle: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
