import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:provider/provider.dart';
import 'package:famlicious_app/managers/auth_manager.dart';
import 'package:famlicious_app/views/auth/create_account_view.dart';
import 'package:famlicious_app/views/auth/forgot_password_view.dart';
import 'package:famlicious_app/views/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RegExp emailRegexp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  bool isLoading = false;

  void onAuthResult(bool isSuccessful, BuildContext context) {
    if (isSuccessful) {
      Fluttertoast.showToast(
          msg: "Welcome back to Famlicious!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);

      //move to home view
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => const HomeView()),
              (route) => false);
    } else {
      final errorMessage = Provider.of<AuthManager>(context, listen: false).message;
      Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
          child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Image.asset(
              'assets/logo_header.png',
              width: 130,
              height: 130,
            ),
            const SizedBox(
              height: 35,
            ),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                label: Text('Email'),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Email is required!';
                }

                if (!emailRegexp.hasMatch(value)) {
                  return 'Email is invalid';
                }
              },
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              decoration: const InputDecoration(
                label: Text('Password'),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Password is required!';
                }

                if (value.length < 8) {
                  return 'Password should be 8 characters or more';
                }
              },
            ),
            const SizedBox(
              height: 25,
            ),
            Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const ForgotPasswordView())),
                    child: const Text(
                      'Forgot password? Reset here!',
                      style: TextStyle(color: Colors.grey),
                    ))),
            isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : Column(
                    children: [
                      SignInButton(
                        Buttons.Email,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            bool isSuccessful =
                            await Provider.of<AuthManager>(context,
                                listen: false)
                                .loginUser(
                                email: _emailController.text,
                                password: _passwordController.text);
                            setState(() {
                              isLoading = false;
                            });
                            onAuthResult(isSuccessful, context);
                          } else {
                            //error validation
                            Fluttertoast.showToast(
                                msg: 'Email and Password are required!',
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }
                        },
                      ),
                        SignInButton(
                          Buttons.Google,
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            bool isSuccessful = await Provider.of<AuthManager>(
                                    context,
                                    listen: false)
                                .googleLogin();
                            setState(() {
                              isLoading = false;
                            });
                            onAuthResult(isSuccessful, context);
                          },
                        ),
                        SignInButton(
                          Buttons.Facebook,
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            bool isSuccessful = await Provider.of<AuthManager>(
                                    context,
                                    listen: false)
                                .facebookLogin();
                            setState(() {
                              isLoading = false;
                            });
                            onAuthResult(isSuccessful, context);
                          },
                        ),
                      ]),
            Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const CreateAccountView())),
                    child: const Text(
                      'No account? Create one here!',
                      style: TextStyle(color: Colors.grey),
                    ))),
          ],
        ),
      )),
    );
  }
}
