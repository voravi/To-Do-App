import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/app_theme_provider.dart';

class ThemePage extends StatefulWidget {
  const ThemePage({Key? key}) : super(key: key);

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  @override
  Widget build(BuildContext context) {
    return SimpleOutlinedButton(
      bgColor: Theme.of(context).backgroundColor,
      onPressed: () async {

      },
      outlineColor: Colors.transparent,
      child: Text("Tap To change Theme",style: TextStyle(color: Theme.of(context).dividerColor,fontSize: 25,),)
    );
  }
}


class SimpleOutlinedButton extends StatelessWidget {
  const SimpleOutlinedButton(
      {this.child,
        this.textColor,
        required this.bgColor,
        this.outlineColor,
        required this.onPressed,
        this.borderRadius = 0,
        this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        Key? key})
      : super(key: key);
  final Widget? child;
  final Function onPressed;
  final double borderRadius;
  final Color? outlineColor;
  final Color? textColor;
  final EdgeInsetsGeometry padding;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    ThemeData currentTheme = Theme.of(context);
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor ?? outlineColor ?? currentTheme.primaryColor,
        padding: padding,
        backgroundColor: bgColor,
        textStyle: TextStyle(color: currentTheme.primaryColor),
        side: BorderSide(color: outlineColor ?? currentTheme.primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      onPressed: onPressed as void Function()?,
      child: child!,
    );
  }
}
