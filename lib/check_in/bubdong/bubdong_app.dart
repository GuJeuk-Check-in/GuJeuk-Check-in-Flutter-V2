import 'package:flutter/material.dart';

class BubdongApp extends StatelessWidget {
  const BubdongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '법동 체크인',
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: Text('법동 체크인'))),
    );
  }
}
