part of '../../flamestore.dart';

class _DocumentListState {
  _DocumentListState({
    List<DocumentReference> refs,
    this.lastDoc,
    this.hasMore = true,
  }) : refs = refs ?? [];
  final List<DocumentReference> refs;
  final DocumentSnapshot lastDoc;
  final bool hasMore;
}
