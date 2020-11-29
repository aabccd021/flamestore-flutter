part of '../../flamestore.dart';

class DocumentBuilder<T extends Document> extends StatefulWidget {
  DocumentBuilder({
    @required this.keyDocument,
    @required this.builder,
    this.allowNull = false,
    this.fetchOnInit = true,
    this.onErrorWidget,
    this.onEmptyWidget,
    this.onKeyNullWidget,
    Flamestore flamestore,
    Key key,
  })  : _flamestore = flamestore ?? Flamestore.instance,
        this.reference = null,
        this.isFromReference = false,
        super(key: key);

  DocumentBuilder.fromReference({
    @required this.reference,
    @required this.builder,
    this.allowNull = false,
    this.onErrorWidget,
    this.onEmptyWidget,
    this.onKeyNullWidget,
    Flamestore flamestore,
    Key key,
  })  : _flamestore = flamestore ?? Flamestore.instance,
        this.keyDocument = null,
        this.isFromReference = true,
        this.fetchOnInit = false,
        super(key: key);

  final Flamestore _flamestore;
  final T keyDocument;
  final Widget Function(T state) builder;
  final bool allowNull;
  final bool fetchOnInit;
  final DocumentReference reference;
  final bool isFromReference;
  final Widget onErrorWidget;
  final Widget onEmptyWidget;
  final Widget onKeyNullWidget;

  @override
  _DocumentBuilderState<T> createState() => _DocumentBuilderState<T>();
}

class _DocumentBuilderState<T extends Document>
    extends State<DocumentBuilder<T>> {
  @override
  void initState() {
    if (widget.fetchOnInit) {
      widget._flamestore.getDocument(widget.keyDocument);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFromReference) {
      return _buildStreamBuilder(widget.reference.path);
    }
    if (widget.keyDocument.keys.contains(null)) {
      return widget.onKeyNullWidget ?? Container();
    }
    final path = widget.keyDocument.reference.path;
    return _buildStreamBuilder(path);
  }

  StreamBuilder _buildStreamBuilder(String path) {
    return StreamBuilder<T>(
      stream: widget._flamestore._docStreamWherePath<T>(path),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return widget.onErrorWidget ?? Container();
        }
        if (snapshot.hasData) {
          return widget.builder(snapshot.data);
        }
        if (widget.allowNull) {
          return widget.builder(null);
        }
        return widget.onEmptyWidget ?? Container();
      },
    );
  }
}
