import 'package:dba/pages/home_page.dart';
import 'package:dba/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'db/database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => AppDatabase()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Промоутер',
        theme: basicTheme(),
        home: HomePage(),
      ),
    );
  }
}

