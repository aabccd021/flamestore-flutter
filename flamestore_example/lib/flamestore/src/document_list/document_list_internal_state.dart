part of '../../flamestore.dart';

class _DocumentListInternalState extends Equatable {
  _DocumentListInternalState({
    List<DocumentReference> refs,
    this.lastDoc,
    this.hasMore = true,
  }) : refs = refs ?? [];
  final List<DocumentReference> refs;
  final DocumentSnapshot lastDoc;
  final bool hasMore;

  @override
  List<Object> get props => [...refs.map((e) => e.path).toList(), lastDoc];

  @override
  String toString() => '_DocumentListState'
      '\nrefs(${refs?.length}):'
      '\n${refs?.prettyPrint}'
      '\nlastDoc: ${lastDoc?.reference?.path}'
      '\nhasMore:$hasMore';
}

