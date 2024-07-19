import 'package:credit_monitor/pages/home_page.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    gotoHome();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset("assets/devoos_icon.png", width: 200, height: 200,),
      ),
    );
  }

  Future<void> gotoHome() async {
    await Future.delayed(Duration(seconds: 2));
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx)=>HomePage()));
  }
}
