import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/app_service.dart';
import 'package:speedometer/screens/home_screen.dart';
import 'package:speedometer/screens/login_screen.dart';

void main() {
  runApp(MultiProvider(providers: AppService.provideMultiProviders(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speedometer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}
