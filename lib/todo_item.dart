import 'package:hive/hive.dart';
part 'todo_item.g.dart';

@HiveType(typeId: 1)
class TodoItem extends HiveObject {
  @HiveField(0)
  String title;
  @HiveField(1, defaultValue: false)
  bool isCompleted;
  TodoItem({
    required this.title,
    required this.isCompleted,
  });
}
