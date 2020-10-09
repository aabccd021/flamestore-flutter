part of '../../flamestore.dart';

class DocumentListBuilder<T extends Document, V extends DocumentList<T>>
    extends StatefulWidget {
  DocumentListBuilder(
    this.list, {
    @required this.builder,
    Flamestore flamestore,
    Key key,
  })  : _flamestore = flamestore ?? Flamestore.instance,
        super(key: key);

  final Widget Function(
    BuildContext context,
    List<T> document,
    bool hasMore,
  ) builder;
  final V list;
  final Flamestore _flamestore;

  @override
  _ListViewBuilderState<T, V> createState() => _ListViewBuilderState<T, V>();
}

class _ListViewBuilderState<T extends Document, V extends DocumentList<T>>
    extends State<DocumentListBuilder<T, V>> {
  @override
  void initState() {
    widget._flamestore.getList<T, V>(widget.list);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentListState<T>>(
      stream: widget._flamestore._streamOfList(widget.list),
      builder: (context, listSnapshot) {
        if (listSnapshot.hasData) {
          return StreamBuilder<List<T>>(
            stream: listSnapshot.data.documents,
            builder: (context, snapshot) {
              return widget.builder(
                context,
                snapshot?.data ?? [],
                listSnapshot.data.hasMore,
              );
            },
          );
        }
        return Container();
      },
    );
  }
}