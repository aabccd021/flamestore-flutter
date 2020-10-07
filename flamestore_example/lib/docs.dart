import 'package:cloud_firestore/cloud_firestore.dart';
import 'flamestore/flamestore.dart';

class TweetDocument extends Document {
  TweetDocument({
    this.user,
    this.userName,
    this.tweetText,
    this.likesSum,
    this.creationTime,
    DocumentReference reference,
  }) : super(reference);

  final DocumentReference user;
  final String userName;
  final String tweetText;
  final int likesSum;
  final DateTime creationTime;

  @override
  DocumentMetadata get metadata => DocumentMetadata(collectionName: 'tweets');

  @override
  List<Object> get props => [user, userName, tweetText, likesSum, creationTime];

  @override
  TweetDocument documentFromData(Map<String, dynamic> data) {
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
      reference: tweetDocument.reference ?? reference,
      user: tweetDocument.user ?? user,
      userName: tweetDocument.userName ?? userName,
      tweetText: tweetDocument.tweetText ?? tweetText,
      likesSum: tweetDocument.likesSum ?? likesSum,
      creationTime: tweetDocument.creationTime ?? creationTime,
    );
  }

  @override
  TweetDocument get defaultDocument {
    return TweetDocument(
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
  TweetDocument documentFromReference(DocumentReference reference) {
    return TweetDocument(reference: reference);
  }

  @override
  bool get shouldBeDeleted => false;
}

enum TweetAttribute { user, userName, tweetText, likesSum }

class UserDocument extends Document {
  UserDocument({
    this.uid,
    this.userName,
    this.bio,
    this.tweetsCount,
    DocumentReference reference,
  }) : super(reference);

  final String uid;
  final String userName;
  final String bio;
  final int tweetsCount;

  @override
  DocumentMetadata get metadata => DocumentMetadata(collectionName: 'users');

  @override
  List<Object> get props => [uid, userName, bio, tweetsCount];

  @override
  UserDocument documentFromData(Map<String, dynamic> data) {
    return UserDocument(
      uid: data['uid'],
      userName: data['userName'],
      bio: data['bio'],
      tweetsCount: data['tweetsCount'],
    );
  }

  @override
  UserDocument documentFromReference(DocumentReference reference) {
    return UserDocument(reference: reference);
  }

  @override
  UserDocument mergeWith(Document document) {
    UserDocument userDocument = document;
    return UserDocument(
      reference: userDocument.reference ?? reference,
      uid: userDocument.uid ?? uid,
      userName: userDocument.userName ?? userName,
      bio: userDocument.bio ?? bio,
      tweetsCount: userDocument.tweetsCount ?? tweetsCount,
    );
  }

  @override
  UserDocument get defaultDocument {
    return UserDocument(tweetsCount: 0);
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
}

class LikeDocument extends Document {
  LikeDocument({
    this.likeValue,
    this.user,
    this.tweet,
    DocumentReference reference,
  }) : super(reference);

  final int likeValue;
  final DocumentReference user;
  final DocumentReference tweet;

  @override
  LikeDocument get defaultDocument => LikeDocument();

  @override
  Map<String, dynamic> get defaultMap => {};

  @override
  LikeDocument documentFromData(Map<String, dynamic> data) {
    return LikeDocument(
      likeValue: data['likeValue'],
      user: data['user'],
      tweet: data['tweet'],
    );
  }

  @override
  LikeDocument documentFromReference(DocumentReference reference) {
    return LikeDocument(reference: reference);
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
  List<Object> get props => [likeValue, user, tweet];

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
}
