import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';
import '../cubits/auth_cubits.dart';

class RegisterPage extends StatefulWidget {

  final void Function()? togglePages;

  const RegisterPage({super.key, required this.togglePages});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  final confirmpwController = TextEditingController();

  //register button pressed
  void register() {
    //prepare info
    final String name = nameController.text;
    final String email = emailController.text;
    final String pw = pwController.text;
    final String confirmpw = confirmpwController.text;

    //auth cubit
    final authCubit = context.read<AuthCubit>();

    if(email.isNotEmpty && pw.isNotEmpty && confirmpw.isNotEmpty && name.isNotEmpty){
      if(pw == confirmpw){
        authCubit.register(name, email, pw);
      }

      //if dont match
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Passwords don't match!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    //fields are empty -> then display error
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all fields!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    pwController.dispose();
    confirmpwController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // logo
              Image.asset(
                'assets/images/studymate_logo.png',
                width: 200,
                height: 200,
              ),

              // const SizedBox(height: 25,),
              //name of the app
              Text("Create an account",
                style: TextStyle(
                  fontSize: 25,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),


              const SizedBox(height: 25,),

              //email txtfld
              MyTextfield(
                controller: nameController,
                hintText: "Username",
                obscureText: false,
              ),

              const SizedBox(height: 10,),

              //email txtfld
              MyTextfield(
                controller: emailController,
                hintText: "Email",
                obscureText: false,
              ),

              const SizedBox(height: 10,),

              //forgot pw
              MyTextfield(
                controller: pwController,
                hintText: "Password",
                obscureText: true,
              ),

              const SizedBox(height: 10,),

              //confirm passw
              MyTextfield(
                controller: confirmpwController,
                hintText: "Confirm Password",
                obscureText: true,
              ),

              const SizedBox(height: 10,),


              const SizedBox(height: 25,),

              //login button
              MyButton(
                onTap: register ,
                text: "Sign Up",
              ),

              const SizedBox(height: 25,),

              //other sign in option

              //register button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Text(
                    "Already have an account?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.togglePages,
                    child: Text(
                      "Login now",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
