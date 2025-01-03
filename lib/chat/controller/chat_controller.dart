import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:winest_chatbot/services/gemini.dart';

import '../../models/message.dart';

import 'package:get/get.dart';

class ChatController extends GetxController {
  final messages = <Message>[].obs;
  final loading = false.obs;
  final hasText = false.obs;
  final msgController = TextEditingController();
  final scrollController = ScrollController();
  late GetStorage _box;

  @override
  void onInit() {
    super.onInit();
    _box = GetStorage();
    messages.value = getSavedMessage();
    msgController.addListener(() {
      final isNotEmpty = msgController.text.isNotEmpty;
      if (isNotEmpty != hasText.value) {
        hasText.value = isNotEmpty;
      }
    });
  }

  void sendMessage() async {
    scrollController.jumpTo(scrollController.position.minScrollExtent);
    loading.value = true;
    messages.insert(0, Message(
      role: 'user',
      text: msgController.text.trim(),
    ));
    msgController.clear();
    try {
      final message = await GeminiService.getResponse(getGeminiPrompt());
      messages.insert(0, message);
      // Cache messages
      saveMessage(messages.map((e) => e.toJson()).toList());
    } catch (e) {
      Get.log(e.toString());
      msgController.text = messages.removeLast().text!;
    } finally {
      loading.value = false;
    }
  }

  void saveMessage(List messages) {
    _box.write('messages', messages);
  }

  List<Message> getSavedMessage() {
    final messages = _box.read('messages') as List?;
    return messages?.map((e) => Message.fromJson(e)).toList() ?? [];
  }

  String getGeminiPrompt() {
    return json.encode({
      "contents": [...messages.map((e) => e.toJson())],
      "systemInstruction": {
        "role": "user",
        "parts": [
          {
            "text":
                "You are a knowledgeable chatbot specializing in 5G, autonomous networks, and AI-native networks.\n\nOnly respond to queries related to your specialization\nProvide concise and informative answers to user questions about these technologies.\nExplain complex concepts clearly and avoid jargon whenever possible.\nUse examples and analogies to illustrate key points.\nStay up-to-date on the latest advancements and research in these fields.\nBe helpful and friendly in your interactions with users.\n\nExample:\nUser: \"What is the difference between 4G and 5G?\"\nChatbot: \"5G is the fifth-generation mobile network technology, succeeding 4G. Key differences include significantly faster speeds, lower latency, and the ability to connect many more devices simultaneously. 5G enables applications like self-driving cars, remote surgery, and augmented reality that were not feasible with 4G."
          }
        ]
      },
      "generationConfig": {
        "temperature": 0,
        "topK": 64,
        "topP": 0.95,
        "maxOutputTokens": 8192,
        "responseMimeType": "text/plain"
      }
    });
  }

  @override
  void onClose() {
    msgController.dispose();
    super.onClose();
  }
}
