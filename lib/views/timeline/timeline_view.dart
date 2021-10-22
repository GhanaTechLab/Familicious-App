import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famlicious_app/managers/post_manager.dart';
import 'package:famlicious_app/views/timeline/create_post_view.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:unicons/unicons.dart';

class TimelineView extends StatelessWidget {
  TimelineView({Key? key}) : super(key: key);

  final PostManager _postManager = PostManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Timeline'),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreatePostView())),
              icon: Icon(
                UniconsLine.plus_square,
                color: Theme.of(context).iconTheme.color,
              ))
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>?>>(
          stream: _postManager.getAllPosts(),
          builder: (context, snapshot) {
            return ListView.separated(
                itemBuilder: (context, index) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      snapshot.data == null) {
                    return const Center(
                        child: CircularProgressIndicator.adaptive());
                  }

                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.data == null) {
                    return const Center(child: Text('No data available'));
                  }

                  return Card(
                    elevation: 0,
                    color: Theme.of(context).cardColor,
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StreamBuilder<Map<String, dynamic>?>(
                              stream: _postManager
                                  .getUserInfo(snapshot.data!.docs[index]
                                      .data()!['user_uid'])
                                  .asStream(),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState ==
                                        ConnectionState.waiting &&
                                    userSnapshot.data == null) {
                                  return const Center(
                                      child:
                                          LinearProgressIndicator());
                                }

                                if (userSnapshot.connectionState ==
                                        ConnectionState.done &&
                                    userSnapshot.data == null) {
                                  return const ListTile();
                                }
                                return ListTile(
                                  contentPadding: const EdgeInsets.all(0),
                                  leading: CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(
                                        userSnapshot.data!['picture']!),
                                  ),
                                  title: Text(userSnapshot.data!['name'],
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600)),
                                  subtitle: Text(
                                      timeago.format(
                                          snapshot.data!.docs[index]
                                              .data()!['createdAt']
                                              .toDate(),
                                          allowFromNow: true),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2!
                                          .copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.grey)),
                                  trailing: IconButton(
                                      onPressed: null,
                                      icon: Icon(
                                        Icons.more_horiz,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      )),
                                );
                              }),
                          snapshot.data!.docs[index]
                                  .data()!['description']!
                                  .isEmpty
                              ? const SizedBox.shrink()
                              : Text(
                                  snapshot.data!.docs[index]
                                      .data()!['description']!,
                                  textAlign: TextAlign.left,
                                ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              snapshot.data!.docs[index].data()!['image_url']!,
                              height: 200,
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                      onPressed: null,
                                      icon: Icon(UniconsLine.thumbs_up,
                                          color: Theme.of(context)
                                              .iconTheme
                                              .color)),
                                  IconButton(
                                      onPressed: null,
                                      icon: Icon(UniconsLine.comment_lines,
                                          color: Theme.of(context)
                                              .iconTheme
                                              .color))
                                ],
                              ),
                              IconButton(
                                  onPressed: null,
                                  icon: Icon(
                                    UniconsLine.telegram_alt,
                                    color: Theme.of(context).iconTheme.color,
                                  ))
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
                itemCount:
                    snapshot.data == null ? 0 : snapshot.data!.docs.length);
          }),
    );
  }
}
