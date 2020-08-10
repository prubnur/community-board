
import 'package:firebase_database/firebase_database.dart';

class Board {
  String key;
  String name;
  String subject;
  String body;

  Board(this.name, this.subject, this.body);

  Board.fromSnapshot(DataSnapshot snapshot) :
      key = snapshot.key,
      name = snapshot.value['name'],
      subject = snapshot.value['subject'],
      body = snapshot.value['body'];

  toJson() {
    return {
      "name" : name,
      "subject" : subject,
      "body" : body,
    };
  }


}