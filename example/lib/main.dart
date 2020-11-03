import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_core/firebase_core.dart';
import 'package:flamestore/flamestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'flamestore/flamestore.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await DotEnv().load();
  final debugFirestoreIP = DotEnv().env['DEBUG_FIRESTORE_IP'];
  final debugFirestoreIpPort = '$debugFirestoreIP:8080';
  FirebaseFirestore.instance.settings = Settings(
    host: debugFirestoreIpPort,
    sslEnabled: false,
    persistenceEnabled: false,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flamestore Demo',
      darkTheme: ThemeData(brightness: Brightness.dark),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Flamestore flamestore,
  }) : _flamestore = flamestore ?? Flamestore.instance;
  final Flamestore _flamestore;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    flamestore = widget._flamestore;
    super.initState();
  }

  Flamestore flamestore;
  User currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flamestore Demo'),
        actions: [
          currentUser == null
              ? FlatButton(child: Text('Login'), onPressed: _signIn)
              : FlatButton(child: Text('Logout'), onPressed: _signOut)
        ],
      ),
      body: DocumentListBuilder<Tweet, TweetList>(
        TweetList(),
        builder: (_, docs, hasMore) {
          return ListView(
            children: [
              if (currentUser != null) TweetCount(currentUser),
              if (currentUser != null) TweetForm(user: currentUser),
              RaisedButton(
                onPressed: () => flamestore.refreshList(TweetList()),
                child: Text('Refresh List'),
              ),
              ...docs
                  .map((doc) => TweetWidget(tweet: doc, user: currentUser))
                  .toList(),
              RaisedButton(
                onPressed:
                    hasMore ? () => flamestore.getList(TweetList()) : null,
                child: Text(hasMore ? 'Load More' : 'No More Tweets'),
              )
            ],
          );
        },
      ),
    );
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    setState(() => currentUser = null);
  }

  void _signIn() async {
    final googleSignInAccount = await GoogleSignIn().signIn();
    final googleSignInAuthentication = await googleSignInAccount.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    final authResult =
        await FirebaseAuth.instance.signInWithCredential(credential);
    final user = authResult.user;
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);
    final firebaseCurrentUser = FirebaseAuth.instance.currentUser;
    assert(user.uid == firebaseCurrentUser.uid);
    final userDocument = await flamestore.createDocumentIfAbsent(
      User(
        uid: firebaseCurrentUser.uid,
        userName: 'user' + Random().nextInt(100000).toString(),
      ),
    );
    setState(() => currentUser = userDocument);
  }
}

class TweetCount extends StatelessWidget {
  const TweetCount(this.keyUser, {Key key}) : super(key: key);

  final User keyUser;

  @override
  Widget build(BuildContext context) {
    return DocumentBuilder(
      keyUser,
      builder: (_, user) => Text('TweetCount: ${user.data.tweetsCount}'),
    );
  }
}

class TweetWidget extends StatefulWidget {
  const TweetWidget({
    @required this.tweet,
    @required this.user,
  });
  final Tweet tweet;
  final User user;

  @override
  _TweetState createState() => _TweetState();
}

class _TweetState extends State<TweetWidget> {
  @override
  Widget build(BuildContext context) {
    final data = widget.tweet?.data;
    return Card(
      child: Column(
        children: [
          Text('userName: ${data?.userName}'),
          Text('tweetText: ${data?.tweetText}'),
          Text('likes: ${data?.likesSum}'),
          Text('creationTime: ${data?.creationTime}'),
          if (widget.user != null)
            Row(
              children: [
                LikeButton(user: widget.user, tweet: widget.tweet),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    Flamestore.instance.deleteDocument(widget.tweet);
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class LikeButton extends StatelessWidget {
  LikeButton({
    @required this.user,
    @required this.tweet,
    Flamestore flamestore,
  }) : flamestore = flamestore ?? Flamestore.instance;

  final User user;
  final Tweet tweet;
  final Flamestore flamestore;

  @override
  Widget build(BuildContext context) {
    final like = Like(user: user?.reference, tweet: tweet?.reference);
    return DocumentBuilder<Like>(
      like,
      allowNull: true,
      builder: (context, document) {
        final likeValue = document?.data?.likeValue ?? 0;
        final color = likeValue != 0 ? Colors.red : null;
        return Row(
          children: [
            IconButton(
              color: color,
              icon: Icon(Icons.favorite),
              onPressed: () {
                flamestore.setDocument(
                  like.copyWith(likeValue: (likeValue + 1) % 5),
                  debounce: Duration(seconds: 5),
                );
              },
            ),
            Text('$likeValue', style: TextStyle(color: color))
          ],
        );
      },
    );
  }
}

class TweetForm extends StatefulWidget {
  TweetForm({
    @required this.user,
    Flamestore flamestore,
  }) : _flamestore = flamestore ?? Flamestore.instance;

  final User user;
  final Flamestore _flamestore;

  @override
  _TweetFormState createState() => _TweetFormState();
}

class _TweetFormState extends State<TweetForm> {
  @override
  void initState() {
    flamestore = widget._flamestore;
    super.initState();
  }

  Flamestore flamestore;
  String tweet = '';
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (text) => setState(() => tweet = text),
              decoration: InputDecoration(hintText: 'Type tweet here'),
            ),
          ),
          RaisedButton(
            onPressed: tweet != '' ? onSubmitPressed : null,
            child: Text('Tweet'),
          )
        ],
      ),
    );
  }

  void onSubmitPressed() {
    widget._flamestore.createDocument(
      Tweet(
        user: widget.user.reference,
        userName: widget.user.data.userName,
        tweetText: tweet,
      ),
      appendOnLists: [TweetList()],
    );
  }
}

class TweetList extends DocumentList<Tweet> {
  @override
  Tweet get document => Tweet();

  @override
  List<Object> get props => [];

  @override
  Query query(CollectionReference collection) => collection;
}
