import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:winest_chatbot/chat/controller/chat_controller.dart';

import '../../common/color.dart';

class ChatView extends GetView<ChatController> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: const Color(0xF0F0F0FF),
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 8.0, top: 6.0, bottom: 6.0),
          child: CircleAvatar(
            child: Text(
              "WC",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blueAccent,
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Winest Chatbot',
              style: TextStyle(fontSize: 16),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.circle,
                  color: Colors.green,
                  size: 10,
                ),
                SizedBox(
                  width: 4,
                ),
                Text(
                  'Online',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(child: Obx(() {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: controller.messages.isEmpty
                  ? const Center(
                      child: Text("No conversations yet"),
                    )
                  : Obx(() {
                      return ListView.builder(
                          itemCount: controller.messages.length,
                          shrinkWrap: true,
                          reverse: true,
                          physics: const BouncingScrollPhysics(),
                          controller: controller.scrollController,
                          itemBuilder: (context, index) {
                            final isUser = 'user' ==
                                controller.messages.elementAt(index).role;
                            return Padding(
                              padding: isUser
                                  ? EdgeInsets.only(
                                      left: size.width * 0.2, top: 6, bottom: 6)
                                  : EdgeInsets.only(
                                      right: size.width * 0.2,
                                      top: 6,
                                      bottom: 6),
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
                                      // nip: BubbleNip.no,
                                      nip: isUser ? BubbleNip.no : BubbleNip.leftBottom,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Text(
                                          controller.messages
                                              .elementAt(index)
                                              .text!,
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
                          });
                    }),
            );
          })),
          Obx(() {
            return !controller.loading.value
                ? const SizedBox.shrink()
                : const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                            strokeWidth: 3,
                          ),
                        ),
                      ],
                    ),
                  );
          }),
          Container(
            padding: const EdgeInsets.only(
                left: 16, right: 16, bottom: 10.0, top: 10.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
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
                          horizontal: 10,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller.msgController,
                                maxLines: 6,
                                minLines: 1,
                                decoration: InputDecoration(
                                  hintText: 'Enter prompt here...',
                                  border: InputBorder.none,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  hintStyle:
                                      const TextStyle(color: Colors.black54),
                                  contentPadding: const EdgeInsets.only(
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
                  child: Obx(() {
                    return controller.hasText.value
                        ? Row(
                            // key: ValueKey<bool>(hasText),
                            children: [
                              const SizedBox(
                                width: 6,
                              ),
                              IconButton.filledTonal(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      CustomColor.blue),
                                ),
                                onPressed: controller.sendMessage,
                                icon: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink();
                  }),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
