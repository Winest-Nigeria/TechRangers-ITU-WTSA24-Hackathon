import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:winest_chatbot/chat/view/chat_view.dart';
import 'package:winest_chatbot/common/color.dart';

import 'chat/binding/chat_binding.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await GetStorage.init();

  runApp(GetMaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: CustomColor.blue),
      useMaterial3: true,
    ),
    getPages: [
      GetPage(name: '/', page: () => ChatView(), binding: ChatBinding()),
    ],
  ));
}

