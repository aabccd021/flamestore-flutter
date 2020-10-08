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
  TweetDocument fromMap(Map<String, dynamic> data) {
    return TweetDocument(
      user: data['user'],
      userName: data['userName'],
      tweetText: data['tweetText'],
      likesSum: data['likesSum'],
      creationTime: data['creationTime']?.toDate(),
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
  Map<String, dynamic> toDataMap() {
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
  UserDocument fromMap(Map<String, dynamic> data) {
    return UserDocument(
      uid: data['uid'],
      userName: data['userName'],
      bio: data['bio'],
      tweetsCount: data['tweetsCount'],
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
  Map<String, dynamic> toDataMap() {
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
  LikeDocument fromMap(Map<String, dynamic> data) {
    return LikeDocument(
      likeValue: data['likeValue'],
      user: data['user'],
      tweet: data['tweet'],
    );
  }

  @override
  DocumentMetadata get metadata => DocumentMetadata(collectionName: 'likes');

  @override
  bool get shouldBeDeleted => likeValue == 0;

  @override
  Map<String, dynamic> toDataMap() {
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
