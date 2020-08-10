import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_setup/main.dart';
import 'package:firebase_setup/model/BoardModel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _filter = new TextEditingController();
  List<BoardModel> boards = List();
  List<BoardModel> filteredBoards = List();
  BoardModel b;
  final FirebaseDatabase database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  DatabaseReference databaseReference;
  Widget _appBarTitle = Text("Boards");

  @override
  void initState() {
    super.initState();

    b = new BoardModel("");
    databaseReference = database.reference();
    databaseReference.onChildAdded.listen(_onEntryAdded);
    databaseReference.onChildRemoved.listen(_onEntryRemoved);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _appBarTitle,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: DataSearch(boards: boards));
            },
          )
        ],
      ),
      body: Column(
          children: <Widget>[
            Flexible(
              flex: 0,
              child: Center(
                  child: Form(
                    key: formKey,
                    child: Flex(
                      direction: Axis.vertical,
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.add),
                          title: TextFormField(
                            initialValue: "",
                            decoration: InputDecoration(
                                labelText: "New Board Name"
                            ),
                            onSaved: (val) => b.boardName = val,
                            validator: (val) =>
                            val
                                .trim()
                                .isEmpty ? "Enter field" : null,
                          ),
                        ),
                        ListTile(
                          title: FlatButton(
                            child: Text("Create New Board",
                              style: TextStyle(
                                  color: Colors.white
                              ),),
                            color: Colors.blue,
                            onPressed: () {
                              handleAdded();
                            },
                          ),
                        ),
                      ],
                    ),
                  )
              ),),
            Flexible(
              child: FirebaseAnimatedList(
                query: databaseReference,
                itemBuilder: (_, DataSnapshot snapshot,
                    Animation<double> animation, int index) {
                  return new Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        trailing: Icon(Icons.chevron_right),
                        leading: Icon(Icons.comment),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (context) {
                                    return MyHomePage(boardName: boards[index].boardName, boardKey: boards[index].key,);
                                  }
                              )
                          );
                        },
                        title: Text(boards[index].boardName,
                          style: TextStyle(
                          ),),
                      ),
                    ),
                  );
                },
              ),
            ),
          ]
      ),
    );
  }

  void handleAdded() {
    final FormState form = formKey.currentState;
    if (form.validate()) {
      form.save();
      form.reset();

      databaseReference.push().set(b.toJson());
    }
  }

  void _onEntryAdded(Event event) {
    if (event.snapshot.value!=null) {
      setState(() {
        boards.add(BoardModel.fromSnapshot(event.snapshot));
      });
    }
  }

//  void _onEntryChanged(Event event) {
//    var oldEntry = boards.singleWhere((entry) {
//      return entry.key == event.snapshot.key;
//    });
//
//    setState(() {
//      boards[boards.indexOf(oldEntry)] = BoardModel.fromSnapshot(event.snapshot);
//    });
//  }

  void _onEntryRemoved(Event event) {
    var key = boards.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      boards.removeAt(boards.indexOf(key));
    });
  }
}

class DataSearch extends SearchDelegate<String> {
  DataSearch({Key key, @required this.boards});

  final List boards;
  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(
      icon: Icon(Icons.clear),
      onPressed: () {
        query = "";
      },
    )];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty ?
        boards :
        boards.where((p) => p.boardName.toString().toLowerCase().startsWith(query.toLowerCase())).toList();
    return ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index) => ListTile(
          onTap: () {
            close(context, null);

            Navigator.push(context,
                MaterialPageRoute(
                    builder: (context) {
                      return MyHomePage(boardName: suggestionList[index].boardName, boardKey: suggestionList[index].key,);
                    }
                )
            );
          },
          leading: Icon(Icons.comment),
          title: RichText(
              text: TextSpan(
                text: suggestionList[index].boardName.substring(0, query.length),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold
                ),
                children: [
                  TextSpan(
                    text: suggestionList[index].boardName.substring(query.length),
                    style: TextStyle(
                      color: Colors.grey
                    )
                  )
                ]
              ))
        )
    );
  }
}

