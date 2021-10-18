

import 'dart:io';

import 'package:flutter/material.dart';
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

  Future selectImage({ImageSource imageSource = ImageSource.camera}) async {
    XFile? selectedFile = await _imagePicker.pickImage(source: imageSource);

    _imageFile = File(selectedFile!.path);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CircleAvatar(
                radius: 65,
                backgroundImage: (_imageFile == null
                    ? const AssetImage('assets/avatar.png')
                    : FileImage(_imageFile!)) as ImageProvider,
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
                                    onPressed: () => selectImage(
                                        imageSource: ImageSource.camera),
                                    icon: const Icon(UniconsLine.camera),
                                    label: const Text('Select from Camera')),
                                TextButton.icon(
                                    onPressed: () => selectImage(
                                        imageSource: ImageSource.gallery),
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
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  label: Text('Email'),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                keyboardType: TextInputType.visiblePassword,
                decoration: const InputDecoration(
                  label: Text('Password'),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              TextButton(
                  onPressed: null,
                  style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context)
                          .buttonTheme
                          .colorScheme!
                          .background),
                  child: Text('Create Account',
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
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
