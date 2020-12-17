part of '../../flamestore.dart';

class DynamicLinkHandler extends StatefulWidget {
  DynamicLinkHandler({
    @required this.child,
    Key key,
    FirebaseFirestore firestore,
    @required this.builders,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        super(key: key);
  final Widget child;
  final FirebaseFirestore _firestore;
  final Map<String, Widget Function(Document)> builders;

  @override
  _DynamicLinkHandlerState createState() => _DynamicLinkHandlerState();
}

class _DynamicLinkHandlerState extends State<DynamicLinkHandler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      //Handle initial deeplink
      final data = await FirebaseDynamicLinks.instance.getInitialLink();
      await _handleDynamicLink(data);
      //Handle middle deeplink
      FirebaseDynamicLinks.instance.onLink(onSuccess: _handleDynamicLink);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _handleDynamicLink(PendingDynamicLinkData dynamicLink) async {
    final deepLink = dynamicLink?.link;

    if (deepLink != null) {
      print('DYNAMIC LINK OPENED $deepLink');
      widget.builders.entries.forEach(
        (builderEntry) {
          final colName = builderEntry.key;
          final builder = builderEntry.value;
          if (deepLink.pathSegments[0] == colName) {
            final id = deepLink.pathSegments[1];
            final ref = widget._firestore.collection(colName).doc(id);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) {
                  return DocumentBuilder.fromReference(
                    reference: ref,
                    builder: builder,
                  );
                },
              ),
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
