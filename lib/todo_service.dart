import 'package:hive/hive.dart';

import 'todo_item.dart';

class TodoService {
  final String _boxName = "todoBox";

  Future<Box<TodoItem>> get _box async =>
      await Hive.openBox<TodoItem>(_boxName);

  Future<int> addItem(TodoItem item) async {
    final box = await _box;
    final int itemId = await box.add(item);
    return itemId;
  }

  Future<List<TodoItem>> getAllTodos() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<void> deleteItem(int index) async {
    final box = await _box;
    await box.deleteAt(index);
  }

  // Future<void> updateIsCompleted(int index, TodoItem todoItem) async {
  Future<void> updateIsCompleted(TodoItem todoItem) async {
    final box = await _box;
    todoItem.isCompleted = !todoItem.isCompleted;
    await box.put(todoItem.key, todoItem);
  }
}
