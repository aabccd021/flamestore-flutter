part of '../../flamestore.dart';

class FlamestoreConfig {
  FlamestoreConfig({
    @required this.projects,
  });

  final Map<String, ProjectConfig> projects;
}
