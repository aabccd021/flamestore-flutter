part of '../../flamestore.dart';

class DocumentListState {
  DocumentListState(this.hasMore, this.documents);
  final bool hasMore;
  final List<DocumentReference> documents;
}
