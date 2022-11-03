import '../views/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'appRoutes.dart';

Map<String, Widget Function(BuildContext)> routes = {
  AppRoutes().homePage: (context) => const HomePage(),
};
