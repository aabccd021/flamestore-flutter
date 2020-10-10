import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

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
  final jsonString = await File(argResult[inputPath]).readAsString();
  final schema = Schema.fromJson(json.decode(jsonString));
  final generated = generate(schema);
  await File(argResult[ouputPath]).writeAsString(generated);
  await Process.run('flutter', ['format', argResult[ouputPath]]);
}

String generate(Schema schema) {
  String content = """
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flamestore/flamestore.dart';
""";
  for (final collectionEntry in schema.collections.entries) {
    content += generateCollection(
      schema,
      collectionEntry.key,
      collectionEntry.value,
    );
  }
  return content;
}
