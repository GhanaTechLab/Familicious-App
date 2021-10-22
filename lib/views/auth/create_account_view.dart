import 'dart:io';

import 'package:famlicious_app/managers/auth_manager.dart';
import 'package:famlicious_app/utilities/utils.dart';
import 'package:famlicious_app/views/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unicons/unicons.dart';

class CreateAccountView extends StatefulWidget {
  const CreateAccountView({Key? key}) : super(key: key);

  @override
  State<CreateAccountView> createState() => _CreateAccountViewState();
}

class _CreateAccountViewState extends State<CreateAccountView> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  File? _imageFile;

  final RegExp emailRegexp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  final AuthManager _authManager = AuthManager();

  bool isLoading = false;

  Future selectImage({ImageSource imageSource = ImageSource.camera}) async {
    XFile? selectedFile = await _imagePicker.pickImage(source: imageSource);

    File? croppedFile = await myImageCropper(selectedFile!.path);

    setState(() {
      _imageFile = croppedFile;
    });
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
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(90),
                  child: _imageFile == null
                      ? Image.asset(
                          'assets/avatar.png',
                          width: 130,
                          height: 130,
                          fit: BoxFit.contain,
                        )
                      : Image.file(
                          _imageFile!,
                          width: 130,
                          height: 130,
                          fit: BoxFit.contain,
                        ),
                ),
              ),
              TextButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return SizedBox(
                            height: 100,
                            child: Column(
                              children: [
                                TextButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      selectImage(
                                          imageSource: ImageSource.camera);
                                    },
                                    icon: const Icon(UniconsLine.camera),
                                    label: const Text('Select from Camera')),
                                TextButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      selectImage(
                                          imageSource: ImageSource.gallery);
                                    },
                                    icon: const Icon(UniconsLine.picture),
                                    label: const Text('Select from Gallery'))
                              ],
                            ),
                          );
                        });
                  },
                  icon: const Icon(
                    UniconsLine.camera,
                    color: Colors.grey,
                  ),
                  label: Text(
                    'Select Profile Picture',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(color: Colors.grey),
                  )),
              const SizedBox(
                height: 35,
              ),
              TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  label: Text('Full Name'),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Full Name is required!';
                  }
                },
              ),
              const SizedBox(height: 15),
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
              isLoading
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : TextButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate() &&
                            _imageFile != null) {
                          setState(() {
                            isLoading = true;
                          });
                          //all good
                          String name = _nameController.text;
                          String email = _emailController.text;
                          String password = _passwordController.text;

                          //call createNewUser method/func
                          bool isCreated = await _authManager.createNewUser(
                              name: name,
                              email: email,
                              password: password,
                              imageFile: _imageFile!);

                          setState(() {
                            isLoading = false;
                          });
                          if (isCreated) {
                            //new user successfully created
                            Fluttertoast.showToast(
                                msg: "Welcome!, $name",
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
                            //error occurred
                            Fluttertoast.showToast(
                                msg: _authManager.message,
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }
                        } else if (_formKey.currentState!.validate() &&
                            _imageFile == null) {
                          //image was not selected
                          Fluttertoast.showToast(
                              msg: "Please select your Profile picture",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } else {
                          // validation failed
                          Fluttertoast.showToast(
                              msg:
                                  "Please check Input field(s) & Profile picture",
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
                      child: Text('Create Account',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(
                                  color: Theme.of(context)
                                      .buttonTheme
                                      .colorScheme!
                                      .primary)))
            ],
          ),
        ),
      ),
    );
  }
}
