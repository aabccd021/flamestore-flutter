import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flamestore/flamestore.dart';

class _UserDocumentData {
  _UserDocumentData({
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
  bool get shouldBeDeleted => false;

  @override
  List<String> get keys => [data.uid];

  @override
  UserDocument fromSnapshot(DocumentSnapshot snapshot) {
    return super.fromSnapshot(snapshot) as UserDocument;
  }

  @override
  UserDocument withDefaultValue() {
    return super.withDefaultValue() as UserDocument;
  }

  @override
  UserDocument mergeDataWith(Document other) {
    return super.mergeDataWith(other) as UserDocument;
  }

  UserDocument copyWith({
    String uid,
    String userName,
    String bio,
    int tweetsCount,
  }) {
    return UserDocument(
      uid: uid ?? data.uid,
      userName: userName ?? data.userName,
      bio: bio ?? data.bio,
      tweetsCount: tweetsCount ?? data.tweetsCount,
    );
  }
}
