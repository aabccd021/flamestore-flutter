part of '../../flamestore.dart';

class _DocumentListState {
  _DocumentListState({
    List<DocumentReference> references,
    this.lastDocument,
    this.hasMore = true,
  }) : references = references ?? [];
  final List<DocumentReference> references;
  final DocumentSnapshot lastDocument;
  final bool hasMore;
}
