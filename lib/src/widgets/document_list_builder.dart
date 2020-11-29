part of '../../flamestore.dart';

class DocumentListBuilder extends StatefulWidget {
  DocumentListBuilder({
    @required this.documentListKey,
    @required this.builder,
    this.onEmptyWidget,
    Flamestore flamestore,
    Key key,
  })  : _flamestore = flamestore ?? Flamestore.instance,
        super(key: key);

  final Widget Function(
    List<DocumentReference> document,
    bool hasMore,
  ) builder;
  final DocumentListKey documentListKey;
  final Flamestore _flamestore;
  final Widget onEmptyWidget;

  @override
  _ListViewBuilderState createState() => _ListViewBuilderState();
}

class _ListViewBuilderState extends State<DocumentListBuilder> {
  @override
  void initState() {
    widget._flamestore.getList(widget.documentListKey).then((value) => print('fetched'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentListState>(
      stream: widget._flamestore._streamOfList(widget.documentListKey),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          return widget.builder(snapshot.data.documents, snapshot.data.hasMore);
        }
        return widget.onEmptyWidget ?? Container();
      },
    );
  }
}
