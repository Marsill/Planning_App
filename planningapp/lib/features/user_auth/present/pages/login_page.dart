import 'package:flutter/material.dart';
import 'package:planningapp/features/user_auth/present/pages/signup_page.dart';
import 'package:planningapp/features/user_auth/present/widget/contain_form.dart';
import 'package:planningapp/features/user_auth/present/pages/home_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        backgroundColor: Colors.cyan,
      ),
      body: Center( 
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Login", style: TextStyle(
              fontSize: 29, fontWeight: FontWeight.bold),
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
              SizedBox(               // the login button structure 
                height: 20,),
              GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                  },
                child:Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.cyan,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Center(child: Text("Login" , style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ),
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  SizedBox(
                    width: 5,),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SignupPage()));
                      },
                      child: Text("Sign Up", style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold),),
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