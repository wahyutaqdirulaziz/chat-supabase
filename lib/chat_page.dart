import 'dart:async';
import 'dart:io';

import 'package:chatapp/app.dart';
import 'package:chatapp/model/message.dart';
import 'package:chatapp/model/profile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file_plus/open_file_plus.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart';

// ignore: must_be_immutable
/// Page to chat with someone.
///
/// Displays chat bubbles as a ListView and TextField to enter new chat.
class ChatPage extends StatefulWidget {
  String? id;
  String? username;
  ChatPage({
    Key? key,
    this.id,
    this.username,
  }) : super(key: key);

  // static Route<void> route() {
  //   return MaterialPageRoute(
  //     builder: (context) =>  ChatPage(id: ,),
  //   );
  // }

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final Stream<List<Message>> _messagesStream;
  final Map<String, Profile> _profileCache = {};

  @override
  void initState() {
    super.initState();
    final myUserId = supabase.auth.currentUser!.id;
    _messagesStream = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .eq('room_id', widget.id.toString() + myUserId)
        .map((maps) => maps
            .map(
              (map) => Message.fromMap(map: map, myUserId: myUserId),
            )
            .toList());
  }

  Future<void> _loadProfileCache(String profileId) async {
    if (_profileCache[profileId] != null) {
      return;
    }
    final data =
        await supabase.from('profiles').select().eq('id', profileId).single();
    final profile = Profile.fromMap(data);
    setState(() {
      _profileCache[profileId] = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.username.toString())),
      body: StreamBuilder<List<Message>>(
        stream: _messagesStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final messages = snapshot.data!;

            return Column(
              children: [
                Expanded(
                  child: messages.isEmpty
                      ? const Center(
                          child: Text('Start your conversation now :)'),
                        )
                      : ListView.builder(
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];

                            /// I know it's not good to include code that is not related
                            /// to rendering the widget inside build method, but for
                            /// creating an app quick and dirty, it's fine 😂
                            //_loadProfileCache(message.profileId);

                            return _ChatBubble(
                              message: message,
                              profile: _profileCache[message.profileId],
                            );
                          },
                        ),
                ),
                _MessageBar(
                  id: widget.id,
                ),
              ],
            );
          } else {
            return Column(
              children: [
                const Expanded(
                    child: Center(
                  child: Text('Start your conversation now :)'),
                )),
                _MessageBar(
                  id: widget.id,
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

/// Set of widget that contains TextField and Button to submit message
class _MessageBar extends StatefulWidget {
  String? id;
  _MessageBar({Key? key, this.id}) : super(key: key);

  @override
  State<_MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<_MessageBar> {
  late final TextEditingController _textController;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[200],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading: const Icon(Icons.photo),
                              title: const Text('Gallery'),
                              onTap: () {
                                pickImageGallery(widget.id);
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.camera_alt_sharp),
                              title: const Text('Camera'),
                              onTap: () {
                                pickImage(widget.id);
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.book),
                              title: const Text('file'),
                              onTap: () {
                                uploadFile(widget.id);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      });
                },
                child: const CircleAvatar(
                  child: Icon(Icons.attach_file),
                ),
              ),
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  autofocus: true,
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _submitMessage(widget.id),
                child: const Text('Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  FilePickerResult? result;

  Future uploadFile(id) async {
    result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) {
      print("No file selected");
    } else {
      PlatformFile file = result!.files.first;

      // print(file.name);
      // print(file.bytes);
      // print(file.size);
      // print(file.extension);
      // print(file.path);
      setState(() {});
      await supabase.storage
          .from('avantrade-storage-supabase')
          .upload(
            'public/documents/${file.name}',
            File(file.path.toString()),
          )
          .then((value) async {
        print(value);

        final myUserId = supabase.auth.currentUser!.id;
        await supabase.from('messages').insert({
          'profile_id': myUserId,
          'received_id': id,
          'message_type': "doc",
          'content':
              "https://drlqfvktfqzefkwlfrfv.supabase.co/storage/v1/object/public/$value",
          'room_id': widget.id.toString() + myUserId
        });
      });
    }
  }

  File? image;
  Future pickImage(id) async {
    print(id);
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);

      await supabase.storage
          .from('avantrade-storage-supabase')
          .upload(
            'public/${image.name}',
            imageTemp,
          )
          .then((value) async {
        print(value);

        final myUserId = supabase.auth.currentUser!.id;
        await supabase.from('messages').insert({
          'profile_id': myUserId,
          'received_id': id,
          'message_type': "img",
          'content':
              "https://drlqfvktfqzefkwlfrfv.supabase.co/storage/v1/object/public/$value",
          'room_id': widget.id.toString() + myUserId
        });
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickImageGallery(id) async {
    print(id);
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);

      await supabase.storage
          .from('avantrade-storage-supabase')
          .upload(
            'public/${image.name}',
            imageTemp,
          )
          .then((value) async {
        print(value);

        final myUserId = supabase.auth.currentUser!.id;
        await supabase.from('messages').insert({
          'profile_id': myUserId,
          'received_id': id,
          'message_type': "img",
          'content':
              "https://drlqfvktfqzefkwlfrfv.supabase.co/storage/v1/object/public/$value",
          'room_id': widget.id.toString() + myUserId
        });
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitMessage(id) async {
    final text = _textController.text;
    final myUserId = supabase.auth.currentUser!.id;
    if (text.isEmpty) {
      return;
    }
    _textController.clear();
    try {
      await supabase.from('messages').insert({
        'profile_id': myUserId,
        'received_id': id,
        'message_type': "txt",
        'content': text,
        'room_id': widget.id.toString() + myUserId
      });
    } on PostgrestException catch (error) {
      // ignore: use_build_context_synchronously
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      // ignore: use_build_context_synchronously
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }

  Future<void> _submitMessageImage(id, path) async {
    final text = _textController.text;
    final myUserId = supabase.auth.currentUser!.id;
    if (text.isEmpty) {
      return;
    }
    _textController.clear();
    try {
      await supabase.from('messages').insert({
        'profile_id': myUserId,
        'received_id': id,
        'content': path,
        'room_id': widget.id.toString() + myUserId
      });
    } on PostgrestException catch (error) {
      // ignore: use_build_context_synchronously
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      // ignore: use_build_context_synchronously
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    Key? key,
    required this.message,
    required this.profile,
  }) : super(key: key);

  final Message message;
  final Profile? profile;

  @override
  Widget build(BuildContext context) {
    String splitNameDoc(value) {
      List<String> parts = value.split('/');

      // Now, 'parts' contains the split segments
      // You can access specific segments using their indices
      return parts.last.toLowerCase();
    }

    Future<void> downloadFile(url) async {
      print(url);
      final File? file = await FileDownloader.downloadFile(
        url: url,
        onDownloadCompleted: (String path) {
          OpenFile.open(path);
          Get.snackbar("Success", "Download success uhuy");
        },
      );

      print('FILE: ${file?.path}');
    }

    List<Widget> chatContents = [
      if (!message.isMine)
        CircleAvatar(
          child: profile == null
              ? preloader
              : Text(profile!.username.substring(0, 2)),
        ),
      const SizedBox(width: 12),
      Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: message.isMine
                ? Theme.of(context).primaryColor
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: (message.message_type != "doc")
              ? Text(message.content)
              : GestureDetector(
                  onTap: () {
                    downloadFile(message.content);
                  },
                  child: Container(
                    color: Colors.white,
                    child: ListTile(
                      leading: const Icon(Icons.file_copy),
                      title: Text(splitNameDoc(message.content)),
                      trailing: const Icon(Icons.download),
                    ),
                  ),
                ),
        ),
      ),
      const SizedBox(width: 12),
      Text(format(message.createdAt, locale: 'en_short')),
      const SizedBox(width: 60),
    ];
    if (message.isMine) {
      chatContents = chatContents.reversed.toList();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: Row(
        mainAxisAlignment:
            message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: chatContents,
      ),
    );
  }
}
