import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flamestore_example/docs.dart';
import 'package:flamestore_example/flamestore/flamestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
      theme: ThemeData(
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
    Flamestore flamestore,
  })  : _flamestore = flamestore ?? Flamestore.instance,
        super(key: key);

  final Flamestore _flamestore;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  UserDocument currentUser;

  @override
  Widget build(BuildContext context) {
    final documentList = TweetList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Flamestore Demo'),
        actions: [
          currentUser == null
              ? FlatButton(child: Text('Login'), onPressed: _signIn)
              : FlatButton(child: Text('Logout'), onPressed: _signOut)
        ],
      ),
      body: DocumentListBuilder<TweetDocument, TweetList>(
        documentList: documentList,
        builder: (_, docs, hasMore) {
          return ListView(
            children: [
              if (currentUser != null) TweetForm(user: currentUser),
              RaisedButton(
                onPressed: () => widget._flamestore.refreshList(documentList),
                child: Text('Refresh List'),
              ),
              ...docs
                  .map((doc) => Tweet(tweet: doc, user: currentUser))
                  .toList(),
              RaisedButton(
                onPressed: hasMore
                    ? () => widget._flamestore.getList(documentList)
                    : null,
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
    final key = UserDocument(uid: firebaseCurrentUser.uid);
    final randomUserName = 'user' + Random().nextInt(100000).toString();
    final userDoc = await widget._flamestore.getDoc(key, fromCache: false) ??
        await widget._flamestore.setDoc(key.copyWith(userName: randomUserName));
    setState(() => currentUser = userDoc);
  }
}

class Tweet extends StatefulWidget {
  const Tweet({
    @required this.tweet,
    @required this.user,
    Key key,
  }) : super(key: key);
  final TweetDocument tweet;
  final UserDocument user;

  @override
  _TweetState createState() => _TweetState();
}

class _TweetState extends State<Tweet> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text('userName: ${widget.tweet?.userName}'),
          Text('tweetText: ${widget.tweet?.tweetText}'),
          Text('likes: ${widget.tweet?.likesSum}'),
          Text('creationTime: ${widget.tweet?.creationTime}'),
          if (widget.user != null)
            LikeButton(user: widget.user, tweet: widget.tweet),
        ],
      ),
    );
  }
}

class LikeButton extends StatefulWidget {
  LikeButton({
    @required this.user,
    @required this.tweet,
    Key key,
    Flamestore flamestore,
  })  : _flamestore = flamestore ?? Flamestore.instance,
        super(key: key);

  final UserDocument user;
  final TweetDocument tweet;
  final Flamestore _flamestore;

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  @override
  Widget build(BuildContext context) {
    final keyDocument = LikeDocument(
      user: widget.user?.reference,
      tweet: widget.tweet?.reference,
    );
    return DocumentBuilder<LikeDocument>(
      keyDocument: keyDocument,
      allowNull: true,
      builder: (context, document) {
        final likeValue = document?.likeValue ?? 0;
        final color = likeValue != 0 ? Colors.red : null;
        return Row(
          children: [
            IconButton(
              color: color,
              icon: Icon(Icons.favorite),
              onPressed: () {
                final newLikeValue = (likeValue + 1) % 5;
                widget._flamestore.setDoc(
                  keyDocument.copyWith(likeValue: newLikeValue),
                );
              },
            ),
            Text(likeValue.toString(), style: TextStyle(color: color))
          ],
        );
      },
    );
  }
}

class TweetForm extends StatefulWidget {
  TweetForm({
    @required this.user,
    Key key,
    Flamestore flamestore,
  })  : _flamestore = flamestore ?? Flamestore.instance,
        super(key: key);

  final UserDocument user;
  final Flamestore _flamestore;

  @override
  _TweetFormState createState() => _TweetFormState();
}

class _TweetFormState extends State<TweetForm> {
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
    widget._flamestore.setDoc(
      TweetDocument(
        user: widget.user.reference,
        userName: widget.user.userName,
        tweetText: tweet,
      ),
      appendOnLists: [TweetList()],
    );
  }
}

class TweetList extends DocumentList<TweetDocument> {
  @override
  TweetDocument get document => TweetDocument();

  @override
  List<Object> get props => [];

  @override
  Query query(CollectionReference collection) => collection;
}
