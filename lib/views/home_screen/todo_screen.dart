import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo_app/controllers/todo_db_helper.dart';
import 'package:todo_app/modals/todo.dart';
import '../../utils/colours.dart';
import '../../utils/globals.dart';

class ToDoScreen extends StatefulWidget {
  const ToDoScreen({Key? key}) : super(key: key);

  @override
  State<ToDoScreen> createState() => _ToDoScreenState();
}

List<ToDo> todoList = [];

class _ToDoScreenState extends State<ToDoScreen> {
  Future<List<ToDo>>? todoData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    todoData = ToDoDBHelper.todoDBHelper.fetchAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                                  onPressed: (context) {},
                                ),
                                SlidableAction(
                                  icon: Icons.save,
                                  label: 'Save',
                                  backgroundColor: const Color(0xFF0392CF),
                                  onPressed: (context) {
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
                                      Icon(Icons.fast_forward_rounded,color: colorWhite,)
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
    );
  }
}
