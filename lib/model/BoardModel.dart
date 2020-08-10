import 'package:firebase_database/firebase_database.dart';



class BoardModel {
  String key;
  String boardName;

  BoardModel(this.boardName);

  BoardModel.fromSnapshot(DataSnapshot snapshot) :
    key = snapshot.key,
    boardName = snapshot.value['boardName'].toString();

  toJson() {
    return {
      "boardName" : boardName
    };
  }

}