import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'flamestore/flamestore.dart';

class TweetDocument extends Document {
  TweetDocument({
    this.user,
    this.userName,
    this.tweetText,
    this.likesSum,
    this.creationTime,
  });

  DocumentReference user;
  String userName;
  String tweetText;
  int likesSum;
  DateTime creationTime;

  @override
  DocumentMetadata get metadata => DocumentMetadata(collectionName: 'tweets');

  @override
  TweetDocument createDocumentFromData(Map<String, dynamic> data) {
    return TweetDocument(
      user: data['user'],
      userName: data['userName'],
      tweetText: data['tweetText'],
      likesSum: data['likesSum'],
      creationTime: data['creationTime']?.toDate(),
    );
  }

  @override
  TweetDocument mergeWith(Document document) {
    TweetDocument tweetDocument = document;
    return TweetDocument(
      user: tweetDocument.user ?? user,
      userName: tweetDocument.userName ?? userName,
      tweetText: tweetDocument.tweetText ?? tweetText,
      likesSum: tweetDocument.likesSum ?? likesSum,
      creationTime: tweetDocument.creationTime ?? creationTime,
    );
  }

  @override
  TweetDocument withDefaultValue() {
    return TweetDocument(
      user: user,
      userName: userName,
      tweetText: tweetText,
      likesSum: 0,
      creationTime: DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> get defaultMap {
    return {
      'likesSum': 0,
      'creationTime': FieldValue.serverTimestamp(),
    };
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'user': user,
      'userName': userName,
      'tweetText': tweetText,
      'likesSum': likesSum,
      'creationTime': creationTime,
    };
  }

  @override
  bool get shouldBeDeleted => false;

  @override
  List<String> get keys => [];
}

class UserDocument extends Document {
  UserDocument({
    @required this.uid,
    this.userName,
    this.bio,
    this.tweetsCount,
  });

  String uid;
  String userName;
  String bio;
  int tweetsCount;

  @override
  DocumentMetadata get metadata => DocumentMetadata(collectionName: 'users');

  @override
  UserDocument createDocumentFromData(Map<String, dynamic> data) {
    return UserDocument(
      uid: data['uid'],
      userName: data['userName'],
      bio: data['bio'],
      tweetsCount: data['tweetsCount'],
    );
  }

  @override
  UserDocument mergeWith(Document document) {
    UserDocument userDocument = document;
    return UserDocument(
      uid: userDocument.uid ?? uid,
      userName: userDocument.userName ?? userName,
      bio: userDocument.bio ?? bio,
      tweetsCount: userDocument.tweetsCount ?? tweetsCount,
    );
  }

  @override
  UserDocument withDefaultValue() {
    return UserDocument(
      uid: uid,
      userName: userName,
      bio: bio,
      tweetsCount: 0,
    );
  }

  @override
  Map<String, dynamic> get defaultMap {
    return {
      'tweetsCount': 0,
    };
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userName': userName,
      'bio': bio,
      'tweetsCount': tweetsCount,
    };
  }

  @override
  bool get shouldBeDeleted => false;

  @override
  List<String> get keys => [uid];

  UserDocument copyWith({
    String uid,
    String userName,
    String bio,
    int tweetsCount,
  }) {
    return UserDocument(
      uid: uid ?? this.uid,
      userName: userName ?? this.userName,
      bio: bio ?? this.bio,
      tweetsCount: tweetsCount ?? this.tweetsCount,
    );
  }
}

class LikeDocument extends Document {
  LikeDocument({
    this.likeValue,
    @required this.user,
    @required this.tweet,
  });

  int likeValue;
  DocumentReference user;
  DocumentReference tweet;

  @override
  LikeDocument withDefaultValue() {
    return LikeDocument(
      likeValue: likeValue,
      user: user,
      tweet: tweet,
    );
  }

  @override
  Map<String, dynamic> get defaultMap => {};

  @override
  LikeDocument createDocumentFromData(Map<String, dynamic> data) {
    return LikeDocument(
      likeValue: data['likeValue'],
      user: data['user'],
      tweet: data['tweet'],
    );
  }

  @override
  LikeDocument mergeWith(Document document) {
    LikeDocument likeDocument = document;
    return LikeDocument(
      likeValue: likeDocument.likeValue ?? likeValue,
      user: likeDocument.user ?? user,
      tweet: likeDocument.tweet ?? tweet,
    );
  }

  @override
  DocumentMetadata get metadata => DocumentMetadata(collectionName: 'likes');

  @override
  bool get shouldBeDeleted => likeValue == 0;

  @override
  Map<String, dynamic> toMap() {
    return {
      'likeValue': likeValue,
      'user': user,
      'tweet': tweet,
    };
  }

  @override
  List<String> get keys => [user?.id, tweet?.id];

  LikeDocument copyWith({
    int likeValue,
    DocumentReference user,
    DocumentReference tweet,
  }) {
    return LikeDocument(
      likeValue: likeValue ?? this.likeValue,
      user: user ?? this.user,
      tweet: tweet ?? this.tweet,
    );
  }
}
