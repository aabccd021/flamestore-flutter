part of '../../flamestore.dart';

class DocumentBuilder<T extends Document> extends StatefulWidget {
  DocumentBuilder({
    @required this.where,
    @required this.builder,
    this.onStateNullWidget,
    this.onStateInactive,
    this.onErrorWidget,
    this.allowNull = false,
    Flamestore flamestore,
    Key key,
  })  : _flamestore = flamestore ?? Flamestore.instance,
        reference = null,
        super(key: key);

  DocumentBuilder.fromReference({
    @required this.reference,
    @required this.builder,
    this.onStateNullWidget,
    this.onStateInactive,
    this.onErrorWidget,
    this.allowNull = false,
    Flamestore flamestore,
    Key key,
  })  : _flamestore = flamestore ?? Flamestore.instance,
        where = null,
        super(key: key);

  final Widget onStateNullWidget;
  final Widget onStateInactive;
  final Widget onErrorWidget;
  final Flamestore _flamestore;
  final T where;
  final DocumentReference reference;
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
    if (widget.where != null) {
      flamestore.getDoc(widget.where);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: widget.where == null
          ? flamestore._docStreamWhereRef<T>(widget.reference)
          : flamestore._docStreamWhere(widget.where),
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
