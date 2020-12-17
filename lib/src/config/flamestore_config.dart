part of '../../flamestore.dart';

class FlamestoreConfig {
  FlamestoreConfig({
    @required this.projects,
    @required this.collectionClassMap,
    @required this.documentDefinitions,
  });

  final Map<String, ProjectConfig> projects;
  final Map<Type, String> collectionClassMap;
  final Map<String, DocumentDefinition> documentDefinitions;
}
