part of '../../flamestore.dart';

class DocumentBuilder<T extends Document> extends StatefulWidget {
  DocumentBuilder(
    this.document, {
    @required this.builder,
    this.allowNull = false,
    Flamestore flamestore,
    Key key,
  })  : _flamestore = flamestore ?? Flamestore.instance,
        super(key: key);

  final Flamestore _flamestore;
  final T document;
  final Widget Function(BuildContext context, T state) builder;
  final bool allowNull;

  @override
  _DocumentBuilderState<T> createState() => _DocumentBuilderState<T>();
}

class _DocumentBuilderState<T extends Document>
    extends State<DocumentBuilder<T>> {
  @override
  void initState() {
    widget._flamestore.getDoc(widget.document);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.document.keys.contains(null)) {
      return Container();
    }
    final path = widget.document.reference.path;
    return StreamBuilder<T>(
      stream: widget._flamestore._docStreamWherePath<T>(path),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container();
        }
        if (snapshot.hasData) {
          return widget.builder(context, snapshot.data);
        }
        if (widget.allowNull) {
          return widget.builder(context, null);
        }
        return Container();
      },
    );
  }
}
