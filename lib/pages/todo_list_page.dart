
import 'package:flutter/material.dart';
import 'package:todo_list/models/todo.dart';
import 'package:todo_list/repository/todo_repository.dart';

import '../widgets/todo_list_item.dart';

class TodoListPage extends StatefulWidget {
   TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
   final TextEditingController todoController = TextEditingController();
   final TodoRepository todoRepository = TodoRepository();

   List<Todo> todos = [];

   Todo? deletedTodo;
   int? deletedTodoPos;

   String? errorText;

   @override
  void initState() {
    super.initState();

    todoRepository.getTodoList().then((value) => {
    setState(() {
      todos = value;
    }),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          InkWell(
            onTap: (){},
            child: const Icon(Icons.exit_to_app,
            color: Colors.white,
              size: 30,
            ),
          ),
        ],
        elevation: 2,
        title: const Text('Todo List - 2024',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: todoController,
                      decoration:  InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Adicione uma tarefa',
                        labelStyle: TextStyle(color: Colors.black),
                        hintText: 'Ex: Estudar Flutter',
                        errorText: errorText,
                        focusedBorder: const OutlineInputBorder(
                          borderSide:  BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                    ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      fixedSize: Size(100, 65),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                      )
                    ),
                    onPressed: () {
                      String text = todoController.text;
                      if(text.isEmpty) {
                        setState(() {
                          errorText = 'Digite o titulo';
                        });
                        return;
                      }

                      setState(() {
                        Todo newTodo = Todo(
                            title: text,
                            dateTime: DateTime.now());
                        todos.add(newTodo);
                        errorText = null;
                      });
                      todoController.clear();
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tarefa adicionada'))
                      );
                      todoRepository.saveTodoList(todos);
                    },
                      child: const Icon(Icons.add,
                      color: Colors.white,
                        size: 35,
                      ),
                  ),
                ],
              ),
             const SizedBox(height: 16,),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for(Todo todo in todos)
                      TodoListItem(
                      todo: todo,
                        onDelete: onDelete,
                      ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Expanded(
                      child: Text('Você Possui ${todos.length} tarefas Pendentes')),
                 const SizedBox(
                    width: 4,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        fixedSize: Size(130, 35),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)
                        )
                    ),
                    onPressed: showDeleteTodoConfirmationDialog,
                      child: const Text('Limpar tudo', style: TextStyle(
                          color: Colors.white
                      ),
                      ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
   void onDelete(Todo todo){
    deletedTodo = todo;
    deletedTodoPos = todos.indexOf(todo);
    setState(() {
      todos.remove(todo);
    });
    todoRepository.saveTodoList(todos);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('Tarefa removida'),
      action: SnackBarAction(
        label: 'Desfazer',
        onPressed: () {
          setState(() {
            todos.insert(deletedTodoPos!, deletedTodo!);
          });
          todoRepository.saveTodoList(todos);
        },
      ),
        duration: const Duration(seconds: 5),
      ),
    );
   }
   void showDeleteTodoConfirmationDialog(){
    showDialog(
        context: context,
        builder:(context) => AlertDialog(
          title: const Text('Deletar tudo'),
          content: const Text('Essa ação não poderá ser desfeita'),
          actions: [
           TextButton(onPressed: () => Navigator.pop(context, 'Não'),
               child: const Text('Não'),
           ),
            TextButton(onPressed: () {
              Navigator.pop(context, 'Sim');
              setState(() {
                todos.clear();
              });
              todoRepository.saveTodoList(todos);
            } ,
                child: const Text('Sim')),
          ],
        ),
    );
   }
}