import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flamestore/flamestore.dart';
import 'package:flutter/widgets.dart';

class _UserImage {
  String url;
  int width;
  int height;

  _UserImage._fromMap(Map<String, dynamic> map) {
    if (map != null) {
      url = map['url'];
      width = map['width'];
      height = map['height'];
    }
  }
}

class User extends Document {
  User({
    @required this.userName,
    this.bio,
    @required this.uid,
    File image,
  })  : tweetsCount = 0,
        _image = image,
        image = null,
        super(null);

  User._fromMap(Map<String, dynamic> data)
      : userName = StringField.fromMap(data['userName']).value,
        bio = StringField.fromMap(data['bio']).value,
        tweetsCount = CountField.fromMap(data['tweetsCount']).value,
        uid = StringField.fromMap(data['uid']).value,
        image = _UserImage._fromMap(data['image']),
        _image = null,
        super(data['reference']);

  User._(
    this._image, {
    @required this.userName,
    @required this.bio,
    @required this.tweetsCount,
    @required this.uid,
    @required this.image,
    @required DocumentReference reference,
  }) : super(reference);

  User copyWith({
    String userName,
    String bio,
    File image,
  }) {
    return User._(
      image ?? this._image,
      userName: userName ?? this.userName,
      bio: bio ?? this.bio,
      tweetsCount: this.tweetsCount,
      uid: this.uid,
      image: this.image,
      reference: this.reference,
    );
  }

  final String userName;
  final String bio;
  final int tweetsCount;
  final String uid;
  final File _image;
  final _UserImage image;

  @override
  String get colName => "users";

  @override
  List<String> get keys {
    return [
      uid,
    ];
  }
}

final userDefinition = DocumentDefinition<User>(
  mapToDoc: (data) => User._fromMap(data),
  docToMap: (doc) {
    return {
      'userName': StringField(doc.userName),
      'bio': StringField(doc.bio),
      'tweetsCount': CountField(doc.tweetsCount),
      'uid': StringField(doc.uid),
      'image': ImageField(
        doc?.image?.url,
        file: doc._image,
        userId: doc.uid,
      ),
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

class _TweetUser extends ReferenceField {
  _TweetUser(DocumentReference reference, {@required this.userName})
      : super(
          reference,
          fields: {
            'userName': userName,
          },
        );
  _TweetUser._fromUser(User user)
      : userName = user.userName,
        super(
          user.reference,
          fields: {
            'userName': user.userName,
          },
        );
  _TweetUser._fromMap(Map<String, dynamic> map)
      : userName = map['userName'],
        super.fromMap(map);

  final String userName;
}

class _TweetImage {
  String url;
  int width;
  int height;

  _TweetImage._fromMap(Map<String, dynamic> map) {
    if (map != null) {
      url = map['url'];
      width = map['width'];
      height = map['height'];
    }
  }
}

class Tweet extends Document {
  Tweet({
    @required User user,
    @required this.tweetText,
    File image,
  })  : user = _TweetUser._fromUser(user),
        likesSum = null,
        creationTime = null,
        dynamicLink = null,
        hotness = null,
        _image = image,
        image = null,
        super(null);
  Tweet._fromMap(Map<String, dynamic> data)
      : user = _TweetUser._fromMap(data['user']),
        tweetText = StringField.fromMap(data['tweetText']).value,
        likesSum = SumField.fromMap(data['likesSum']).value,
        creationTime = TimestampField.fromMap(data['creationTime']).value,
        hotness = FloatField.fromMap(data['hotness']).value,
        dynamicLink = DynamicLinkField.fromMap(data['dynamicLink']).value,
        image = _TweetImage._fromMap(data['image']),
        _image = null,
        super(data['reference']);
  Tweet._(
    this._image, {
    @required this.user,
    @required this.tweetText,
    @required this.likesSum,
    @required this.creationTime,
    @required this.hotness,
    @required this.dynamicLink,
    @required this.image,
    @required DocumentReference reference,
  }) : super(reference);
  Tweet copyWith({
    String tweetText,
    File image,
  }) {
    return Tweet._(
      image ?? this._image,
      tweetText: tweetText ?? this.tweetText,
      user: this.user,
      likesSum: this.likesSum,
      creationTime: this.creationTime,
      hotness: this.hotness,
      dynamicLink: this.dynamicLink,
      image: this.image,
      reference: this.reference,
    );
  }

  final _TweetUser user;
  final String tweetText;
  final double likesSum;
  final DateTime creationTime;
  final double hotness;
  final String dynamicLink;
  final File _image;
  final _TweetImage image;

  @override
  String get colName => "tweets";
}

final tweetDefinition = DocumentDefinition<Tweet>(
  mapToDoc: (data) => Tweet._fromMap(data),
  docToMap: (doc) {
    return {
      'user': doc.user,
      'tweetText': StringField(doc.tweetText),
      'likesSum': SumField(doc.likesSum?.toDouble()),
      'creationTime': TimestampField(
        doc.creationTime,
        isServerTimestamp: true,
      ),
      'hotness': FloatField(doc.hotness),
      'dynamicLink': DynamicLinkField(
        doc.dynamicLink,
        title: doc.tweetText,
        description: "tweet description",
        isSuffixShort: true,
      ),
      'image': ImageField(
        doc?.image?.url,
        file: doc._image,
        userId: doc.user.reference.id,
      ),
    };
  },
  creatableFields: [
    'user',
    'tweetText',
    'dynamicLink',
  ],
  updatableFields: [
    'tweetText',
  ],
  counts: (doc) {
    return [
      Count(
        countDocCol: 'users',
        ref: doc.user.reference,
        fieldName: 'tweetsCount',
      ),
    ];
  },
);

class _LikeTweet extends ReferenceField {
  _LikeTweet(DocumentReference reference) : super(reference);
  _LikeTweet._fromTweet(Tweet user) : super(user.reference);
  _LikeTweet._fromMap(Map<String, dynamic> map) : super(map['reference']);
}

class _LikeUser extends ReferenceField {
  _LikeUser(DocumentReference reference) : super(reference);
  _LikeUser._fromUser(User user) : super(user.reference);
  _LikeUser._fromMap(Map<String, dynamic> map) : super(map['reference']);
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
      : likeValue = IntField(data['likeValue']).value,
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
      reference: reference,
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
      user.reference?.id,
      tweet.reference?.id,
    ];
  }
}

final likeDefinition = DocumentDefinition<Like>(
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
  sums: (doc) {
    return [
      Sum(
        field: 'likeValue',
        ref: doc.tweet.reference,
        fieldName: 'likesSum',
      ),
    ];
  },
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
    'users': userDefinition,
    'tweets': tweetDefinition,
    'likes': likeDefinition,
  },
);

Map<String, Widget Function(Document)> dynamicLinkBuilders({
  @required Widget Function(Tweet tweet) tweetBuilder,
}) {
  return {
    'tweets': (document) => tweetBuilder(document as Tweet),
  };
}
