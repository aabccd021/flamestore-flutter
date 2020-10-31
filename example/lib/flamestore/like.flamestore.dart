import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flamestore/flamestore.dart';

class _LikeDocumentData {
  _LikeDocumentData({
    this.likeValue,
    this.user,
    this.tweet,
  });
  final int likeValue;
  final DocumentReference user;
  final DocumentReference tweet;
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
  List<Sum> get sum => [
        Sum(
          field: 'likeValue',
          sumDocument: data.tweet,
          sumField: 'likesSum',
        ),
      ];

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

  @override
  LikeDocument withDefaultValue() {
    return super.withDefaultValue() as LikeDocument;
  }

  @override
  LikeDocument mergeDataWith(Document other) {
    return super.mergeDataWith(other) as LikeDocument;
  }

  LikeDocument copyWith({
    int likeValue,
    DocumentReference user,
    DocumentReference tweet,
  }) {
    return LikeDocument(
      likeValue: likeValue ?? data.likeValue,
      user: user ?? data.user,
      tweet: tweet ?? data.tweet,
    );
  }
}
