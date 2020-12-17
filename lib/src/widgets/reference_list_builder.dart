part of '../../flamestore.dart';

class ReferenceListBuilder<T extends Document> extends StatefulWidget {
  ReferenceListBuilder({
    @required this.documentListKey,
    @required this.builder,
    this.onEmptyWidget,
    Flamestore flamestore,
    Key key,
  })  : _flamestore = flamestore ?? Flamestore.instance,
        super(key: key);

  final Widget Function(List<DocumentReference> document, bool hasMore) builder;
  final DocumentListKey<T> documentListKey;
  final Flamestore _flamestore;
  final Widget onEmptyWidget;

  @override
  _ListViewBuilderState<T> createState() => _ListViewBuilderState<T>();
}

class _ListViewBuilderState<T extends Document>
    extends State<ReferenceListBuilder<T>> {
  @override
  void initState() {
    widget._flamestore.getList(widget.documentListKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentListState>(
      stream: widget._flamestore._streamOfList(widget.documentListKey),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          return widget.builder(snapshot.data.docs, snapshot.data.hasMore);
        }
        return widget.onEmptyWidget ?? Container();
      },
    );
  }
}
