part of '../../flamestore.dart';

class DocumentBuilder<T extends Document> extends StatefulWidget {
  DocumentBuilder({
    @required this.keyDocument,
    @required this.builder,
    this.onStateNullWidget,
    this.onStateInactive,
    this.onErrorWidget,
    this.allowNull = false,
    Flamestore flamestore,
    Key key,
  })  : _flamestore = flamestore ?? Flamestore.instance,
        super(key: key);

  final Widget onStateNullWidget;
  final Widget onStateInactive;
  final Widget onErrorWidget;
  final Flamestore _flamestore;
  final T keyDocument;
  final Widget Function(
    BuildContext context,
    T state,
  ) builder;
  final bool allowNull;

  @override
  _DocumentBuilderState<T> createState() => _DocumentBuilderState<T>();
}

class _DocumentBuilderState<T extends Document>
    extends State<DocumentBuilder<T>> {
  Flamestore flamestore;
  @override
  void initState() {
    flamestore = widget._flamestore;
    flamestore.getDoc(widget.keyDocument);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final keyDocument = widget.keyDocument;
    if (keyDocument.keys.contains(null)) {
      return Container();
    }
    return StreamBuilder<T>(
      stream: flamestore._docStreamWherePath<T>(keyDocument.reference.path),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return widget.onErrorWidget ?? Container();
        }
        if (snapshot.hasData) {
          return widget.builder(context, snapshot.data);
        }
        if (widget.allowNull) {
          return widget.builder(context, null);
        }
        return widget.onStateNullWidget ?? Container();
      },
    );
  }
}
