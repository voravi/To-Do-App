import 'package:flutter/material.dart';
import 'package:todo_app/utils/globals.dart';

import '../utils/colours.dart';

class PDFScreen extends StatefulWidget {
  const PDFScreen({Key? key}) : super(key: key);

  @override
  State<PDFScreen> createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 580,
        width: double.infinity,
        color: colorWhite,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: ListView.builder(
            itemCount: pdfTime.length,
            itemBuilder: (context, i) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        pdfTime[i],
                        style: TextStyle(fontSize: 10,decoration: TextDecoration.none,),
                      ),
                      Text(
                        "  :  ",
                        style: TextStyle(fontSize: 10,decoration: TextDecoration.none,),
                      ),
                      Text(
                        pdfTask[i],
                        style: TextStyle(fontSize: 10,decoration: TextDecoration.none,),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
