import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/item.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = new List<Item>();

  HomePage() {
    items = [];

    // items.add(Item(id: 1, title: "Manita", done: false));
    // items.add(Item(id: 2, title: "Popo", done: true));
    // items.add(Item(id: 3, title: "Ninito", done: false));
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var taskInputController = TextEditingController();


  void add() {
    setState(() {
      if (taskInputController.text.isNotEmpty) {

        Random random = new Random();
        int randomId = random.nextInt(1000000000);

        widget.items.add(
          Item(
            id: randomId,
            title: taskInputController.text,
            done: false
          )
        );

        taskInputController.clear();
        save();
      }
    });
  }

  void remove(index){
    setState(() {
       widget.items.removeAt(index);
       save();
    });
  }


  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  //Future = promisse
  Future load() async {
    
    //espera carregar a instância do shared preferences 
    var prefs = await SharedPreferences.getInstance();

    //pega o json "data"
    var data = prefs.getString('data');

    if(data != null){
      //decoda o json salvo na shared preferences
      Iterable decoded = jsonDecode(data);

      //percorre todos os itens e transforma em JSON
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();

      //atribui a lista do shared preferences a list view
      setState(() {
        widget.items = result;
      });
    }
  }

  //chama a função asyncrona para carregar a lista
  _HomePageState(){
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //leading: Text("Oi"),

        title: TextFormField(
          controller: taskInputController,
          keyboardType: TextInputType.text,
          style: TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
              labelText: "Digite uma nova tarefa...",
              labelStyle: TextStyle(color: Colors.white)),
        ),

        // actions: <Widget>[
        //   Icon(Icons.plus_one)
        // ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(46, 46, 46, 1)
        ),
        child: widget.items.length == 0 ?
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,

            child: 
            Center(
              child: Text(
                "Ainda não há nenhuma tarefa cadastrada\n\n:(",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                ),
              )
            )
          ) :
        
        ListView.builder(
          itemCount: widget.items.length,
          itemBuilder: (BuildContext context, int index) {
            var item = widget.items[index];

              return Dismissible(
                key: Key(item.id.toString()),
                background: Container(
                  color: Colors.grey,
                ),

                onDismissed: (direction){
                  remove(index);
                },

                child: CheckboxListTile(
                  title: Text(
                    item.title,
                    style: TextStyle(color: Colors.white),
                  ),
                  value: item.done,
                  onChanged: (value) {
                    setState(() {
                      item.done = value;
                      save();
                    });
                  },
                ),
              );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
    );
  }
}
