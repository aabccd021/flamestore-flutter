import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flamestore/flamestore.dart';
import 'package:flutter/widgets.dart';

class User extends Document {
  User({
    @required this.userName,
    this.bio,
    @required this.uid,
  })  : tweetsCount = 0,
        super(null);
  User._fromMap(Map<String, dynamic> data)
      : userName = StringField.fromMap(data['userName']).value,
        bio = StringField.fromMap(data['bio']).value,
        tweetsCount = CountField.fromMap(data['tweetsCount']).value,
        uid = StringField.fromMap(data['uid']).value,
        super(data['reference']);
  User._({
    @required this.userName,
    @required this.bio,
    @required this.tweetsCount,
    @required this.uid,
    @required DocumentReference reference,
  }) : super(reference);
  User copyWith({
    String userName,
    String bio,
  }) {
    return User._(
      userName: userName ?? this.userName,
      bio: bio ?? this.bio,
      tweetsCount: this.tweetsCount,
      uid: this.uid,
      reference: this.reference,
    );
  }

  final String userName;
  final String bio;
  final int tweetsCount;
  final String uid;
  @override
  String get colName => "users";
  @override
  List<String> get keys {
    return [
      uid,
    ];
  }
}

final UserDefinition = DocumentDefinition<User>(
  mapToDoc: (data) => User._fromMap(data),
  docToMap: (doc) {
    return {
      'userName': StringField(doc.userName),
      'bio': StringField(doc.bio),
      'tweetsCount': CountField(doc.tweetsCount),
      'uid': StringField(doc.uid),
    };
  },
  creatableFields: [
    'userName',
    'bio',
    'uid',
  ],
  updatableFields: [
    'userName',
    'bio',
  ],
);

class _TweetOwner extends ReferenceField {
  _TweetOwner(DocumentReference reference, {@required this.userName})
      : super(
          reference,
          fields: {
            'userName': userName,
          },
        );
  _TweetOwner._fromUser(User owner)
      : userName = owner.userName,
        super(
          owner.reference,
          fields: {
            'userName': owner.userName,
          },
        );
  _TweetOwner._fromMap(Map<String, dynamic> map)
      : userName = map['userName'],
        super.fromMap(map);
  final String userName;
}

class _TweetImage {
  String url;
  int height;
  int width;
  _TweetImage._fromMap(Map<String, dynamic> map) {
    if (map != null) {
      url = map['url'];
      height = map['height'];
      width = map['width'];
    }
  }
}

class Tweet extends Document {
  Tweet({
    @required User owner,
    @required this.tweetText,
    File image,
  })  : owner = _TweetOwner._fromUser(owner),
        likesSum = 0,
        creationTime = null,
        hotness = null,
        _image = image,
        image = null,
        dynamicLink = null,
        super(null);
  Tweet._fromMap(Map<String, dynamic> data)
      : owner = _TweetOwner._fromMap(data['owner']),
        tweetText = StringField.fromMap(data['tweetText']).value,
        likesSum = SumField.fromMap(data['likesSum']).value,
        creationTime = TimestampField.fromMap(data['creationTime']).value,
        hotness = FloatField.fromMap(data['hotness']).value,
        image = _TweetImage._fromMap(data['image']),
        _image = null,
        dynamicLink = DynamicLinkField.fromMap(data['dynamicLink']).value,
        super(data['reference']);
  Tweet._(
    this._image, {
    @required this.owner,
    @required this.tweetText,
    @required this.likesSum,
    @required this.creationTime,
    @required this.hotness,
    @required this.image,
    @required this.dynamicLink,
    @required DocumentReference reference,
  }) : super(reference);
  Tweet copyWith({
    String tweetText,
    File image,
  }) {
    return Tweet._(
      image ?? this._image,
      owner: this.owner,
      tweetText: tweetText ?? this.tweetText,
      likesSum: this.likesSum,
      creationTime: this.creationTime,
      hotness: this.hotness,
      image: this.image,
      dynamicLink: this.dynamicLink,
      reference: this.reference,
    );
  }

