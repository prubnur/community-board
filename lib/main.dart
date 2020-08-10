import 'package:firebase_setup/ui/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'model/board.dart';



void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Community Board',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
        home: Home(),
//      home: MyHomePage(boardName: "community_board",),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key,@required this.boardName, @required this.boardKey}) : super(key: key);

  final String boardName;
  final String boardKey;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  List<Board> boardMessages = List();
  Board board;
  final FirebaseDatabase database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  DatabaseReference databaseReference;

  @override
  void initState() {
    super.initState();

    board = Board("", "", "");
    databaseReference = database.reference();
    databaseReference = database.reference().child(widget.boardKey);
    databaseReference.onChildAdded.listen(_onEntryAdded);
 //   databaseReference.onChildChanged.listen(_onEntryChanged);
    databaseReference.onChildRemoved.listen(_onEntryRemoved);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.boardName),
          centerTitle: true,
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
                            leading: Icon(Icons.person),
                            title: TextFormField(
                              initialValue: "",
                              decoration: InputDecoration(
                                  labelText: "Name"
                              ),
                              onSaved: (val) => board.name = val,
                              validator: (val) => val.trim().isEmpty ? "Enter field" : null,
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.subject),
                            title: TextFormField(
                              initialValue: "",
                              decoration: InputDecoration(
                                  labelText: "Subject"
                              ),
                              onSaved: (val) => board.subject = val,
                              validator: (val) => val.trim().isEmpty ? "Enter field" : null,
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.message),
                            title: TextFormField(
                              initialValue: "",
                              decoration: InputDecoration(
                                  labelText: "Body"
                              ),
                              onSaved: (val) => board.body = val,
                              validator: (val) => val.trim().isEmpty?"Enter field":null,
                            ),
                          ),
                          ListTile(
                            title: FlatButton(
                              child: Text("Post",
                                style: TextStyle(
                                    color: Colors.white
                                ),),
                              color: Colors.blue,
                              onPressed: () {
                                handleSubmit();
                              },
                            ),
                          )
                        ],
                      ),
                  )
              ),
            ),
            Flexible(
              child: FirebaseAnimatedList(
                  query: databaseReference,
                  itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation, int index) {
                    try {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(boardMessages[index].name[0].toString(),
                                style: TextStyle(
                                    color: Colors.white
                                ),),
                            ),
                            title: Text(
                              boardMessages[index].name.toString() + ": " +
                                  boardMessages[index].subject.toString(),
                              style: TextStyle(
                              ),),
                            subtitle: Text(boardMessages[index].body.toString(),
                              style: TextStyle(
                              ),),
                          ),
                        ),
                      );
                    } catch(e) {
                      print(e.toString());
                    }
                  },
              ),
            ),
          ],
        ),
    );
  }

  void _onEntryAdded(Event event) {
    if (event.snapshot.key != 'boardName') {
      setState(() {
        boardMessages.add(Board.fromSnapshot(event.snapshot));
      });
    }
  }

  void handleSubmit() {
    final FormState form = formKey.currentState;
    if (form.validate()) {
      form.save();
      form.reset();
      
      //save to database
      databaseReference.push().set(board.toJson());
    }
  }

//  void _onEntryChanged(Event event) {
//    var oldEntry = boardMessages.singleWhere((entry) {
//      return entry.key == event.snapshot.key;
//    });
//
//
//    setState(() {
//      boardMessages[boardMessages.indexOf(oldEntry)] = Board.fromSnapshot(event.snapshot);
//    });
//  }

  void _onEntryRemoved(Event event) {
    var key = boardMessages.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      boardMessages.removeAt(boardMessages.indexOf(key));
    });
  }
}
