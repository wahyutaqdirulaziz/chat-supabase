import 'package:chatapp/app.dart';
import 'package:chatapp/chat_page.dart';
import 'package:chatapp/model/profile.dart';
import 'package:flutter/material.dart';

class ListAccountView extends StatefulWidget {
  const ListAccountView({super.key});
  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const ListAccountView(),
    );
  }

  @override
  State<ListAccountView> createState() => _ListAccountViewState();
}

class _ListAccountViewState extends State<ListAccountView> {
  late final Stream<List<Profile>> _profileCache;
  Future<void> _loadProfileCache() async {
    final data = await supabase.from('profiles').select();
    final profile = Profile.fromMap(data);
  }

  @override
  void initState() {
    // TODO: implement initState
    _profileCache = supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((maps) => maps.map((map) => Profile.fromMap(map)).toList());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Users"),
      ),
      body: StreamBuilder<List<Profile>>(
        stream: _profileCache,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final profile = snapshot.data!;
            return profile.isEmpty
                ? const Center(
                    child: Text('Start your conversation now :)'),
                  )
                : ListView.builder(
                    itemCount: profile.length,
                    itemBuilder: (context, index) {
                      final message = profile[index];

                      /// I know it's not good to include code that is not related
                      /// to rendering the widget inside build method, but for
                      /// creating an app quick and dirty, it's fine 😂
                      // _loadProfileCache(message.profileId);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatPage(
                                      id: message.id.toString(),
                                    )),
                          );
                        },
                        child: Card(
                          child: ListTile(
                            title: Text(message.username),
                          ),
                        ),
                      );
                    },
                  );
          } else {
            return preloader;
          }
        },
      ),
    );
  }
}
