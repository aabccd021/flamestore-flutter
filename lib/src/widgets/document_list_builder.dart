part of '../../flamestore.dart';

class DocumentListBuilder extends StatefulWidget {
  DocumentListBuilder(
    this.list, {
    @required this.builder,
    Flamestore flamestore,
    Key key,
  })  : _flamestore = flamestore ?? Flamestore.instance,
        super(key: key);

  final Widget Function(
    BuildContext context,
    List<DocumentReference> document,
    bool hasMore,
  ) builder;
  final DocumentList list;
  final Flamestore _flamestore;

  @override
  _ListViewBuilderState createState() => _ListViewBuilderState();
}

class _ListViewBuilderState<T extends Document, V extends DocumentList<T>>
    extends State<DocumentListBuilder> {
  @override
  void initState() {
    widget._flamestore.getList<T, V>(widget.list);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentListState>(
      stream: widget._flamestore._streamOfList(widget.list),
      builder: (context, listSnapshot) {
        if (listSnapshot.hasData) {
          return widget.builder(
            context,
            listSnapshot?.data?.documents ?? [],
            listSnapshot?.data?.hasMore ?? true,
          );
          // return StreamBuilder<List<T>>(
          //   stream: listSnapshot.data.documents,
          //   builder: (context, snapshot) {
          //     return widget.builder(
          //       context,
          //       snapshot?.data ?? [],
          //       listSnapshot.data.hasMore,
          //     );
          //   },
          // );
        }
        return Container();
      },
    );
  }
}
