import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'main_page.dart';

Future<void> main() async {
  await dotenv.load(fileName: "assets/config/.env");
  runApp(ReviewApp());
}

// 페이지 시작
class ReviewApp extends StatelessWidget {
  const ReviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main Page',
      home: MainPage(),
    );
  }
}
