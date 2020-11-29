part of '../../flamestore.dart';

class DocumentBuilder<T extends Document> extends StatefulWidget {
  DocumentBuilder(
    this.document, {
    @required this.builder,
    this.allowNull = false,
    this.fetchOnInit = true,
    this.onErrorWidget,
    this.onEmptyWidget,
    Flamestore flamestore,
    Key key,
  })  : _flamestore = flamestore ?? Flamestore.instance,
        this.reference = null,
        this.isFromReference = false,
        super(key: key);

  DocumentBuilder.fromReference(
    this.reference, {
    @required this.builder,
    this.allowNull = false,
    this.onErrorWidget,
    this.onEmptyWidget,
    Flamestore flamestore,
    Key key,
  })  : _flamestore = flamestore ?? Flamestore.instance,
        this.document = null,
        this.isFromReference = true,
        this.fetchOnInit = false,
        super(key: key);

  final Flamestore _flamestore;
  final T document;
  final Widget Function(T state) builder;
  final bool allowNull;
  final bool fetchOnInit;
  final DocumentReference reference;
  final bool isFromReference;
  final Widget onErrorWidget;
  final Widget onEmptyWidget;

  @override
  _DocumentBuilderState<T> createState() => _DocumentBuilderState<T>();
}

class _DocumentBuilderState<T extends Document>
    extends State<DocumentBuilder<T>> {
  @override
  void initState() {
    if (widget.fetchOnInit) {
      widget._flamestore.getDocument(widget.document);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFromReference) {
      return _buildStreamBuilder(widget.reference.path);
    }
    if (widget.document.keys.contains(null)) {
      return Container();
    }
    final path = widget.document.reference.path;
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
