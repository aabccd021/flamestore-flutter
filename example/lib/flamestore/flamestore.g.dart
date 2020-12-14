import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flamestore/flamestore.dart';
import 'package:flutter/widgets.dart';

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
  }) : data = _UserData(
          uid: uid,
          userName: userName,
          bio: bio,
        );

  User._({
    String uid,
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
    return User._(
        uid: data['uid'],
        userName: data['userName'],
        bio: data['bio'],
        tweetsCount: data['tweetsCount']);
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
  User mergeDataWith(Document other) {
    return super.mergeDataWith(other) as User;
  }

  User copyWith({
    String uid,
    String userName,
    String bio,
    int tweetsCount,
  }) {
    return User._(
      uid: uid ?? data.uid,
      userName: userName ?? data.userName,
      bio: bio ?? data.bio,
      tweetsCount: tweetsCount ?? data.tweetsCount,
    );
  }
}

class _TweetUser {
  _TweetUser({
    @required this.reference,
    @required this.userName,
  });

  final DocumentReference reference;
  final String userName;

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

class _TweetData {
  _TweetData({
    this.user,
    this.tweetText,
    this.likesSum,
    this.creationTime,
    this.hotness,
    this.dynamicLink,
  });
  final _TweetUser user;
  final String tweetText;
  final int likesSum;
  final DateTime creationTime;
  final double hotness;
  final String dynamicLink;
}

class Tweet extends Document {
  Tweet({
    User user,
    String tweetText,
    String dynamicLink,
  }) : data = _TweetData(
          user: _TweetUser(
            reference: user?.reference,
            userName: user?.data?.userName,
          ),
          tweetText: tweetText,
          dynamicLink: dynamicLink,
        );

  Tweet._({
    _TweetUser user,
    String tweetText,
    int likesSum,
    DateTime creationTime,
    double hotness,
    String dynamicLink,
  }) : data = _TweetData(
          user: user,
          tweetText: tweetText,
          likesSum: likesSum,
          creationTime: creationTime,
          hotness: hotness,
          dynamicLink: dynamicLink,
        );

  final _TweetData data;

  @override
  String get collectionName => 'tweets';

  @override
  Tweet fromMap(Map<String, dynamic> data) {
    return Tweet._(
        user: _TweetUser(
          reference: data['user']['reference'],
          userName: data['user']['userName'],
        ),
        tweetText: data['tweetText'],
        likesSum: data['likesSum'],
        creationTime: data['creationTime'] is DateTime
            ? data['creationTime']
            : data['creationTime']?.toDate(),
        hotness: data['hotness']?.toDouble(),
        dynamicLink: data['dynamicLink']);
  }

  @override
  Map<String, dynamic> get defaultValueMap {
    return {
      'likesSum': 0,
      'creationTime': DateTime.now(),
      'dynamicLink': DynamicLinkField(
        title: data.tweetText,
        description: "tweet description",
        isSuffixShort: true,
      ),
    };
  }

  @override
  Map<String, dynamic> toDataMap() {
    return {
      'user': {
        'reference': data.user.reference,
        'userName': data.user.userName,
      },
      'tweetText': data.tweetText,
      'likesSum': data.likesSum,
      'creationTime': data.creationTime,
      'hotness': data.hotness,
      'dynamicLink': data.dynamicLink,
    };
  }

  @override
  List<String> firestoreCreateFields() {
    return [
      'user',
      'tweetText',
      'hotness',
      'dynamicLink',
    ];
  }

  @override
  List<Sum> get sums => [];

  @override
  List<Count> get counts => [
        Count(
          countDocument: data.user.reference,
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
  Tweet mergeDataWith(Document other) {
    return super.mergeDataWith(other) as Tweet;
  }

  Tweet copyWith({
    DocumentReference user,
    String userName,
    String tweetText,
    int likesSum,
    DateTime creationTime,
    double hotness,
    String dynamicLink,
  }) {
    return Tweet._(
      user: data.user?.copyWith(reference: user, userName: userName),
      tweetText: tweetText ?? data.tweetText,
      likesSum: likesSum ?? data.likesSum,
      creationTime: creationTime ?? data.creationTime,
      hotness: hotness ?? data.hotness,
      dynamicLink: dynamicLink ?? data.dynamicLink,
    );
  }
}

class _LikeTweet {
  final DocumentReference reference;

  _LikeTweet({
    @required this.reference,
  });

  _LikeTweet copyWith({
    DocumentReference reference,
  }) {
    return _LikeTweet(reference: reference ?? this.reference);
  }
}

class _LikeUser {
  final DocumentReference reference;

  _LikeUser({@required this.reference});

  _LikeUser copyWith({
    DocumentReference reference,
  }) {
    return _LikeUser(reference: reference ?? this.reference);
  }
}

class _LikeData {
  _LikeData({
    this.likeValue,
    this.user,
    this.tweet,
  });
  final int likeValue;
  final _LikeUser user;
  final _LikeTweet tweet;
}

class Like extends Document {
  Like({
    int likeValue,
    @required User user,
    @required Tweet tweet,
  }) : data = _LikeData(
          likeValue: likeValue,
          user: _LikeUser(reference: user.reference),
          tweet: _LikeTweet(reference: tweet.reference),
        );

  Like._({
    int likeValue,
    _LikeUser user,
    _LikeTweet tweet,
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
    return Like._(
      likeValue: data['likeValue'],
      user: _LikeUser(reference: data['user']['reference']),
      tweet: _LikeTweet(reference: data['tweet']['reference']),
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
      'user': {
        'reference': data.user.reference,
      },
      'tweet': {
        'reference': data.tweet.reference,
      }
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
          sumDocument: data.tweet.reference,
          sumField: 'likesSum',
        ),
      ];

  @override
  List<Count> get counts => [];

  @override
  bool get shouldBeDeleted => data.likeValue == 0;

  @override
  List<String> get keys => [
        data?.user?.reference?.id,
        data?.tweet?.reference?.id,
      ];

  @override
  Like fromSnapshot(DocumentSnapshot snapshot) {
    return super.fromSnapshot(snapshot) as Like;
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
    return Like._(
      likeValue: likeValue ?? data.likeValue,
      user: data.user.copyWith(reference: user),
      tweet: data.tweet.copyWith(reference: tweet),
    );
  }
}

final config = FlamestoreConfig(projects: {
  'flamestore': ProjectConfig(
    dynamicLinkDomain: 'flamestore.page.link',
    androidPackageName: 'com.example.flamestore_example',
  )
});

Map<String, Widget Function(Document)> dynamicLinkBuilders({
  @required Widget Function(Tweet tweet) tweetBuilder,
}) {
  return {
    'tweets': (Document document) => tweetBuilder(document as Tweet),
  };
}
