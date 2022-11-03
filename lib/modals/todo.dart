import 'dart:typed_data';
class ToDo {
  int? id;
  final String startTime;
  final String endTime;
  final String myToDo;

  ToDo({
    this.id,
    required this.startTime,
    required this.endTime,
    required this.myToDo,
  });

  factory ToDo.fromMap({required Map data}) {
    return ToDo(
      id: data["id"],
      startTime: data["startTime"],
      endTime: data["endTime"],
      myToDo: data["task"],
    );
  }
}

