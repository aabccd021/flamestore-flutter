part of '../../flamestore.dart';

class ProjectConfig {
  ProjectConfig({
    this.domain,
    this.dynamicLinkDomain,
    this.androidPackageName,
  });

  final String domain;
  final String dynamicLinkDomain;
  final String androidPackageName;
}
