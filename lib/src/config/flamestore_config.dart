part of '../../flamestore.dart';

class FlamestoreConfig {
  FlamestoreConfig({
    @required this.projects,
    @required this.collectionClassMap,
    @required this.documentDefinitions,
    @required this.sums,
    @required this.counts,
  });

  final Map<String, ProjectConfig> projects;
  final Map<Type, String> collectionClassMap;
  final Map<String, DocumentDefinition> documentDefinitions;
  final Map<String, List<Sum> Function(Document)> sums;
  final Map<String, List<Count> Function(Document)> counts;
}
