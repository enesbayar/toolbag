import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tool_bag/models/to_do.dart';
import 'package:tool_bag/services/dbHelper.dart';
import 'package:tool_bag/widgets/classic_text.dart';

class ToDoPage extends StatefulWidget {
  @override
  _ToDoPageState createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  var dbHelper = DbHelper();
  List<ToDo> toDoList;
  int toDoCount = 0;
  TextEditingController textEditingController = TextEditingController();
  @override
  void initState() {
    super.initState();
    //dbHelper.deleteDatabase();
    getToDoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ClassicText(
          text: "To Do List",
          fontSize: 18,
        ),
      ),
      body: buildToDoPage(context),
      floatingActionButton: FloatingActionButton(
        onPressed: addToDo,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildToDoPage(BuildContext context) {
    return toDoCount == 0
        ? Center(
            child: ClassicText(
            text: "Empty List",
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ))
        : ListView.builder(
            itemCount: toDoCount,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                  elevation: 2.0,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Checkbox(
                        value: toDoList[index].isDone,
                        onChanged: (value) {
                          setState(() {
                            toDoList[index].isDone = value;
                            dbHelper.update(toDoList[index]);
                          });
                        },
                      ),
                      Flexible(
                        child: ClassicText(
                          text: toDoList[index].description,
                          fontSize: 18,
                          textDecoration: toDoList[index].isDone == true
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteItem(toDoList[index]))
                    ],
                  ));
            });
  }

  void getToDoList() async {
    var toDoListFuture = dbHelper.getToDoList();
    toDoListFuture.then((data) {
      setState(() {
        this.toDoList = data;
        toDoCount = data.length;
      });
    });
  }

  void deleteItem(ToDo toDo) async {
    var result = dbHelper.delete(toDo.id);
    if (result != null) {
      getToDoList();
    } else {
      throw Exception("db exception");
    }
  }

  void addItem() async {
    ToDo _todo = ToDo(description: textEditingController.text);
    var result = await dbHelper.insert(_todo);
    if (result != null) {
      getToDoList();
    } else {
      throw Exception("db exception");
    }
  }

  Future<void> addToDo() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: TextField(
            controller: textEditingController,
            cursorColor: Colors.red,
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue)),
              hintText: "Please write the description",
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: ClassicText(text: "Close", fontSize: 14.0),
              onPressed: () {
                textEditingController.clear();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: ClassicText(
                text: "Save",
                fontSize: 14.0,
              ),
              onPressed: () async {
                addItem();
                textEditingController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}