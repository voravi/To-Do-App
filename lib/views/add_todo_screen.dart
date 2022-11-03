import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'package:todo_app/controllers/todo_db_helper.dart';
import 'package:todo_app/modals/todo.dart';
import 'package:todo_app/utils/globals.dart';
import 'dart:developer';
import '../../utils/colours.dart';
import 'home_screen.dart';

class AddToDoScreen extends StatefulWidget {
  const AddToDoScreen({Key? key}) : super(key: key);

  @override
  State<AddToDoScreen> createState() => _AddToDoScreenState();
}

class _AddToDoScreenState extends State<AddToDoScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TimeOfDay taskStartTime = TimeOfDay.now();
  TimeOfDay taskEndTime = TimeOfDay.now();
  TextEditingController taskController = TextEditingController();
  String task = "";
  String startTime = "12:00 PM";
  String endTime = "15:00 PM";

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).dividerColor)
                    ),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).dividerColor)
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).dividerColor)
                    ),

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

                        int val = await ToDoDBHelper.todoDBHelper.insertData(data: ToDo(startTime: startTime, endTime: endTime, myToDo: task));
                        pdfTime.add(startTime + endTime);
                        pdfTask.add(taskController.text);
                        log(pdfTask.toString(),name: "taskList");
                        log(pdfTime.toString(),name: "Timelist");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
                          ),
                        );
                        log("$val", name: "Insertion Success");
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
                              )
                            ),
                            child: Center(
                              child: Text(
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
    );
  }
}
