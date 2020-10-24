import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flamestore/flamestore.dart';

class _TweetDocumentData {
  _TweetDocumentData({
    this.user,
    this.userName,
    this.tweetText,
    this.likesSum,
    this.creationTime,
  });
  final DocumentReference user;
  final String userName;
  final String tweetText;
  final int likesSum;
  final DateTime creationTime;
}

class TweetDocument extends Document {
  TweetDocument({
    DocumentReference user,
    String userName,
    String tweetText,
    int likesSum,
    DateTime creationTime,
  }) : data = _TweetDocumentData(
          user: user,
          userName: userName,
          tweetText: tweetText,
          likesSum: likesSum,
          creationTime: creationTime,
        );

  final _TweetDocumentData data;

  @override
  String get collectionName => 'tweets';

  @override
  TweetDocument fromMap(Map<String, dynamic> data) {
    return TweetDocument(
      user: data['user'],
      userName: data['userName'],
      tweetText: data['tweetText'],
      likesSum: data['likesSum'],
      creationTime: data['creationTime'] is DateTime
          ? data['creationTime']
          : data['creationTime']?.toDate(),
    );
  }

  @override
  Map<String, dynamic> get defaultValueMap {
    return {
      'likesSum': 0,
      'creationTime': DateTime.now(),
    };
  }

  @override
  Map<String, dynamic> toDataMap() {
    return {
      'user': data.user,
      'userName': data.userName,
      'tweetText': data.tweetText,
      'likesSum': data.likesSum,
      'creationTime': data.creationTime,
    };
  }

  @override
  List<String> firestoreCreateFields() {
    return [
      'user',
      'tweetText',
    ];
  }

  @override
  bool get shouldBeDeleted => false;

  @override
  List<String> get keys => [];

  @override
  TweetDocument fromSnapshot(DocumentSnapshot snapshot) {
    return super.fromSnapshot(snapshot) as TweetDocument;
  }

  @override
  TweetDocument withDefaultValue() {
    return super.withDefaultValue() as TweetDocument;
  }

  @override
  TweetDocument mergeDataWith(Document other) {
    return super.mergeDataWith(other) as TweetDocument;
  }

  TweetDocument copyWith({
    DocumentReference user,
    String userName,
    String tweetText,
    int likesSum,
    DateTime creationTime,
  }) {
    return TweetDocument(
      user: user ?? data.user,
      userName: userName ?? data.userName,
      tweetText: tweetText ?? data.tweetText,
      likesSum: likesSum ?? data.likesSum,
      creationTime: creationTime ?? data.creationTime,
    );
  }
}
