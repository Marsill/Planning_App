import 'package:flutter/material.dart';
import 'package:planningapp/features/user_auth/present/pages/login_page.dart';
import 'package:planningapp/features/user_auth/present/widget/contain_form.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Signup"),
      ),
      body: Center( 
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Signup", style: TextStyle(
              fontSize: 29, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
              FormContainer(
                hintText: "Username",
                isPasswordField: false,
              ),
              SizedBox(
                height: 20,
              ),
              FormContainer(
                hintText: "Email",
                isPasswordField: false,
              ),
              SizedBox(
                height: 20,
              ),
              FormContainer(
                hintText: "Password",
                isPasswordField: true,
              ),
              SizedBox(               
                height: 20,),
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Center(child: Text("Signup" , style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  SizedBox(
                    width: 5,),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()));
                      },
                      child: Text("Login", style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold),),
                    )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}