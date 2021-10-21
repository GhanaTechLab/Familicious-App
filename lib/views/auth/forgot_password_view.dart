import 'package:famlicious_app/managers/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final RegExp emailRegexp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  final TextEditingController _emailController = TextEditingController();

  bool isLoading = false;

  final AuthManager _authManager = AuthManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
          child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const FlutterLogo(
            size: 130,
          ),
          const SizedBox(
            height: 35,
          ),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
                label: Text('Email'),
                hintText: 'Please provide your email address'),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Email is required!';
              }

              if (!emailRegexp.hasMatch(value)) {
                return 'Email is invalid';
              }
            },
          ),
          const SizedBox(
            height: 25,
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator.adaptive())
              : TextButton(
                  onPressed: () async {
                    if (_emailController.text.isNotEmpty &&
                        emailRegexp.hasMatch(_emailController.text)) {
                      setState(() {
                        isLoading = true;
                      });
                      bool isSent = await _authManager
                          .sendResetLink(_emailController.text);
                      setState(() {
                        isLoading = false;
                      });
                      if (isSent) {
                        //successs
                        Fluttertoast.showToast(
                            msg:
                                "Please check your email for password reset link.",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                            fontSize: 16.0);
                        Navigator.pop(context);
                      } else {
                        //error
                        Fluttertoast.showToast(
                            msg: _authManager.message,
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }
                    } else {
                      Fluttertoast.showToast(
                          msg: 'Email address is required!',
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                  },
                  style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context)
                          .buttonTheme
                          .colorScheme!
                          .background),
                  child: Text('Reset Password',
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          color: Theme.of(context)
                              .buttonTheme
                              .colorScheme!
                              .primary)))
        ],
      )),
    );
  }
}
