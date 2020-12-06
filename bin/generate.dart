import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:inflection2/inflection2.dart';

import 'generate/collections.dart';
import 'generate/schema.dart';

const inputPath = 'input-path';
const ouputPath = 'output-path';
bool dev;

String generateProjects(Schema schema) {
  return schema.configuration.project.entries.map((project) {
    final val = project.value;
    final domain = val?.domain != null ? "domain:'${val.domain}'," : '';
    final dynamicLinkDomain = val?.dynamicLinkDomain != null
        ? "dynamicLinkDomain:'${val.dynamicLinkDomain}',"
        : '';
    final androidPackageName = val?.androidPackageName != null
        ? "androidPackageName:'${val.androidPackageName}',"
        : '';
    return ''''${project.key}':ProjectConfig(
      $domain$dynamicLinkDomain$androidPackageName
    )''';
  }).join(',');
}

String generateDynamicLinkBuilder(Schema schema) {
  final dlCollections = Map<String, Collection>.from(schema.collections)
    ..removeWhere((_, collection) {
      return collection.fields.values
          .every((field) => field.type.dynamicLink == null);
    });

  final parameter = dlCollections.entries.map((collectionEntry) {
    final colName = SINGULAR.convert(collectionEntry.key);
    return '@required Widget Function(${colName.inCaps} $colName) ${colName}Builder,';
  }).join();

  final returns = dlCollections.entries.map((collectionEntry) {
    final rawColName = collectionEntry.key;
    final colName = SINGULAR.convert(rawColName);
    return "'$rawColName': (Document document) =>"
        " ${colName}Builder(document as ${colName.inCaps}),";
  }).join();

  return """
  Map<String, Widget Function(Document)> dynamicLinkBuilders({
    ${parameter}
  }){
    return {
      ${returns}
    };
  }
""";
}

main(List<String> args) async {
  final parser = ArgParser()
    ..addOption(inputPath, abbr: 'i')
    ..addOption(ouputPath, abbr: 'o');
  final argResult = parser.parse(args);
  final jsonString =
      await File(argResult[inputPath] ?? '../flamestore.json').readAsString();
  final schema = Schema.fromJson(json.decode(jsonString));
  final path = argResult[ouputPath] ?? 'lib/flamestore';
  final colContent = schema.collections.entries
      .map((col) => generateCollection(schema, col.key, col.value))
      .join();
  final content = """
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flamestore/flamestore.dart';
import 'package:flutter/widgets.dart';
$colContent
final config = FlamestoreConfig(
  projects: {
    ${generateProjects(schema)}
  }
);

${generateDynamicLinkBuilder(schema)}
""";
  final filePath = '${path}/flamestore.g.dart';
  await File(filePath).writeAsString(content);
  await Process.run('flutter', ['format', filePath]);
}
