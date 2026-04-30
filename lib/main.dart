import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:odometer/core/app_service.dart';
import 'package:odometer/screens/home_screen.dart';
import 'package:odometer/screens/login_screen.dart';

void main() {
  runApp(MultiProvider(providers: AppService.provideMultiProviders(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'odometer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}
