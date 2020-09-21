part of '../../flamestore.dart';

class StateProvider<T extends StateData> extends StatefulWidget {
  StateProvider({
    @required this.builder,
    @required this.fetcher,
    this.onStateNullWidget,
    this.onStateInactive,
    this.onErrorWidget,
    Flamestore flamestore,
    Key key,
  })  : _flamestore = flamestore ?? Flamestore.instance,
        assert(T != StateData),
        super(key: key);
  final Widget onStateNullWidget;
  final Widget onStateInactive;
  final Widget onErrorWidget;
  final Flamestore _flamestore;
  final StateFetcher<T> fetcher;
  final Widget Function(
    BuildContext context,
    T state,
  ) builder;

  @override
  _StateProviderState<T> createState() => _StateProviderState<T>();
}

class _StateProviderState<T extends StateData> extends State<StateProvider<T>> {
  @override
  void initState() {
    widget._flamestore.fetch<T>(widget.fetcher);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: widget._flamestore.streamOf<T>(widget.fetcher),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return widget.onErrorWidget ?? Container();
        }
        if (snapshot.hasData) {
          return widget.builder(context, snapshot.data);
        }
        return widget.onStateNullWidget ?? Container();
      },
    );
  }
}
