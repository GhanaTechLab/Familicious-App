import 'package:provider/provider.dart';
import 'package:famlicious_app/managers/auth_manager.dart';
import 'package:famlicious_app/models/user_model.dart';
import 'package:famlicious_app/views/auth/login_view.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            TextButton.icon(
                onPressed: () async {
                  await Provider.of<AuthManager>(context, listen: false)
                      .signOut()
                      .then((value) =>
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginView()),
                              (route) => false)
                  );
                },
                icon: const Icon(UniconsLine.exit),
                label: const Text('Logout'))
          ],
        ),
        body: StreamBuilder<UserModel?>(
            stream: Provider
                .of<AuthManager>(context, listen: true)
                .currentUserStream
                .stream,
            builder: (context, state) {
              return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage:
                        (state.data?.picture == null)
                            ? const AssetImage("assets/user.png")
                            : Image
                            .network(state.data!.picture!)
                            .image,
                        radius: 50,
                      ),
                      Text(state.data?.name ?? "no name"),
                      Text(state.data?.email ?? "no email"),
                      Text(state.data?.userId ?? "no user"),
                    ],
                  )
              );
            }
        )
    );
  }
}
