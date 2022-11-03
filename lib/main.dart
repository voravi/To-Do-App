import 'package:provider/provider.dart';
import 'package:todo_app/utils/colours.dart';

import '/utils/appRoutes.dart';
import '/utils/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'controllers/app_theme_provider.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
      ],
      builder:(context,_) => MaterialApp(
        themeMode: (Provider.of<ThemeProvider>(context).obj.isDark) ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(
          backgroundColor: Colors.grey[50],
          primaryColorLight: primaryColor,
          secondaryHeaderColor: secondaryColor,
          dividerColor: Colors.black.withOpacity(0.7),
          disabledColor: Colors.white,
        ),
        darkTheme: ThemeData(
          backgroundColor: Colors.black,
          primaryColorLight: Colors.amber,
          dividerColor: Colors.white,
          secondaryHeaderColor: Colors.white.withOpacity(0.9),
          disabledColor: Colors.black87,),
        debugShowCheckedModeBanner: false,
        title: "To-Do App",
        //home: HomePage(),
        initialRoute: AppRoutes().homePage,
        routes: routes,
      ),
    );
  }
}