  final _TweetOwner owner;
  final String tweetText;
  final double likesSum;
  final DateTime creationTime;
  final double hotness;
  final File _image;
  final _TweetImage image;
  final String dynamicLink;
  @override
  String get colName => "tweets";
}

final TweetDefinition = DocumentDefinition<Tweet>(
  mapToDoc: (data) => Tweet._fromMap(data),
  docToMap: (doc) {
    return {
      'owner': doc.owner,
      'tweetText': StringField(doc.tweetText),
      'likesSum': SumField(doc.likesSum?.toDouble()),
      'creationTime': TimestampField(
        doc.creationTime,
        isServerTimestamp: true,
      ),
      'hotness': FloatField(doc.hotness),
      'image': ImageField(
        doc?.image?.url,
        file: doc._image,
        userId: doc.owner.reference.id,
      ),
      'dynamicLink': DynamicLinkField(
        doc.dynamicLink,
        title: doc.tweetText,
        description: "tweet description",
        isSuffixShort: true,
      ),
    };
  },
  creatableFields: [
    'owner',
    'tweetText',
    'dynamicLink',
  ],
  updatableFields: [
    'tweetText',
  ],
);

class _LikeTweet extends ReferenceField {
  _LikeTweet(DocumentReference reference) : super(reference);
  _LikeTweet._fromTweet(Tweet tweet) : super(tweet.reference);
  _LikeTweet._fromMap(Map<String, dynamic> map) : super.fromMap(map);
}

class _LikeUser extends ReferenceField {
  _LikeUser(DocumentReference reference) : super(reference);
  _LikeUser._fromUser(User user) : super(user.reference);
  _LikeUser._fromMap(Map<String, dynamic> map) : super.fromMap(map);
}

class Like extends Document {
  Like({
    @required this.likeValue,
    @required Tweet tweet,
    @required User user,
  })  : tweet = _LikeTweet._fromTweet(tweet),
        user = _LikeUser._fromUser(user),
        super(null);
  Like._fromMap(Map<String, dynamic> data)
      : likeValue = IntField.fromMap(data['likeValue']).value,
        tweet = _LikeTweet._fromMap(data['tweet']),
        user = _LikeUser._fromMap(data['user']),
        super(data['reference']);
  Like._({
    @required this.likeValue,
    @required this.tweet,
    @required this.user,
    @required DocumentReference reference,
  }) : super(reference);
  Like copyWith({
    int likeValue,
  }) {
    return Like._(
      likeValue: likeValue ?? this.likeValue,
      tweet: this.tweet,
      user: this.user,
      reference: this.reference,
    );
  }

  final int likeValue;
  final _LikeTweet tweet;
  final _LikeUser user;
  @override
  String get colName => "likes";
  @override
  List<String> get keys {
    return [
      tweet.reference?.id,
      user.reference?.id,
    ];
  }
}

final LikeDefinition = DocumentDefinition<Like>(
  mapToDoc: (data) => Like._fromMap(data),
  docToMap: (doc) {
    return {
      'likeValue': IntField(doc.likeValue, deleteOn: 0),
      'tweet': doc.tweet,
      'user': doc.user,
    };
  },
  creatableFields: [
    'likeValue',
    'tweet',
    'user',
  ],
  updatableFields: [
    'likeValue',
  ],
);

final config = FlamestoreConfig(
  projects: {
    'flamestore': ProjectConfig(
      dynamicLinkDomain: 'flamestore.page.link',
      androidPackageName: 'com.example.flamestore_example',
    ),
  },
  collectionClassMap: {
    User: 'users',
    Tweet: 'tweets',
    Like: 'likes',
  },
  documentDefinitions: {
    'users': UserDefinition,
    'tweets': TweetDefinition,
    'likes': LikeDefinition,
  },
);

Map<String, Widget Function(Document)> dynamicLinkBuilders({
  @required Widget Function(Tweet tweet) tweetBuilder,
}) {
  return {
    'tweets': (document) => tweetBuilder(document as Tweet),
  };
}
