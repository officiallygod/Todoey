import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todoey/helpers/database_helper.dart';
import 'package:todoey/models/task_model.dart';
import 'package:todoey/screens/add_task_screen.dart';

class ToDoListScreen extends StatefulWidget {
  @override
  _ToDoListScreenState createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen>
    with TickerProviderStateMixin {
  Future<List<Task>> _taskList;
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');

  Widget _buildTask(Task task) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30.0,
        vertical: 5.0,
      ),
      child: ListTile(
        title: Text(
          ' ${task.title} ',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 19.0,
            color: task.status == 0 ? Colors.black : Colors.redAccent,
            fontFamily: 'Monster',
            decorationColor: Theme.of(context).primaryColor,
            decorationThickness: 2,
            decorationStyle: TextDecorationStyle.solid,
            fontWeight: FontWeight.bold,
            decoration: task.status == 1
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Text(
          '  ${_dateFormatter.format(task.date)} | ${task.priority}',
          style: TextStyle(
            fontSize: 12.0,
            fontFamily: 'Nunito',
            decorationColor: Colors.black26,
            color: task.status == 0 ? Colors.black87 : Colors.black26,
            decorationStyle: TextDecorationStyle.solid,
            fontWeight: FontWeight.bold,
            decoration: task.status == 1
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
//        leading: Checkbox(
//          checkColor: Colors.white,
//          onChanged: (value) {
//            task.status = value ? 1 : 0;
//            DatabaseHelper.instance.updateTask(task);
//            _updateTaskList();
//          },
//          activeColor: Theme.of(context).primaryColor,
//          value: task.status == 1 ? true : false,
//        ),
        leading: GestureDetector(
          onTap: () {
            task.status == 0 ? task.status = 1 : task.status = 0;
            DatabaseHelper.instance.updateTask(task);
            _updateTaskList();
          },
          child: Container(
            height: 21.0,
            width: 21.0,
            margin: EdgeInsets.symmetric(vertical: 10.0),
            decoration: BoxDecoration(
              color: task.status == 0 ? Colors.white : Colors.redAccent,
              border: Border.all(
                width: 1.0,
                color: Colors.black26,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: task.status == 0
                  ? SizedBox.shrink()
                  : Icon(
                      Icons.check,
                      size: 17.0,
                      color: Colors.white,
                    ),
            ),
          ),
        ),
        trailing: IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddTaskScreen(updateTaskList: _updateTaskList, task: task),
            ),
          ),
          icon: Icon(
            Icons.edit,
            size: 20.0,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _updateTaskList();
  }

  _updateTaskList() {
    setState(() {
      _taskList = DatabaseHelper.instance.getTaskList();
    });
  }

  double getPercentCompleted(int first, int second) {
    if (first == 0 && second == 0) {
      return 0;
    } else {
      return first / second;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskScreen(
                updateTaskList: _updateTaskList,
              ),
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder(
          future: _taskList,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final int completedTaskCount = snapshot.data
                .where((Task task) => task.status == 1)
                .toList()
                .length;

            return ListView.builder(
              padding: EdgeInsets.symmetric(
                vertical: 10.0,
              ),
              itemCount: 1 + snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                              top: 40.0, left: 40.0, bottom: 60.0),
                          width: double.infinity,
                          alignment: Alignment.centerLeft,
                          child: Image(
                            height: 40.0,
                            width: 40.0,
                            fit: BoxFit.contain,
                            image: AssetImage('assets/images/tasks.png'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 60.0,
                          ),
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  SizedBox(
                                    height: 28.0,
                                    width: 28.0,
                                    child: CircularProgressIndicator(
                                      value: getPercentCompleted(
                                          completedTaskCount,
                                          snapshot.data.length),
                                      strokeWidth: 2,
                                      backgroundColor: Colors.grey[200],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 25.0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'My Tasks',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 35.0,
                                      fontFamily: 'Monster',
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Text(
                                    '$completedTaskCount of ${snapshot.data.length} tasks',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15.0,
                                      fontFamily: 'Sans',
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15.0,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 110.0,
                          ),
                          child: Divider(
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return _buildTask(snapshot.data[index - 1]);
              },
            );
          }),
    );
  }
}
