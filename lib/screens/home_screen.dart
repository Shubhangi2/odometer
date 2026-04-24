import 'package:flutter/material.dart';
import 'package:speedometer/core/app_colors.dart';
import 'package:speedometer/screens/form_screen.dart';
import 'package:speedometer/screens/shared_widgets/custom_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg_image.jpg'),
              fit: BoxFit.cover,
              opacity: 0.1,
            ),
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Text('Hello', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, height: 1)),
              SizedBox(height: 12),
              Text(
                'Shubhangi Jadhav',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1),
              ),
              SizedBox(height: 24),
              Row(spacing: 24, children: [actionCardWidget(), actionCardWidget()]),
              SizedBox(height: 24),
              CustomButton(
                text: "Start Journey",
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FormScreen()));
                },
              ),
              SizedBox(height: 24),
              Text("Jopurney in progress - Tap to end", style: TextStyle(fontSize: 14)),
              SizedBox(height: 12),
              CustomButton(
                text: "End Journey",
                onPressed: () {},
                color: Colors.red,
                borderColor: const Color.fromARGB(255, 241, 95, 85),
              ),

              SizedBox(height: 24),
              Text("Recent journies", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget actionCardWidget() {
    return Expanded(
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: const Color(0x1023BBDD),
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: const Color(0xFF23BCDD), width: 1.0),
        ),
      ),
    );
  }
}
