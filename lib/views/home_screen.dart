import 'dart:developer';
import 'dart:io';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todo_app/controllers/todo_db_helper.dart';
import 'package:todo_app/utils/colours.dart';
import 'package:todo_app/views/add_todo_screen.dart';
import 'package:todo_app/views/home_screen/todo_screen.dart';
import 'package:todo_app/views/pdf_screen.dart';
import 'package:todo_app/views/theme_page.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../utils/globals.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _page = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  PageController pageController = PageController();
  int currentPageVal = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColorLight,
        title: Text(
          "To-Do App",
          style: TextStyle(
            color: colorWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              // delete all data
              await ToDoDBHelper.todoDBHelper.deleteAllData();
            },
            icon: Icon(
              Icons.delete_sweep_outlined,
              color: colorWhite,
            ),
          ),
          IconButton(
            onPressed: () async {
              var pdf = pw.Document();

              pdf.addPage(pw.Page(
                  pageFormat: PdfPageFormat.a4,
                  build: (pw.Context context) {
                    return pw.Center(
                      child: pw.Container(
                        height: 580,
                        width: double.infinity,
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 15),
                          child: pw.ListView.builder(
                            itemCount: pdfTime.length,
                            itemBuilder: (context, i) {
                              return pw.Column(
                                mainAxisSize: pw.MainAxisSize.min,
                                children: [
                                  pw.Row(
                                    children: [
                                      pw.Text(
                                        pdfTime[i],
                                        style: const pw.TextStyle(
                                          fontSize: 10,
                                          decoration: pw.TextDecoration.none,
                                        ),
                                      ),
                                      pw.Text(
                                        "  :  ",
                                        style: const pw.TextStyle(fontSize: 10, decoration: pw.TextDecoration.none),
                                      ),
                                      pw.Text(
                                        pdfTask[i],
                                        style: const pw.TextStyle(
                                          fontSize: 10,
                                          decoration: pw.TextDecoration.none,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ); // Center
                  })); // Page

              // On Flutter, use the [path_provider](https://pub.dev/packages/path_provider) library:
              final output = await getExternalStorageDirectory();
              final file = File("${output!.path}/example.pdf");
              log(output.path, name: "Output : ");
              await file.writeAsBytes(await pdf.save());

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("PDF Download"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: Icon(
              Icons.save_alt_outlined,
              color: colorWhite,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      body: PageView(
        onPageChanged: (val) {
          setState(() {
            _page = val;
          });
        },
        scrollDirection: Axis.horizontal,
        controller: pageController,
        children: const [
          ToDoScreen(),
          AddToDoScreen(),
          ThemePage(),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _page,
        backgroundColor: Theme.of(context).primaryColorLight,
        height: 60,
        color: Theme.of(context).disabledColor,
        items: <Icon>[
          Icon(
            Icons.today_outlined,
            size: 26,
            color: Theme.of(context).dividerColor,
          ),
          Icon(
            Icons.add,
            size: 30,
            color: Theme.of(context).dividerColor,
          ),
          Icon(
            Icons.dark_mode_outlined,
            size: 26,
            color: Theme.of(context).dividerColor,
          ),
        ],
        onTap: (index) {
          setState(() {
            _page = index;
            pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
          });
        },
      ),
    );
  }
}
