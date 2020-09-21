part of '../../flamestore.dart';

class _StateListData extends Equatable {
  _StateListData({
    List<DocumentReference> refs,
    this.lastDocument,
    this.hasMore = true,
  }) : refs = refs ?? [];
  final List<DocumentReference> refs;
  final DocumentSnapshot lastDocument;
  final bool hasMore;

  @override
  List<Object> get props => [...refs.map((e) => e.id).toList(), lastDocument];

  @override
  String toString() => '_StateListData'
      '\nrefs(${refs.length ?? -1}):'
      '\n${refs.map((e) => e.id).toList().prettyPrint}'
      '\nlastDocument: ${lastDocument?.id}'
      '\nhasMore:$hasMore';
}
