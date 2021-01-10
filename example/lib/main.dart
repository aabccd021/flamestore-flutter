import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_core/firebase_core.dart';
import 'package:flamestore/flamestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

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
  await Flamestore.instance.initialize(config);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flamestore Demo',
      darkTheme: ThemeData(brightness: Brightness.dark),
      home: DynamicLinkHandler(
        builders: dynamicLinkBuilders(
          tweetBuilder: (tweet) {
            return Scaffold(
              appBar: AppBar(title: Text(tweet.reference.path)),
              body: Center(child: TweetWidget(tweet: tweet, user: null)),
            );
          },
        ),
        child: MyHomePage(),
      ),
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
    _signIn();
    super.initState();
  }

  Flamestore flamestore;
  User currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: currentUser != null
            ? GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) {
                      return DocumentBuilder<User>(
                        keyDocument: currentUser,
                        builder: (user) => UserPage(user),
                      );
                    },
                  ),
                ),
                child: Icon(Icons.account_circle_outlined),
              )
            : null,
        title: Text('Flamestore Demo'),
        actions: [
          currentUser == null
              ? FlatButton(child: Text('Login'), onPressed: _signIn)
              : FlatButton(child: Text('Logout'), onPressed: _signOut)
        ],
      ),
      body: ReferenceListBuilder(
        documentListKey: TweetList(),
        onEmptyWidget: Text('empty'),
        builder: (references, hasMore) {
          return ListView(
            children: [
              if (currentUser != null) TweetCount(currentUser),
              if (currentUser != null) TweetForm(user: currentUser),
              RaisedButton(
                onPressed: () => flamestore.refreshList(TweetList()),
                child: Text('Refresh List'),
              ),
              ...references.map((reference) {
                return DocumentBuilder<Tweet>.fromReference(
                  reference: reference,
                  builder: (tweet) {
                    return TweetWidget(tweet: tweet, user: currentUser);
                  },
                );
              }).toList(),
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
    final defaultUserDoc = User(
      uid: firebaseCurrentUser.uid,
      userName: 'user' + Random().nextInt(100000).toString(),
    );
    final userDocument = await flamestore.createDocIfAbsent(defaultUserDoc);
    setState(() => currentUser = userDocument);
  }
}

class TweetCount extends StatelessWidget {
  const TweetCount(this.keyUser, {Key key}) : super(key: key);

  final User keyUser;

  @override
  Widget build(BuildContext context) {
    return DocumentBuilder<User>(
      keyDocument: keyUser,
      builder: (user) => Text('TweetCount: ${user.tweetsCount}'),
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
    final tweet = widget.tweet;
    return Card(
      child: Column(
        children: [
          Text('userName: ${tweet?.owner?.userName}'),
          Text('tweetText: ${tweet?.tweetText}'),
          Text('likes: ${tweet?.likesSum}'),
          Text('creationTime: ${tweet?.creationTime}'),
          if (tweet.image.url != null) Image.network(tweet.image.url),
          if (tweet?.dynamicLink != null)
            ElevatedButton(
              child: Text('OPEN'),
              onPressed: () => launch(tweet?.dynamicLink),
            ),
          if (widget.user != null)
            Row(
              children: [
                LikeButton(user: widget.user, tweet: widget.tweet),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    Flamestore.instance.deleteDoc(widget.tweet);
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
    final keyLike = Like(
      user: user,
      tweet: tweet,
      likeValue: 0,
    );
    return DocumentBuilder<Like>(
      keyDocument: keyLike,
      allowNull: true,
      builder: (likeDocument) {
        final likeValue = likeDocument?.likeValue ?? 0;
        final color = likeValue != 0 ? Colors.red : null;
        return Row(
          children: [
            IconButton(
              color: color,
              icon: Icon(Icons.favorite),
              onPressed: () {
                flamestore.setDoc(
                  keyLike.copyWith(likeValue: (likeValue + 1) % 5),
                  debounce: Duration(seconds: 2),
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
  ImagePickerController _controller = ImagePickerController();
  @override
  void initState() {
    flamestore = widget._flamestore;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Flamestore flamestore;
  String tweet = '';
  @override
  Widget build(BuildContext context) {
    return ImagePickerBuilder(
      controller: _controller,
      builder: (snapshot) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (text) => setState(() => tweet = text),
                      decoration: InputDecoration(hintText: 'Type tweet here'),
                    ),
                  ),
                  SubmitTweetButton(
                    widget.user,
                    tweet,
                    image: snapshot.file,
                  ),
                ],
              ),
              snapshot.hasImageFile
                  ? Image.memory(snapshot.bytes)
                  : RaisedButton(
                      child: Text('Pick Image'),
                      onPressed: _controller.pickImage,
                    )
            ],
          ),
        );
      },
    );
  }
}

class SubmitTweetButton extends StatefulWidget {
  SubmitTweetButton(
    this.user,
    this.tweetText, {
    this.image,
    Key key,
  }) : super(key: key);
  final User user;
  final String tweetText;
  final File image;

  @override
  _SubmitTweetButtonState createState() => _SubmitTweetButtonState();
}

class _SubmitTweetButtonState extends State<SubmitTweetButton> {
  bool isSubmitting = false;
  @override
  Widget build(BuildContext context) {
    void onSubmitPressed() async {
      setState(() => isSubmitting = true);
      await Flamestore.instance.createDoc(
        Tweet(
          owner: widget.user,
          tweetText: widget.tweetText,
          image: widget.image,
        ),
        appendOnLists: [TweetList()],
      );
      setState(() => isSubmitting = false);
    }

    return RaisedButton(
      onPressed: widget.user != null && widget.tweetText.isNotEmpty
          ? onSubmitPressed
          : null,
      child: isSubmitting ? CircularProgressIndicator() : Text('Tweet'),
    );
  }
}

class UserPage extends StatefulWidget {
  UserPage(this.user, {Key key}) : super(key: key);
  final User user;

  @override
  _UserPage createState() => _UserPage();
}

class _UserPage extends State<UserPage> {
  ImagePickerController _controller = ImagePickerController();
  TextEditingController _userNameController =
      TextEditingController(text: 'newUname');
  TextEditingController _bioController = TextEditingController(text: '');

  @override
  void dispose() {
    _controller.dispose();
    _userNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Text("bio: ${widget?.user?.bio}"),
          Text("userName: ${widget?.user?.userName}"),
          GestureDetector(
            onTap: () => _controller.pickImage(),
            child: Icon(Icons.account_circle_outlined),
          ),
          TextField(
            controller: _userNameController,
            decoration: InputDecoration(labelText: 'username'),
          ),
          TextField(
            controller: _bioController,
            decoration: InputDecoration(labelText: 'bio'),
          ),
          ElevatedButton(
            onPressed: () {
              final newUserName = _userNameController.text;
              final newBio = _bioController.text;
              final newUser = widget.user.copyWith(
                userName: newUserName.isNotEmpty ? newUserName : null,
                bio: newBio.isNotEmpty ? newBio : null,
              );
              Flamestore.instance.setDoc(newUser);
            },
            child: Text('update username'),
          ),
        ],
      ),
    );
  }
}

class TweetList extends DocumentListKey<Tweet> {
  @override
  List<Object> get props => [];

  @override
  Query query(col) => col.orderBy('creationTime', descending: true);
}
