import 'dart:io';

import 'package:flutter/material.dart';

import 'HomePage.dart';
import 'package:desktop_window/desktop_window.dart';

Future testWindowFunctions() async {
  Size size = await DesktopWindow.getWindowSize();
  print(size);
  await DesktopWindow.setWindowSize(Size(500,500));

  await DesktopWindow.setMinWindowSize(Size(400,400));
  await DesktopWindow.setMaxWindowSize(Size(800,800));

  await DesktopWindow.resetMaxWindowSize();
  await DesktopWindow.toggleFullScreen();
  bool isFullScreen = await DesktopWindow.getFullScreen();
  await DesktopWindow.setFullScreen(true);
  await DesktopWindow.setFullScreen(false);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(Platform.isWindows){
    await DesktopWindow.setMinWindowSize(Size(400,600));
    await DesktopWindow.setMaxWindowSize(Size(900,720));
  }


  runApp(SqliteApp());
}

class SqliteApp extends StatefulWidget {
  const SqliteApp({Key? key}) : super(key: key);

  @override
  State<SqliteApp> createState() => _SqliteAppState();
}

class _SqliteAppState extends State<SqliteApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}
