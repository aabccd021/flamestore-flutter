import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flamestore/flamestore.dart';
import 'package:flutter/widgets.dart';

class User extends Document {
  User({
    @required this.userName,
    this.bio,
    @required this.uid,
  });
  User._({
    this.userName,
    this.bio,
    this.tweetsCount,
    this.uid,
  });
  final String userName;
  final String bio;
  int tweetsCount;
  final String uid;
  User copyWith({
    String userName,
    String bio,
    String uid,
  }) {
    return User._(
      userName: userName ?? this.userName,
      bio: bio ?? this.bio,
      uid: uid ?? this.uid,
    );
  }

  @override
  String get colName => "users";

  @override
  List<String> get keys => [uid];
}

final userDefinition = DocumentDefinition<User>(
  mapToDoc: (data) => User._(
    userName: data['userName'],
    bio: data['bio'],
    tweetsCount: data['tweetsCount'],
    uid: data['uid'],
  ),
  defaultValueMap: (doc) {
    final userDoc = doc as User;
    return {
      'tweetsCount': 0,
    };
  },
  docToMap: (doc) {
    final userDoc = doc as User;
    return {
      'userName': userDoc.userName,
      'bio': userDoc.bio,
      'tweetsCount': userDoc.tweetsCount,
      'uid': userDoc.uid,
    };
  },
  creatableFields: () => [
    'userName',
    'bio',
    'uid',
  ],
  sums: (doc) {
    final userDoc = doc as User;
    return [];
  },
  counts: (doc) {
    final userDoc = doc as User;
    return [];
  },
  docShouldBeDeleted: (doc) {
    final userDoc = doc as User;
    return false;
  },
);

class _TweetUser {
  _TweetUser({
    @required this.reference,
    @required this.userName,
  });

  _TweetUser.fromUser({
    @required User user,
  })  : reference = user.reference,
        userName = user.userName;

  _TweetUser.fromMap(
    Map<String, dynamic> map,
  )   : reference = map['reference'],
        userName = map['userName'];

  final DocumentReference reference;
  final String userName;

  Map<String, dynamic> toDataMap() {
    return {
      'reference': reference,
      'userName': userName,
    };
  }

  _TweetUser copyWith({
    DocumentReference reference,
    String userName,
  }) {
    return _TweetUser(
      reference: reference ?? this.reference,
      userName: userName ?? this.userName,
    );
  }
}

class Tweet extends Document {
  Tweet({
    @required User user,
    @required this.tweetText,
    this.dynamicLink,
  }) : user = _TweetUser.fromUser(user: user);
  Tweet._({
    this.user,
    this.tweetText,
    this.likesSum,
    this.creationTime,
    this.hotness,
    this.dynamicLink,
  });
  final _TweetUser user;
  final String tweetText;
  int likesSum;
  DateTime creationTime;
  double hotness;
  final String dynamicLink;
  Tweet copyWith({
    User user,
    String tweetText,
    String dynamicLink,
  }) {
    return Tweet._(
      user: user != null ? _TweetUser.fromUser(user: user) : this.user,
      tweetText: tweetText ?? this.tweetText,
      dynamicLink: dynamicLink ?? this.dynamicLink,
    );
  }

  @override
  String get colName => "tweets";

  @override
  List<String> get keys => [];
}

