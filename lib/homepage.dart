import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTodoDialog(context);
        },
        tooltip: 'Add Todo',
        child: Icon(Icons.add,color: Colors.white,),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Todo').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var id = snapshot.data!.docs[index].id;
              return TodoListItem(
                task: snapshot.data!.docs[index]['Task'],
                onDelete: () {
                  FirebaseFirestore.instance.collection('Todo').doc(id).delete();
                },
                onUpdate: () {
                  _showUpdateTodoDialog(context, snapshot.data!.docs[index]['Task'], id);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    final TextEditingController _newTask = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Todo'),
          content: Container(
            height: 150,
            child: Column(
              children: [
                TextField(
                  controller: _newTask,
                  decoration: InputDecoration(labelText: 'Task'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    FirebaseFirestore.instance.collection('Todo').add({'Task': _newTask.text});
                    Navigator.pop(context);
                  },
                  child: Text('Add',style: TextStyle(color: Colors.white),),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUpdateTodoDialog(BuildContext context, String task, String id) {
    final TextEditingController _updateTask = TextEditingController(text: task);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Todo'),
          content: Container(
            height: 150,
            child: Column(
              children: [
                TextField(
                  controller: _updateTask,
                  decoration: InputDecoration(labelText: 'Task'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    FirebaseFirestore.instance.collection('Todo').doc(id).update({'Task': _updateTask.text});
                    Navigator.pop(context);
                  },
                  child: Text('Update',style: TextStyle(color: Colors.white),),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TodoListItem extends StatelessWidget {
  final String task;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const TodoListItem({
    required this.task,
    required this.onDelete,
    required this.onUpdate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(50), // Circle corners
      ),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(50), // Circle corners
        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(task),
              IconButton(
                onPressed: onUpdate,
                icon: Icon(Icons.edit),
                color: Colors.black,
              ),
            ],
          ),
          trailing: IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete),
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
