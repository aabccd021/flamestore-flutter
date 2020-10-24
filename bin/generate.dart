import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:inflection2/inflection2.dart';

import 'generate/collections.dart';
import 'generate/schema.dart';

const inputPath = 'input-path';
const ouputPath = 'output-path';
bool dev;
main(List<String> args) async {
  final parser = ArgParser()
    ..addOption(inputPath, abbr: 'i')
    ..addOption(ouputPath, abbr: 'o');
  final argResult = parser.parse(args);
  final jsonString =
      await File(argResult[inputPath] ?? '../flamestore.json').readAsString();
  final schema = Schema.fromJson(json.decode(jsonString));
  print(argResult[ouputPath]);
  await generate(argResult[ouputPath] ?? 'lib/flamestore', schema);
}

Future<void> generate(String path, Schema schema) async {
  final header = """
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flamestore/flamestore.dart';
""";
  for (final collectionEntry in schema.collections.entries) {
    final colName = collectionEntry.key;
    final content = header +
        generateCollection(
          schema,
          colName,
          collectionEntry.value,
        );
    final singularColName = SINGULAR.convert(colName);
    final filePath = '${path}/${singularColName}Document.dart';
    await File(filePath).writeAsString(content);
    await Process.run('flutter', ['format', filePath]);
  }
}
