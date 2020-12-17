part of '../../flamestore.dart';

class _DocumentListState {
  _DocumentListState({
    List<DocumentReference> refs,
    this.lastDoc,
    this.hasMore = true,
  }) : references = refs ?? [];
  final List<DocumentReference> references;
  final DocumentSnapshot lastDoc;
  final bool hasMore;
}
