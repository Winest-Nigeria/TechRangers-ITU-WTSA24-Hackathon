import 'dart:convert';

import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
// import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;

// import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
// import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:uuid/uuid.dart';

import 'common/color.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Hive.initFlutter();
  // await Hive.openBox("chat");

  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const ChatPage(),
  ));
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String userId = 'user_id';
  String chatbot_id = 'winest_chatbot';

  bool hasText = false, isLoading = false;

  final _msgController = TextEditingController();
  List _messages = [];

  void getGeneratedMsg(String msg) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse("https://5b0d-103-19-91-143.ngrok-free.app/query"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "query": msg,
        }),
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Parse the response body
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        _addMessage(responseData);
      } else {}
    } catch (e) {}
    setState(() {
      isLoading = false;
    });
  }

  void _handleSendPressed() {
    final msg = _msgController.text.trim();
    getGeneratedMsg(msg);
    _addMessage({'id': userId, 'response': msg});
    _msgController.clear();
  }

  void _addMessage(Map message) {
    setState(() {
      _messages.insert(0, message);
    });
    // Hive.box('chat').add(message);
  }

  @override
  void initState() {
    super.initState();
    // final messages = Hive.box('chat').values;
    // if (messages.isNotEmpty) {
    //   _messages.addAll(messages);
    // }
    _msgController.addListener(() {
      final isNotEmpty = _msgController.text.isNotEmpty;
      if (isNotEmpty != hasText) {
        setState(() {
          hasText = isNotEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Column(
        children: [
          AppBar(
            title: const Text('Winest Chatbot'),
            backgroundColor: Colors.blueAccent,
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: _messages.isEmpty
                ? const Center(
                    child: Text("No conversations yet"),
                  )
                : ListView.builder(
                    itemCount: _messages.length,
                    reverse: true,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final isUser = userId == _messages[index]['id'];
                      return Padding(
                        padding: userId == _messages[index]['id']
                            ? EdgeInsets.only(
                                left: size.width * 0.2, top: 6, bottom: 6)
                            : EdgeInsets.only(
                                right: size.width * 0.2, top: 6, bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isUser)
                              const Icon(
                                Icons.smart_toy_outlined,
                              ),
                            if (!isUser)
                              const SizedBox(
                                width: 4,
                              ),
                            Expanded(
                              child: Bubble(
                                padding: const BubbleEdges.all(0),
                                radius: const Radius.circular(8),
                                color: isUser
                                    ? CustomColor.blue
                                    : CustomColor.lightBlue,

                                //   nip: nextMessageInGroup
                                // ? BubbleNip.no
                                //     : _user.id != message.author.id
                                // ? BubbleNip.leftBottom
                                //     : BubbleNip.rightBottom,
                                nip: BubbleNip.no,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    _messages[index]['response'],
                                    style: TextStyle(
                                        color: isUser
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
          )),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    Icons.smart_toy_outlined,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  SizedBox.square(
                    dimension: 23,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      strokeWidth: 3,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: CustomColor.lightBlue,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _msgController,
                                maxLines: 6,
                                minLines: 1,
                                decoration: const InputDecoration(
                                  hintText: 'Enter prompt here...',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(color: Colors.black54),
                                  contentPadding: EdgeInsets.only(
                                      right: 6, top: 8, bottom: 8),
                                ),
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16),
                              ),
                            ),
                          ],
                        ))),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: const Offset(0, 0),
                    ).animate(animation);

                    return ClipRect(
                      child: SlideTransition(
                        position: offsetAnimation,
                        child: SizeTransition(
                          sizeFactor: animation,
                          axis: Axis.horizontal,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: hasText
                      ? Row(
                          key: ValueKey<bool>(hasText),
                          children: [
                            const SizedBox(
                              width: 6,
                            ),
                            IconButton.filledTonal(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(CustomColor.blue),
                              ),
                              onPressed: _handleSendPressed,
                              icon: const Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
