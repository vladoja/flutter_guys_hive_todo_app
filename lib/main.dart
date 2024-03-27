import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

import 'todo_item.dart';
import 'todo_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb == false) {
    //Hive.init('somePath') -> not needed in browser
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
  }

  Hive.registerAdapter(TodoItemAdapter());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final TodoService _todoService = TodoService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: FutureBuilder<List<TodoItem>>(
        future: _todoService.getAllTodos(),
        builder:
            (BuildContext context, AsyncSnapshot<List<TodoItem>> snapshot) {
          // List<Widget> children;
          if (snapshot.connectionState == ConnectionState.done) {
            return TodoListPage(
              todoService: _todoService,
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class TodoListPage extends StatelessWidget {
  final TodoService todoService;
  const TodoListPage({
    Key? key,
    required this.todoService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('HIVE DB CRUD'),
        backgroundColor: Colors.black12,
        actions: [],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<TodoItem>('todoBox').listenable(),
        builder: (context, Box<TodoItem> box, _) {
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final todo = box.getAt(index);
              return ListTile(
                title: Text(todo!.title),
                leading: Checkbox(
                  onChanged: (value) {
                    todoService.updateIsCompleted(todo);
                  },
                  value: todo.isCompleted,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Add Todo'),
                  content: TextField(
                    controller: _controller,
                  ),
                  actions: [
                    ElevatedButton(
                      child: const Text('Add'),
                      onPressed: () async {
                        if (_controller.text.isNotEmpty) {
                          var todo = TodoItem(title: _controller.text);
                          await todoService.addItem(todo);
                          debugPrint('Item added:');
                          List<TodoItem> allItems =
                              await todoService.getAllTodos();
                          debugPrint('Total items: ${allItems.length}');
                          _controller.clear();
                          Navigator.pop(context);
                        }
                      },
                    )
                  ],
                );
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
