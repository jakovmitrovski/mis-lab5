import 'package:flutter/material.dart';

import 'kolokvium.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MIS Lab 3',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'MIS Lab 3')
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Map<String, String> > elements = [];
  final nameController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  Widget getElements(){
    if (elements.isEmpty){
      return const Center(
          child: Text(
            "Во моментов немате додадено колоквиуми",
            style: TextStyle(
                fontSize: 30
            ),
          )
      );
    }else{
      return Expanded(
        child: ListView.builder(
          itemCount: elements.length,
          itemBuilder: (contx, index) {
            print(elements[index]);
            return Kolokvium(
                elements[index]['name'] as String,
                elements[index]['date'] as String,
                elements[index]['time'] as String,
                Theme.of(contx).primaryColor
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: () {
            setState(() {
              elements.add({
                "name": nameController.text,
                "date": dateController.text,
                "time": timeController.text
              });
              nameController.clear();
              dateController.clear();
              timeController.clear();
            });

            showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  content: Text('Успешно додадовте нов колоквиум'),
                );
              },
            );

          }, icon: const Icon(Icons.add))
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(5),
            child: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Име на предмет',
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(5),
            child: TextField(
              controller: dateController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Датум на полагање (формат DD/MM/YYYY)',
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(5),
            child: TextField(
              controller: timeController,
              decoration: const InputDecoration(
              border: OutlineInputBorder(),
                hintText: 'Време на полагање (формат HH:MM)',
              ),
            ),
          ),
          getElements()
      ]),
    );
  }
}