final tweetDefinition = DocumentDefinition<Tweet>(
  mapToDoc: (data) => Tweet._(
    user: _TweetUser.fromMap(data['user']),
    tweetText: data['tweetText'],
    likesSum: data['likesSum'],
    creationTime: data['creationTime'] is DateTime
        ? data['creationTime']
        : data['creationTime']?.toDate(),
    hotness: data['hotness']?.toDouble(),
    dynamicLink: data['dynamicLink'],
  ),
  defaultValueMap: (doc) {
    final tweetDoc = doc as Tweet;
    return {
      'likesSum': 0,
      'creationTime': DateTime.now(),
      'dynamicLink': DynamicLinkField(
        title: tweetDoc.tweetText,
        description: "tweet description",
        isSuffixShort: true,
      ),
    };
  },
  docToMap: (doc) {
    final tweetDoc = doc as Tweet;
    return {
      'user': tweetDoc.user.toDataMap(),
      'tweetText': tweetDoc.tweetText,
      'likesSum': tweetDoc.likesSum,
      'creationTime': tweetDoc.creationTime,
      'hotness': tweetDoc.hotness,
      'dynamicLink': tweetDoc.dynamicLink,
    };
  },
  creatableFields: () => [
    'user',
    'tweetText',
    'dynamicLink',
  ],
  sums: (doc) {
    final tweetDoc = doc as Tweet;
    return [];
  },
  counts: (doc) {
    final tweetDoc = doc as Tweet;
    return [
      Count(
        countDocCol: 'users',
        countDocRef: tweetDoc.user.reference,
        countField: 'tweetsCount',
      ),
    ];
  },
  docShouldBeDeleted: (doc) {
    final tweetDoc = doc as Tweet;
    return false;
  },
);

class _LikeTweet {
  _LikeTweet({
    @required this.reference,
  });

  _LikeTweet.fromTweet({
    @required Tweet tweet,
  }) : reference = tweet.reference;

  _LikeTweet.fromMap(
    Map<String, dynamic> map,
  ) : reference = map['reference'];

  final DocumentReference reference;

  Map<String, dynamic> toDataMap() {
    return {
      'reference': reference,
    };
  }

  _LikeTweet copyWith({
    DocumentReference reference,
  }) {
    return _LikeTweet(
      reference: reference ?? this.reference,
    );
  }
}

class _LikeUser {
  _LikeUser({
    @required this.reference,
  });

  _LikeUser.fromUser({
    @required User user,
  }) : reference = user.reference;

  _LikeUser.fromMap(
    Map<String, dynamic> map,
  ) : reference = map['reference'];

  final DocumentReference reference;

  Map<String, dynamic> toDataMap() {
    return {
      'reference': reference,
    };
  }

  _LikeUser copyWith({
    DocumentReference reference,
  }) {
    return _LikeUser(
      reference: reference ?? this.reference,
    );
  }
}

class Like extends Document {
  Like({
    @required this.likeValue,
    @required Tweet tweet,
    @required User user,
  })  : tweet = _LikeTweet.fromTweet(tweet: tweet),
        user = _LikeUser.fromUser(user: user);
  Like._({
    this.likeValue,
    this.tweet,
    this.user,
  });
  final int likeValue;
  final _LikeTweet tweet;
  final _LikeUser user;
  Like copyWith({
    int likeValue,
    Tweet tweet,
    User user,
  }) {
    return Like._(
      likeValue: likeValue ?? this.likeValue,
      tweet: tweet != null ? _LikeTweet.fromTweet(tweet: tweet) : this.tweet,
      user: user != null ? _LikeUser.fromUser(user: user) : this.user,
    );
  }

  @override
  String get colName => "likes";

  @override
  List<String> get keys => [
        user.reference?.id,
        tweet.reference?.id,
      ];
}

final likeDefinition = DocumentDefinition<Like>(
  mapToDoc: (data) => Like._(
    likeValue: data['likeValue'],
    tweet: _LikeTweet.fromMap(data['tweet']),
    user: _LikeUser.fromMap(data['user']),
  ),
  defaultValueMap: (doc) {
    final likeDoc = doc as Like;
    return {};
  },
  docToMap: (doc) {
    final likeDoc = doc as Like;
    return {
      'likeValue': likeDoc.likeValue,
      'tweet': likeDoc.tweet.toDataMap(),
      'user': likeDoc.user.toDataMap(),
    };
  },
  creatableFields: () => [
    'likeValue',
    'tweet',
    'user',
  ],
  sums: (doc) {
    final likeDoc = doc as Like;
    return [
      Sum(
        field: 'likeValue',
        sumDocCol: 'tweets',
        sumDocRef: likeDoc.tweet.reference,
        sumField: 'likesSum',
      ),
    ];
  },
  counts: (doc) {
    final likeDoc = doc as Like;
    return [];
  },
  docShouldBeDeleted: (doc) {
    final likeDoc = doc as Like;
    return likeDoc.likeValue == 0;
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
