part of '../../flamestore.dart';

class StateListProvider extends StatefulWidget {
  StateListProvider({
    @required this.builder,
    @required this.stateList,
    Flamestore flamestore,
    Key key,
  })  : _flamestore = flamestore ?? Flamestore.instance,
        super(key: key);
  final Widget Function(List<DocumentReference> list) builder;
  final StateList stateList;
  final Flamestore _flamestore;

  @override
  _StateListProviderState createState() => _StateListProviderState();
}

class _StateListProviderState extends State<StateListProvider> {
  @override
  void initState() {
    Logger(printer: PrettyPrinter(methodCount: 1)).v(widget.stateList);
    widget._flamestore.listFetch(widget.stateList);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget._flamestore.listStream(widget.stateList),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          return widget.builder(snapshot.data);
        }
        return Container();
      },
    );
  }
}
