import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flamestore/flamestore.dart';

class _UserData {
  _UserData({
    this.uid,
    this.userName,
    this.bio,
    this.tweetsCount,
  });
  final String uid;
  final String userName;
  final String bio;
  final int tweetsCount;
}

class User extends Document {
  User({
    @required String uid,
    String userName,
    String bio,
    int tweetsCount,
  }) : data = _UserData(
          uid: uid,
          userName: userName,
          bio: bio,
          tweetsCount: tweetsCount,
        );

  final _UserData data;

  @override
  String get collectionName => 'users';

  @override
  User fromMap(Map<String, dynamic> data) {
    return User(
      uid: data['uid'],
      userName: data['userName'],
      bio: data['bio'],
      tweetsCount: data['tweetsCount'],
    );
  }

  @override
  Map<String, dynamic> get defaultValueMap {
    return {
      'tweetsCount': 0,
    };
  }

  @override
  Map<String, dynamic> toDataMap() {
    return {
      'uid': data.uid,
      'userName': data.userName,
      'bio': data.bio,
      'tweetsCount': data.tweetsCount,
    };
  }

  @override
  List<String> firestoreCreateFields() {
    return [
      'uid',
      'userName',
      'bio',
    ];
  }

  @override
  List<Sum> get sums => [];

  @override
  List<Count> get counts => [];

  @override
  bool get shouldBeDeleted => false;

  @override
  List<String> get keys => [data.uid];

  @override
  User fromSnapshot(DocumentSnapshot snapshot) {
    return super.fromSnapshot(snapshot) as User;
  }

  @override
  User withDefaultValue() {
    return super.withDefaultValue() as User;
  }

  @override
  User mergeDataWith(Document other) {
    return super.mergeDataWith(other) as User;
  }

  User copyWith({
    String uid,
    String userName,
    String bio,
    int tweetsCount,
  }) {
    return User(
      uid: uid ?? data.uid,
      userName: userName ?? data.userName,
      bio: bio ?? data.bio,
      tweetsCount: tweetsCount ?? data.tweetsCount,
    );
  }
}

class _TweetData {
  _TweetData({
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

class Tweet extends Document {
  Tweet({
    DocumentReference user,
    String userName,
    String tweetText,
    int likesSum,
    DateTime creationTime,
  }) : data = _TweetData(
          user: user,
          userName: userName,
          tweetText: tweetText,
          likesSum: likesSum,
          creationTime: creationTime,
        );

  final _TweetData data;

  @override
  String get collectionName => 'tweets';

  @override
  Tweet fromMap(Map<String, dynamic> data) {
    return Tweet(
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
  List<Sum> get sums => [];

  @override
  List<Count> get counts => [
        Count(
          countDocument: data.user,
          countField: 'tweetsCount',
        ),
      ];

  @override
  bool get shouldBeDeleted => false;

  @override
  List<String> get keys => [];

  @override
  Tweet fromSnapshot(DocumentSnapshot snapshot) {
    return super.fromSnapshot(snapshot) as Tweet;
  }

  @override
  Tweet withDefaultValue() {
    return super.withDefaultValue() as Tweet;
  }

  @override
  Tweet mergeDataWith(Document other) {
    return super.mergeDataWith(other) as Tweet;
  }

  Tweet copyWith({
    DocumentReference user,
    String userName,
    String tweetText,
    int likesSum,
    DateTime creationTime,
  }) {
    return Tweet(
      user: user ?? data.user,
      userName: userName ?? data.userName,
      tweetText: tweetText ?? data.tweetText,
      likesSum: likesSum ?? data.likesSum,
      creationTime: creationTime ?? data.creationTime,
    );
  }
}

class _LikeData {
  _LikeData({
    this.likeValue,
    this.user,
    this.tweet,
  });
  final int likeValue;
  final DocumentReference user;
  final DocumentReference tweet;
}

class Like extends Document {
  Like({
    int likeValue,
    @required DocumentReference user,
    @required DocumentReference tweet,
  }) : data = _LikeData(
          likeValue: likeValue,
          user: user,
          tweet: tweet,
        );

  final _LikeData data;

  @override
  String get collectionName => 'likes';

  @override
  Like fromMap(Map<String, dynamic> data) {
    return Like(
      likeValue: data['likeValue'],
      user: data['user'],
      tweet: data['tweet'],
    );
  }

  @override
  Map<String, dynamic> get defaultValueMap {
    return {};
  }

  @override
  Map<String, dynamic> toDataMap() {
    return {
      'likeValue': data.likeValue,
      'user': data.user,
      'tweet': data.tweet,
    };
  }

  @override
  List<String> firestoreCreateFields() {
    return [
      'likeValue',
      'user',
      'tweet',
    ];
  }

  @override
  List<Sum> get sums => [
        Sum(
          field: 'likeValue',
          sumDocument: data.tweet,
          sumField: 'likesSum',
        ),
      ];

  @override
  List<Count> get counts => [];

  @override
  bool get shouldBeDeleted => data.likeValue == 0;

  @override
  List<String> get keys => [
        data?.user?.id,
        data?.tweet?.id,
      ];

  @override
  Like fromSnapshot(DocumentSnapshot snapshot) {
    return super.fromSnapshot(snapshot) as Like;
  }

  @override
  Like withDefaultValue() {
    return super.withDefaultValue() as Like;
  }

  @override
  Like mergeDataWith(Document other) {
    return super.mergeDataWith(other) as Like;
  }

  Like copyWith({
    int likeValue,
    DocumentReference user,
    DocumentReference tweet,
  }) {
    return Like(
      likeValue: likeValue ?? data.likeValue,
      user: user ?? data.user,
      tweet: tweet ?? data.tweet,
    );
  }
}