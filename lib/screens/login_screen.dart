import 'package:flutter/material.dart';
import 'package:speedometer/core/app_colors.dart';
import 'package:speedometer/screens/home_screen.dart';
import 'package:speedometer/screens/shared_widgets/custom_button.dart';
import 'package:speedometer/screens/shared_widgets/custom_text_form_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg_image.jpg'),
            fit: BoxFit.cover,
            opacity: 0.04,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Welcome Back', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('Login to your account', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 52),
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 24,
                children: [
                  CustomTextFormField(
                    controller: userNameController,
                    label: "Username",
                    hintText: "Enter username",
                    inputFormatters: [],
                    onValidate: (value) {},
                    textInputType: TextInputType.text,
                  ),
                  CustomTextFormField(
                    controller: passwordController,
                    label: "password",
                    hintText: "Enter password",
                    inputFormatters: [],
                    onValidate: (value) {},
                    textInputType: TextInputType.text,
                  ),
                ],
              ),
            ),
            SizedBox(height: 52),
            CustomButton(
              text: "Login",
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
