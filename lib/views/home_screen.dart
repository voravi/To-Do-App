import 'dart:developer';
import 'dart:io';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'package:todo_app/controllers/todo_db_helper.dart';
import 'package:todo_app/utils/colours.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../controllers/app_theme_provider.dart';
import '../modals/todo.dart';
import '../utils/globals.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _page = 0;
  int? id;
  int pdfDeleteId = 0;
  PageController pageController = PageController();
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  Future<List<ToDo>>? todoData;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController taskController = TextEditingController();
  String task = "";
  String startTime = "12:00 PM";
  String endTime = "15:00 PM";
  bool isUpdate = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    todoData = ToDoDBHelper.todoDBHelper.fetchAllData();
  }

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
          IconButton(onPressed: (){
            Provider.of<ThemeProvider>(context, listen: false).changeTheme();
          }, icon: Icon(Icons.brightness_1_outlined,size: 20,),),
          IconButton(
            onPressed: () async {
              // delete all data
              await ToDoDBHelper.todoDBHelper.deleteAllData();
              todoData = ToDoDBHelper.todoDBHelper.fetchAllData();
              pdfTime.clear();
              pdfTask.clear();
              setState(() {});
            },
            icon: Icon(
              Icons.delete_sweep_outlined,
              color: colorWhite,
            ),
          ),
          IconButton(
            onPressed: () async {
              var pdf = pw.Document();
              pdf.addPage(
                pw.Page(
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
                  },
                ),
              ); // Page
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
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).backgroundColor,
            child: FutureBuilder(
                future: todoData,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("ERROR : ${snapshot.error}"),
                    );
                  } else if (snapshot.hasData) {
                    List<ToDo>? todos = snapshot.data;
                    return ListView.builder(
                      itemCount: todos!.length,
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Slidable(
                                startActionPane: ActionPane(
                                  motion: const DrawerMotion(),
                                  children: [
                                    SlidableAction(
                                      icon: Icons.delete_sweep_outlined,
                                      label: 'Delete',
                                      backgroundColor: colorList[i][4],
                                      onPressed: (context) async {
                                        log("${todos[i].id}",name: "Id is:");
                                        int res = await ToDoDBHelper.todoDBHelper.deleteSingleData(id: todos[i].id!);
                                        todoData = ToDoDBHelper.todoDBHelper.fetchAllData();
                                        pdfTime.removeAt(i + 1);
                                        pdfTask.removeAt(i + 1);
                                        log(res.toString());
                                        setState(() {});
                                      },
                                    ),
                                    SlidableAction(
                                      icon: Icons.update,
                                      label: 'Update',
                                      backgroundColor: const Color(0xFF0392CF),
                                      onPressed: (context) {
                                        _page = 1;
                                        pageController.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
                                        id = todos[i].id;
                                        startTime = todos[i].startTime;
                                        endTime = todos[i].endTime;
                                        taskController.text = todos[i].myToDo;
                                        isUpdate = true;
                                        pdfDeleteId = i;
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: colorList[i],
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 25,
                                            width: 25,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: colorWhite,
                                            ),
                                            child: Center(
                                              child: Text("${i + 1}"),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            todos[i].startTime,
                                            style: const TextStyle(color: colorWhite, fontWeight: FontWeight.w600, fontSize: 20),
                                          ),
                                          const Text(
                                            " TO ",
                                            style: TextStyle(color: colorWhite, fontWeight: FontWeight.w600, fontSize: 20),
                                          ),
                                          Text(
                                            todos[i].endTime,
                                            style: const TextStyle(color: colorWhite, fontWeight: FontWeight.w600, fontSize: 20),
                                          ),
                                          Spacer(),
                                          GestureDetector(
                                            onTap: () {
                                              _page = 1;
                                              pageController.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
                                              id = todos[i].id;
                                              startTime = todos[i].startTime;
                                              endTime = todos[i].endTime;
                                              taskController.text = todos[i].myToDo;
                                              isUpdate = true;
                                              pdfDeleteId = i;
                                              setState(() {});
                                            },
                                            child: Icon(
                                              Icons.fast_forward_rounded,
                                              color: colorWhite,
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: colorList[i],
                                  ),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  todos[i].myToDo,
                                  style: const TextStyle(
                                    color: colorWhite,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                }),
          ),

          //Todo: ScreenTwo
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).backgroundColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 200,
                        width: 200,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).primaryColorLight,
                            width: 17,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: secondaryColor,
                              width: 17,
                            ),
                          ),
                          child: Center(
                            child: IconButton(
                              onPressed: () async {
                                TimeRange? result = await showTimeRangePicker(
                                  context: context,
                                  strokeWidth: 4,
                                  ticks: 12,
                                  ticksOffset: 2,
                                  ticksLength: 8,
                                  handlerRadius: 8,
                                  ticksColor: Colors.grey,
                                  rotateLabels: false,
                                  labels: ["24 h", "3 h", "6 h", "9 h", "12 h", "15 h", "18 h", "21 h"].asMap().entries.map((e) {
                                    return ClockLabel.fromIndex(idx: e.key, length: 8, text: e.value);
                                  }).toList(),
                                  labelOffset: 30,
                                  padding: 55,
                                  labelStyle: const TextStyle(fontSize: 18, color: Colors.black),
                                  start: const TimeOfDay(hour: 12, minute: 0),
                                  end: const TimeOfDay(hour: 15, minute: 0),
                                  disabledTime: TimeRange(startTime: const TimeOfDay(hour: 19, minute: 0), endTime: const TimeOfDay(hour: 10, minute: 0)),
                                  clockRotation: 180.0,
                                );
                                setState(() {
                                  startTime = "${result!.startTime.format(context)} ${result.startTime.period.name.toUpperCase()}";
                                  endTime = "${result.endTime.format(context)} ${result.endTime.period.name.toUpperCase()}";
                                });
                              },
                              icon: Icon(
                                Icons.add,
                                size: 35,
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        children: [
                          Text(
                            "Task Duration: ",
                            style: TextStyle(
                              color: Colors.grey.withOpacity(0.8),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            startTime,
                            style: TextStyle(
                              color: Theme.of(context).dividerColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            " TO ",
                            style: TextStyle(
                              color: Colors.grey.withOpacity(0.8),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            endTime,
                            style: TextStyle(
                              color: Theme.of(context).dividerColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: taskController,
                        textInputAction: TextInputAction.done,
                        onSaved: (val) {
                          setState(() {
                            task = val!;
                          });
                        },
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "Enter Some Task";
                          }
                          return null;
                        },
                        style: TextStyle(color: Theme.of(context).dividerColor),
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Theme.of(context).dividerColor),
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).dividerColor)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).dividerColor)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).dividerColor)),
                          hintText: "Enter Task..",
                          labelText: "Task",
                          alignLabelWithHint: true,
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () async {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              if (isUpdate) {
                                if (id != null) {
                                  pdfTime.removeAt(pdfDeleteId);
                                  pdfTask.removeAt(pdfDeleteId);
                                  int res =
                                      await ToDoDBHelper.todoDBHelper.updateData(data: ToDo(startTime: startTime, endTime: endTime, myToDo: task), id: id);
                                  pdfTime.add("$startTime TO $endTime");
                                  pdfTask.add(taskController.text);
                                }
                              } else {
                                await ToDoDBHelper.todoDBHelper.insertData(data: ToDo(startTime: startTime, endTime: endTime, myToDo: task));
                                pdfTime.add("$startTime TO $endTime");
                                pdfTask.add(taskController.text);
                              }
                              _page = 0;
                              pageController.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
                              todoData = ToDoDBHelper.todoDBHelper.fetchAllData();
                            }
                          },
                          child: Ink(
                            height: 55,
                            width: 200,
                            decoration: BoxDecoration(
                              color: Theme.of(context).dividerColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              height: 55,
                              width: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: DottedBorder(
                                color: Theme.of(context).primaryColorLight,
                                strokeWidth: 1,
                                borderType: BorderType.RRect,
                                dashPattern: [7, 7],
                                radius: Radius.circular(20),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).disabledColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          // color: Theme.of(context).disabledColor,
                                          )),
                                  child: Center(
                                    child: (isUpdate)
                                        ? Text(
                                            "Update Task",
                                            style: TextStyle(color: Theme.of(context).dividerColor, fontWeight: FontWeight.bold, fontSize: 15),
                                          )
                                        : Text(
                                            "+ Add Task",
                                            style: TextStyle(color: Theme.of(context).dividerColor, fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // //Todo: Third Page
          // ThemePage(),
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
          // Icon(
          //   Icons.dark_mode_outlined,
          //   size: 26,
          //   color: Theme.of(context).dividerColor,
          // ),
        ],
        onTap: (index) {
          setState(() {
            _page = index;
            pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
            isUpdate = false;
          });
        },
      ),
    );
  }
}
