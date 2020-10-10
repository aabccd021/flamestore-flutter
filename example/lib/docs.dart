import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flamestore/flamestore.dart';

class _UserDocumentData {
  final String uid;
  final String userName;
  final String bio;
  final int tweetsCount;

  _UserDocumentData({
    this.uid,
    this.userName,
    this.bio,
    this.tweetsCount,
  });
}

class UserDocument extends Document {
  UserDocument({
    @required String uid,
    String userName,
    String bio,
    int tweetsCount,
  }) : data = _UserDocumentData(
          uid: uid,
          userName: userName,
          bio: bio,
          tweetsCount: tweetsCount,
        );

  final _UserDocumentData data;

  @override
  String get collectionName => 'users';

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
      uid: data.uid,
      userName: data.userName,
      bio: data.bio,
      tweetsCount: 0,
    );
  }

  @override
  Map<String, dynamic> get defaultFirestoreMap {
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
  bool get shouldBeDeleted => false;

  @override
  List<String> get keys => [data.uid];

  @override
  UserDocument fromSnapshot(DocumentSnapshot snapshot) {
    return super.fromSnapshot(snapshot) as UserDocument;
  }

  UserDocument copyWith({
    String uid,
    String userName,
    String bio,
    int tweetsCount,
  }) {
    return UserDocument(
      uid: uid ?? this.data.uid,
      userName: userName ?? this.data.userName,
      bio: bio ?? this.data.bio,
      tweetsCount: tweetsCount ?? this.data.tweetsCount,
    );
  }
}

class _TweetDocumentData {
  final DocumentReference user;
  final String userName;
  final String tweetText;
  final int likesSum;
  final DateTime creationTime;

  _TweetDocumentData({
    this.user,
    this.userName,
    this.tweetText,
    this.likesSum,
    this.creationTime,
  });
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
      creationTime: data['creationTime']?.toDate(),
    );
  }

  @override
  TweetDocument withDefaultValue() {
    return TweetDocument(
      user: data.user,
      userName: data.userName,
      tweetText: data.tweetText,
      likesSum: 0,
      creationTime: DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> get defaultFirestoreMap {
    return {
      'likesSum': 0,
      'creationTime': FieldValue.serverTimestamp(),
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
  bool get shouldBeDeleted => false;

  @override
  List<String> get keys => [];

  @override
  TweetDocument fromSnapshot(DocumentSnapshot snapshot) {
    return super.fromSnapshot(snapshot) as TweetDocument;
  }

  TweetDocument copyWith({
    DocumentReference user,
    String userName,
    String tweetText,
    int likesSum,
    DateTime creationTime,
  }) {
    return TweetDocument(
      user: user ?? this.data.user,
      userName: userName ?? this.data.userName,
      tweetText: tweetText ?? this.data.tweetText,
      likesSum: likesSum ?? this.data.likesSum,
      creationTime: creationTime ?? this.data.creationTime,
    );
  }
}

class _LikeDocumentData {
  final int likeValue;
  final DocumentReference user;
  final DocumentReference tweet;

  _LikeDocumentData({
    this.likeValue,
    this.user,
    this.tweet,
  });
}

class LikeDocument extends Document {
  LikeDocument({
    int likeValue,
    @required DocumentReference user,
    @required DocumentReference tweet,
  }) : data = _LikeDocumentData(
          likeValue: likeValue,
          user: user,
          tweet: tweet,
        );

  final _LikeDocumentData data;

  @override
  String get collectionName => 'likes';

  @override
  LikeDocument fromMap(Map<String, dynamic> data) {
    return LikeDocument(
      likeValue: data['likeValue'],
      user: data['user'],
      tweet: data['tweet'],
    );
  }

  @override
  LikeDocument withDefaultValue() {
    return LikeDocument(
      likeValue: data.likeValue,
      user: data.user,
      tweet: data.tweet,
    );
  }

  @override
  Map<String, dynamic> get defaultFirestoreMap {
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
  bool get shouldBeDeleted => data.likeValue == 0;

  @override
  List<String> get keys => [
        data?.user?.id,
        data?.tweet?.id,
      ];

  @override
  LikeDocument fromSnapshot(DocumentSnapshot snapshot) {
    return super.fromSnapshot(snapshot) as LikeDocument;
  }

  LikeDocument copyWith({
    int likeValue,
    DocumentReference user,
    DocumentReference tweet,
  }) {
    return LikeDocument(
      likeValue: likeValue ?? this.data.likeValue,
      user: user ?? this.data.user,
      tweet: tweet ?? this.data.tweet,
    );
  }
}
